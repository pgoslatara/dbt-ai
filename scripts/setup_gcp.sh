#!/usr/bin/env bash
set -euo pipefail

# GCP Project Setup for dbt-ai
# Run this script to create and configure the GCP project.

PROJECT_ID="${GCP_PROJECT_ID:-dbt-ai-demo}"
REGION="europe-west4"
REPO_OWNER="pgoslatara"
REPO_NAME="dbt-ai"

echo "=== Creating GCP project ==="
gcloud projects create "${PROJECT_ID}" --name="dbt-ai Demo" || echo "Project already exists"
gcloud config set project "${PROJECT_ID}"

echo "=== Enabling required APIs ==="
gcloud services enable \
    artifactregistry.googleapis.com \
    bigquery.googleapis.com \
    iam.googleapis.com \
    iamcredentials.googleapis.com \
    run.googleapis.com

echo "=== Creating Artifact Registry repository ==="
gcloud artifacts repositories create dbt-ai \
    --repository-format=docker \
    --location="${REGION}" \
    || echo "Repository already exists"

echo "=== Creating service account for CI/CD ==="
gcloud iam service-accounts create github-actions \
    --display-name="GitHub Actions" \
    || echo "Service account already exists"

SA_EMAIL="github-actions@${PROJECT_ID}.iam.gserviceaccount.com"

echo "=== Granting IAM roles ==="
for ROLE in \
    "roles/artifactregistry.writer" \
    "roles/bigquery.dataEditor" \
    "roles/bigquery.jobUser" \
    "roles/logging.viewer" \
    "roles/run.admin"; do
    gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
        --member="serviceAccount:${SA_EMAIL}" \
        --role="${ROLE}" \
        --condition=None
done

echo "=== Setting up Workload Identity Federation ==="
gcloud iam workload-identity-pools create github-pool \
    --location="global" \
    --display-name="GitHub Actions Pool" \
    || echo "Pool already exists"

gcloud iam workload-identity-pools providers create-oidc github-provider \
    --location="global" \
    --workload-identity-pool="github-pool" \
    --display-name="GitHub Provider" \
    --attribute-condition="assertion.repository=='${REPO_OWNER}/${REPO_NAME}'" \
    --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    || echo "Provider already exists"

PROJECT_NUMBER=$(gcloud projects describe "${PROJECT_ID}" --format="value(projectNumber)")

gcloud iam service-accounts add-iam-policy-binding "${SA_EMAIL}" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/attribute.repository/${REPO_OWNER}/${REPO_NAME}"

echo "=== Granting service account actAs permission ==="
DEFAULT_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
gcloud iam service-accounts add-iam-policy-binding "${DEFAULT_SA}" \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/iam.serviceAccountUser" \
    --project="${PROJECT_ID}"

echo "=== Setup complete ==="
echo ""
echo "GitHub Secrets to configure:"
echo "  GCP_PROJECT_ID: ${PROJECT_ID}"
echo "  GCP_SERVICE_ACCOUNT: ${SA_EMAIL}"
echo "  GCP_WORKLOAD_IDENTITY_PROVIDER: projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/providers/github-provider"
