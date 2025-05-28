import time
import json
import logging
import multiprocessing
import math

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def log_event(event):
    logger.info("Received event:\n" + json.dumps(event, indent=2, ensure_ascii=False))


def cpu_workload():
    while True:
        math.sqrt(12345)


def perform_cpu_work(duration_sec):
    """CPU負荷をかけ続ける関数（duration秒間）"""
    end = time.time() + duration_sec
    while time.time() < end:
        _ = math.sqrt(123456.789) * math.cos(98765.4321)


def call(event, context):
    log_event(event)

    logger.info("Starting CPU stress test")

    # Number of CPU cores to maximize utilization
    # num_cores = multiprocessing.cpu_count()

    # processes = []
    # for _ in range(num_cores):
    #     p = multiprocessing.Process(target=cpu_workload)
    #     processes.append(p)
    #     p.start()

    # for p in processes:
    #     p.join()

    # CPU負荷を約30秒間かける(結局これはうまくいっていない)
    perform_cpu_work(30)

    logger.info("CPU stress test complete")
    return {"statusCode": 200, "body": f"Result: Success"}
