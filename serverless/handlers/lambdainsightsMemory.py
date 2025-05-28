import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def log_event(event):
    logger.info("Received event:\n" + json.dumps(event, indent=2, ensure_ascii=False))


def allocate_memory(size_mb):
    """指定したMBのリストを確保してメモリ使用量を調整する"""
    # 1MB ≒ 1024 * 1024 バイト、ここでは float を使う（1要素 ≒ 24バイト?8にしてみる）
    size = size_mb * 1024 * 1024 // 8
    dummy = [0.0] * size
    return dummy


def call(event, context):
    log_event(event)

    logger.info("Starting memory allocation test")

    # 約115MBを確保（128MBの90%程度）(微調整して変更)
    dummy_memory = allocate_memory(100)

    # data = ["x" * 1024 * 1024 for _ in range(500)]
    # logger.info(f"Allocated {len(dummy_memory)} MB of memory")
    return {"statusCode": 200, "body": f"Allocated memory blocks: {len(dummy_memory)}"}
