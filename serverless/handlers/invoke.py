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

    function_name = os.environ.get("NEXT_FUNCTION_NAME")
    if not function_name:
        raise ValueError("NEXT_FUNCTION_NAME is not set")

    lambda_client = boto3.client("lambda")

    logger.info(f"Invoking function: {function_name}")
    try:
        response = lambda_client.invoke(
            FunctionName=function_name, InvocationType="Event"
        )
        return {
            "statusCode": 200,
            "body": f"Invoked {function_name}, status: {response['StatusCode']}",
        }
    except Exception as e:
        logger.exception("Failed to invoke Lambda")
        return {"statusCode": 500, "body": str(e)}
