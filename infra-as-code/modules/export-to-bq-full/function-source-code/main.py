import functions_framework
import json
import os
import google.auth
import google.oauth2.credentials
import google.auth.transport.requests
import requests
from google.cloud import bigquery
import time

@functions_framework.http
def main(request):
    CCAI_INSIGHTS_PROJECT_ID=os.environ["CCAI_INSIGHTS_PROJECT_ID"]
    CCAI_INSIGHTS_LOCATION_ID=os.environ["CCAI_INSIGHTS_LOCATION_ID"]
    BIGQUERY_PROJECT_ID=os.environ["BIGQUERY_PROJECT_ID"]
    BIGQUERY_DATASET=os.environ["BIGQUERY_DATASET"]
    BIGQUERY_TABLE=os.environ["BIGQUERY_TABLE"]

    def get_token():
        creds, _ = google.auth.default(
            scopes=['https://www.googleapis.com/auth/cloud-platform'])
        auth_req = google.auth.transport.requests.Request()
        creds.refresh(auth_req)

        # print(f"identity: {creds.service_account_email}")

        return creds.token

    def submit_export_request():
        headers = {
            'charset': 'utf-8',
            'Content-type': 'application/json',
            'Authorization': f'Bearer {get_token()}'
        }

        request_data = {
            "parent": f"projects/{CCAI_INSIGHTS_PROJECT_ID}/locations/{CCAI_INSIGHTS_LOCATION_ID}",
            "writeDisposition":"WRITE_TRUNCATE",
            "bigQueryDestination":{
                "projectId":BIGQUERY_PROJECT_ID,
                "dataset":BIGQUERY_DATASET,
                "table":BIGQUERY_TABLE
            }
        }
        # print(request_data)

        url = ('https://contactcenterinsights.googleapis.com/v1/'
            f'projects/{CCAI_INSIGHTS_PROJECT_ID}/locations/{CCAI_INSIGHTS_LOCATION_ID}/insightsdata:export')

        response = requests.post(url, headers=headers, json=request_data)
        response.raise_for_status()

        response_json = response.json()
        
        return response_json

    def get_operation(operation_name):
        headers = {
            'charset': 'utf-8',
            'Content-type': 'application/json',
            'Authorization': f'Bearer {get_token()}'
        }

        url = (f'https://contactcenterinsights.googleapis.com/v1/{operation_name}')

        response = requests.get(url, headers=headers)
        response.raise_for_status()

        return response.json()
        

    export_operation = submit_export_request()

    for i in range(30):
        operation_result = get_operation(export_operation["name"])
        operation_name = export_operation["name"]
        
        # check if the operation is finished
        if "done" in operation_result and operation_result["done"] == True:
            if "error" in operation_result:
                raise Exception(operation_result["error"])
            else:
                print("BigQuery export finished. Result:")
                print(operation_result)
                break
        else:
            print(f"Operation '{operation_name}' still running, sleeping...")
            time.sleep(30) # sleep 20 seconds

    return "ok"