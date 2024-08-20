from cloudevents.http import CloudEvent
import base64


import functions_framework
from google.cloud import contact_center_insights_v1

@functions_framework.cloud_event
def main(cloud_event: CloudEvent):
    print(cloud_event.data)

    decoded_data = base64.b64decode(cloud_event.data["message"]["data"])

    print(decoded_data)

    client = contact_center_insights_v1.ContactCenterInsightsClient()

    # Initialize request argument(s)
    operation_name = cloud_event.data["message"]["attributes"]["operation_name"]

    print(f"operation name:{operation_name}")

    request = contact_center_insights_v1.CreateAnalysisRequest(
        parent=operation_name,
    )

    # Make the request
    operation = client.create_analysis(request=request)

    print("Waiting for operation to complete...")

    response = operation.result()

    # Handle the response
    print(response)

    return "ok"