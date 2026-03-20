#!/usr/bin/env bash
set -euo pipefail

# Deploy Cloud Monitoring alert for Cloud Run Job failures
# This creates an alert policy that triggers a Pub/Sub notification,
# which a Cloud Function forwards to GitHub as a repository_dispatch event.

PROJECT_ID="${GCP_PROJECT_ID:-dbt-ai-demo}"
REGION="europe-west4"
REPO_OWNER="pgoslatara"
REPO_NAME="dbt-ai"

echo "=== Enabling required APIs ==="
gcloud services enable \
    cloudfunctions.googleapis.com \
    cloudbuild.googleapis.com \
    monitoring.googleapis.com \
    pubsub.googleapis.com \
    --project="${PROJECT_ID}"

echo "=== Creating Pub/Sub topic ==="
gcloud pubsub topics create cloud-run-job-failures \
    --project="${PROJECT_ID}" \
    || echo "Topic already exists"

echo "=== Deploying webhook bridge Cloud Function ==="
gcloud functions deploy cloud-run-failure-webhook \
    --gen2 \
    --region="${REGION}" \
    --runtime=python312 \
    --source=scripts/cloud_run_webhook \
    --entry-point=handle_pubsub \
    --trigger-topic=cloud-run-job-failures \
    --set-env-vars="GITHUB_REPO=${REPO_OWNER}/${REPO_NAME}" \
    --set-secrets="GITHUB_TOKEN=github-pat:latest" \
    --project="${PROJECT_ID}" \
    --quiet

echo "=== Creating notification channel ==="
CHANNEL_ID=$(gcloud alpha monitoring channels create \
    --type=pubsub \
    --display-name="Cloud Run Job Failures" \
    --channel-labels=topic="projects/${PROJECT_ID}/topics/cloud-run-job-failures" \
    --project="${PROJECT_ID}" \
    --format="value(name)" \
    2>/dev/null) || echo "Channel may already exist"

echo "=== Creating alert policy ==="
cat > /tmp/alert-policy.json << POLICY
{
  "displayName": "Cloud Run Job Failure - dbt-ai-build",
  "conditions": [
    {
      "displayName": "Cloud Run Job execution failed",
      "conditionMatchedLog": {
        "filter": "resource.type=\"cloud_run_job\" AND resource.labels.job_name=\"dbt-ai-build\" AND severity>=ERROR"
      }
    }
  ],
  "combiner": "OR",
  "notificationChannels": ["${CHANNEL_ID}"],
  "alertStrategy": {
    "autoClose": "604800s"
  }
}
POLICY

gcloud alpha monitoring policies create \
    --policy-from-file=/tmp/alert-policy.json \
    --project="${PROJECT_ID}" \
    || echo "Alert policy may already exist"

echo "=== Setup complete ==="
echo ""
echo "Required secret in GCP Secret Manager:"
echo "  github-pat: A GitHub PAT with 'repo' scope for ${REPO_OWNER}/${REPO_NAME}"
echo ""
echo "Create it with:"
echo "  echo -n 'ghp_your_token_here' | gcloud secrets create github-pat --data-file=- --project=${PROJECT_ID}"
