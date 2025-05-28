import os
import boto3
import json
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def log_event(event):
    logger.info("Received event:\n" + json.dumps(event, indent=2, ensure_ascii=False))


def call(event, context):
    log_event(event)

    bucket = os.environ.get("S3_BUCKET_NAME")
    if not bucket:
        raise ValueError("S3_BUCKET_NAME is not set")

    s3 = boto3.client("s3")
    timestamp = datetime.utcnow().isoformat()
    key = f"uploads/output_{timestamp}.json"
    content = json.dumps({"status": "ok", "timestamp": timestamp})

    logger.info(f"Putting object to S3: {bucket}/{key}")

    try:
        s3.put_object(
            Bucket=bucket, Key=key, Body=content, ContentType="application/json"
        )
        return {"statusCode": 200, "body": f"Stored object to {bucket}/{key}"}
    except Exception as e:
        logger.exception("Failed to write to S3")
        return {"statusCode": 500, "body": str(e)}
