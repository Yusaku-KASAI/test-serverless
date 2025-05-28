import os
import json
import logging
import boto3
import pymysql
import uuid
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def log_event(event):
    logger.info("Received event:\n" + json.dumps(event, indent=2, ensure_ascii=False))


def call(event, context):
    log_event(event)

    secret_arn = os.environ.get("DB_SECRET_ARN")
    db_host = os.environ.get("DB_HOST")
    db_port = os.environ.get("DB_PORT")
    db_user = os.environ.get("DB_USER")
    db_name = os.environ.get("DB_NAME")
    if (
        not secret_arn
        or not db_host
        or not db_user
        or not db_name
        or not db_port
        or not db_port
    ):
        raise ValueError("env is not set")

    region_name = os.environ.get("AWS_REGION", "ap-northeast-1")

    # ① Secrets Manager から取得
    secrets_client = boto3.client("secretsmanager", region_name=region_name)
    try:
        secret_value = secrets_client.get_secret_value(SecretId=secret_arn)
        secret = json.loads(secret_value["SecretString"])
        db_password = secret.get("password")
    except Exception as e:
        logger.exception("Failed to retrieve DB credentials from Secrets Manager")
        return {"statusCode": 500, "body": "Could not retrieve credentials"}

    # ② MySQL に接続して簡易クエリ実行
    try:
        connection = pymysql.connect(
            host=db_host,
            user=db_user,
            password=db_password,
            database=db_name,
            port=int(db_port),
            connect_timeout=5,
            autocommit=True,
        )

        with connection.cursor() as cursor:
            # 現在のDB時間を取得
            cursor.execute("SELECT NOW()")
            result = cursor.fetchone()

            # テーブル作成（存在しない場合）
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS test_table (
                    id VARCHAR(36) PRIMARY KEY,
                    created_at DATETIME NOT NULL
                )
            """
            )

            # レコード挿入
            new_id = str(uuid.uuid4())
            now = datetime.utcnow()
            cursor.execute(
                "INSERT INTO test_table (id, created_at) VALUES (%s, %s)", (new_id, now)
            )

            # 確認のため最新の5件を取得
            cursor.execute("SELECT * FROM test_table ORDER BY created_at DESC LIMIT 5")
            rows = cursor.fetchall()
            logger.info(f"Latest rows: {rows}")

        logger.info(f"DB Time: {result[0]}")
        return {
            "statusCode": 200,
            "body": f"Database connection successful. Time: {result[0]}",
        }

    except Exception as e:
        logger.exception("Database connection or query failed")
        return {"statusCode": 500, "body": "Database error"}

    finally:
        if "connection" in locals() and connection:
            connection.close()
