import json
import urllib.request
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def log_event(event):
    logger.info("Received event:\n" + json.dumps(event, indent=2, ensure_ascii=False))


def viewer_request(event, context):
    log_event(event)

    # lambda edgeは反映に遅延するので、lambda edgeが反映されているか、外部インターネットに出られるか外部のエンドポイントを叩いてチェック
    # (自前のじゃないと結局ログ見れないが、、環境変数も使えないので適宜公開していいやつでセットして確認)
    webhook_url = "https://google.com"
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
