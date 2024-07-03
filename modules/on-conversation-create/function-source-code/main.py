from cloudevents.http import CloudEvent

import functions_framework

@functions_framework.cloud_event
def main(cloud_event: CloudEvent):
    """This function is triggered by a change in a storage bucket.

    Args:
        cloud_event: The CloudEvent that triggered this function.
    Returns:
        The event ID, event type, bucket, name, metageneration, and timeCreated.
    """
    data = cloud_event.data

    print(f"event data:{data}")

    return "ok"