import json
import urllib.request
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def log_event(event):
    logger.info("Received event:\n" + json.dumps(event, indent=2, ensure_ascii=False))


def viewer_request(event, context):
    log_event(event)

    webhook_url = "https://mail-to-line.liny.jp/check"
    payload = {"text": "Hello, World! From Lambda@Edge"}

    try:
        req = urllib.request.Request(
            webhook_url,
            data=json.dumps(payload).encode("utf-8"),
            headers={"Content-Type": "application/json"},
        )
        with urllib.request.urlopen(req) as res:
            print("Slack response:", res.read().decode())
    except Exception as e:
        print("Slack webhook failed:", str(e))

    return event["Records"][0]["cf"]["request"]
