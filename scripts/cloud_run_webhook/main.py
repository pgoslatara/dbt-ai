"""Cloud Function that forwards Cloud Monitoring alerts to GitHub as repository_dispatch events."""

import base64
import json
import logging
import os
from urllib import error, request

logger = logging.getLogger(__name__)


def handle_pubsub(cloud_event: dict) -> str:
    """Handle Pub/Sub message from Cloud Monitoring and trigger GitHub workflow."""
    github_repo = os.environ.get("GITHUB_REPO", "")
    github_token = os.environ.get("GITHUB_TOKEN", "")

    if not github_repo or not github_token:
        logger.error("GITHUB_REPO and GITHUB_TOKEN environment variables are required")
        return "Missing configuration"

    # Decode Pub/Sub message
    event_data: dict = cloud_event
    message_data = base64.b64decode(event_data["data"]["message"]["data"]).decode("utf-8")
    alert_payload = json.loads(message_data)

    logger.info("Received alert: %s", alert_payload.get("incident", {}).get("summary", "unknown"))

    # Extract execution name from alert if available
    execution_name = ""
    incident = alert_payload.get("incident", {})
    log_entry = incident.get("observed_value", "")
    if "execution_name" in str(log_entry):
        execution_name = str(log_entry)

    # Trigger GitHub repository_dispatch
    url = f"https://api.github.com/repos/{github_repo}/dispatches"
    payload = json.dumps(
        {
            "event_type": "cloud_run_failure",
            "client_payload": {
                "execution_name": execution_name,
                "trigger_source": "cloud_monitoring_alert",
                "alert_summary": incident.get("summary", "Cloud Run Job failure detected"),
            },
        }
    ).encode("utf-8")

    req = request.Request(  # noqa: S310
        url,
        data=payload,
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {github_token}",
            "Content-Type": "application/json",
            "X-GitHub-Api-Version": "2022-11-28",
        },
        method="POST",
    )

    try:
        with request.urlopen(req) as response:  # noqa: S310
            logger.info("GitHub dispatch triggered: %s", response.status)
    except error.HTTPError as e:
        logger.exception("GitHub API error: %s %s", e.code, e.read().decode("utf-8"))
        return f"GitHub API error: {e.code}"
    except error.URLError as e:
        logger.exception("Network error: %s", e.reason)
        return f"Network error: {e.reason}"

    return "OK"
