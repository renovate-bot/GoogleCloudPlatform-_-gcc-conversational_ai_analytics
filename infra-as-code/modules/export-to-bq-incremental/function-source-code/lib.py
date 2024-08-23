
import requests
import json
import google.auth
import google.oauth2.credentials
import google.auth.transport.requests
import time

from google.cloud import bigquery

class CCCAIHelper:
    ccai_insights_project_id: str
    ccai_insights_location_id: str
    bigquery_project_id: str
    bigquery_staging_dataset: str
    bigquery_staging_table: str
    bigquery_final_dataset: str
    bigquery_final_table: str

    def __init__(
        self, 
        ccai_insights_project_id,
        ccai_insights_location_id,
        bigquery_project_id,
        bigquery_staging_dataset,
        bigquery_staging_table,
        bigquery_final_dataset,
        bigquery_final_table
        ):

        self.ccai_insights_project_id = ccai_insights_project_id
        self.ccai_insights_location_id = ccai_insights_location_id
        self.bigquery_project_id = bigquery_project_id
        self.bigquery_staging_dataset = bigquery_staging_dataset
        self.bigquery_staging_table = bigquery_staging_table
        self.bigquery_final_dataset = bigquery_final_dataset
        self.bigquery_final_table = bigquery_final_table

    def get_token(self):
        creds, _ = google.auth.default(
            scopes=['https://www.googleapis.com/auth/cloud-platform'])
        auth_req = google.auth.transport.requests.Request()
        creds.refresh(auth_req)

        # print(f"identity: {creds.service_account_email}")

        return creds.token

    def get_operation(self,operation_name):
        headers = {
            'charset': 'utf-8',
            'Content-type': 'application/json',
            'Authorization': f'Bearer {self.get_token()}'
        }

        url = (f'https://contactcenterinsights.googleapis.com/v1/{operation_name}')

        response = requests.get(url, headers=headers)
        response.raise_for_status()

        return response.json()
    
    def submit_export_request(self, filter):
        headers = {
            'charset': 'utf-8',
            'Content-type': 'application/json',
            'Authorization': f'Bearer {self.get_token()}'
        }

        request_data = {
            "parent": f"projects/{self.ccai_insights_project_id}/locations/{self.ccai_insights_location_id}",
            "writeDisposition":"WRITE_TRUNCATE",
            "bigQueryDestination":{
                "projectId":self.bigquery_project_id,
                "dataset":self.bigquery_staging_dataset,
                "table":self.bigquery_staging_table
            },
            "filter":filter
        }
        print("BQ Export Request Data:")
        print(request_data)

        url = ('https://contactcenterinsights.googleapis.com/v1/'
            f'projects/{self.ccai_insights_project_id}/locations/{self.ccai_insights_location_id}/insightsdata:export')

        response = requests.post(url, headers=headers, json=request_data)
        response.raise_for_status()

        response_json = response.json()
        
        return response_json
    
    def execute_merge_query(self):
        client = bigquery.Client()
        staging_table = f'{self.bigquery_project_id}.{self.bigquery_staging_dataset}.{self.bigquery_staging_table}'
        final_table = f'{self.bigquery_project_id}.{self.bigquery_final_dataset}.{self.bigquery_final_table}'

        merge_query = (
            f'MERGE `{final_table}` T USING (SELECT conversationName, MAX(analysisTimestampUtc)'
            f'AS max_time FROM `{staging_table}` GROUP BY conversationName) S'
            'ON T.conversationName = S.conversationName'
            'WHEN MATCHED AND T.analysisTimestampUtc != S.max_time THEN DELETE'
        )
        print("Merge query to be executed:")
        print(merge_query)

        query_job = client.query(merge_query)  # API request
        result = query_job.result()  # Waits for query to finish

        print("Merge query result:")
        print(result)