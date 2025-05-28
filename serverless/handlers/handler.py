import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def log_event(event):
    logger.info("Received event:\n" + json.dumps(event, indent=2, ensure_ascii=False))


def hello(event, context):
    log_event(event)

    logger.info("Hello Lambda triggered")
    return {"statusCode": 200, "body": "Hello from Lambda!"}
