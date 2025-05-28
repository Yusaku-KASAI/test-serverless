import os
import boto3
import json
import logging


logger = logging.getLogger()
logger.setLevel(logging.INFO)


def log_event(event):
    logger.info("Received event:\n" + json.dumps(event, indent=2, ensure_ascii=False))


def call(event, context):
    log_event(event)

    topic_arn = os.environ.get("SNS_TOPIC_ARN")
    if not topic_arn:
        raise ValueError("SNS_TOPIC_ARN is not set")

    sns = boto3.client("sns")
    message = json.dumps({"event": event})

    logger.info(f"Publishing to SNS topic: {topic_arn}")

    try:
        sns.publish(
            TopicArn=topic_arn, Message=message, Subject="S3 Trigger Notification"
        )
        return {"statusCode": 200, "body": "SNS message sent"}
    except Exception as e:
        logger.exception("Failed to publish to SNS")
        return {"statusCode": 500, "body": str(e)}
