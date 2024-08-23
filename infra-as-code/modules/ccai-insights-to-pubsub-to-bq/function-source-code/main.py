from cloudevents.http import CloudEvent
import base64
from concurrent import futures
from google.cloud import pubsub_v1
from typing import Callable

import functions_framework

@functions_framework.cloud_event
def main(cloud_event: CloudEvent):
    print(cloud_event.data)

    decoded_data = base64.b64decode(cloud_event.data["message"]["data"])

    print(decoded_data)

    