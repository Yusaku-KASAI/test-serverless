import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def log_event(event):
    logger.info("Received event:\n" + json.dumps(event, indent=2, ensure_ascii=False))


def call(event, context):
    log_event(event)

    logger.info("Logging event from SNS:")
    logger.info(event)
    logger.error("ERROR: This is a test error log and triggering a CloudWatch alarm")
    return {"statusCode": 200, "body": "Event logged"}
