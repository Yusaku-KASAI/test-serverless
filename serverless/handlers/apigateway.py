import os
import requests
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def log_event(event):
    logger.info("Received event:\n" + json.dumps(event, indent=2, ensure_ascii=False))


def call(event, context):
    log_event(event)

    api_endpoint = os.environ.get("API_ENDPOINT")
    if not api_endpoint:
        raise ValueError("API_ENDPOINT is not set")

    try:
        logger.info(f"Sending request to {api_endpoint}")
        response = requests.get(api_endpoint, timeout=10)
        response.raise_for_status()
        return {"statusCode": 200, "body": f"Success: {response.text[:100]}"}
    except Exception as e:
        logger.exception("Failed to call API endpoint")
        return {"statusCode": 500, "body": str(e)}
