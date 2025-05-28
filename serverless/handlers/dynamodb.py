import os
import boto3
import uuid
import json
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def log_event(event):
    logger.info("Received event:\n" + json.dumps(event, indent=2, ensure_ascii=False))


def call(event, context):
    log_event(event)

    table_name = os.environ.get("DYNAMODB_TABLE_NAME")
    if not table_name:
        raise ValueError("DYNAMODB_TABLE_NAME is not set")

    dynamodb = boto3.client("dynamodb")
    item_id = str(uuid.uuid4())
    now = datetime.utcnow().isoformat()

    logger.info(f"Inserting item to {table_name}: id={item_id}, timestamp={now}")

    try:
        response = dynamodb.put_item(
            TableName=table_name,
            Item={
                "id": {"S": item_id},  # AttributeType: S
                "timestamp": {"S": now},  # AttributeType: S
            },
        )
        return {"statusCode": 200, "body": f"PutItem succeeded: {item_id}"}
    except Exception as e:
        logger.exception("Failed to write to DynamoDB")
        return {"statusCode": 500, "body": str(e)}
