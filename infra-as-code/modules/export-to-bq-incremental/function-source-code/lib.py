#    Copyright 2024 Google LLC

#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at

#        http://www.apache.org/licenses/LICENSE-2.0

#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

import requests
import json
import google.auth
import google.oauth2.credentials
import google.auth.transport.requests
import time
import datetime

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

        merge_query = f'''
            MERGE `{final_table}` T 
                USING (
                    SELECT 
                    conversationName, 
                    audioFileUri, 
                    dialogflowConversationProfileId, 
                    startTimestampUtc, 
                    loadTimestampUtc, 
                    analysisTimestampUtc, 
                    conversationUpdateTimestampUtc, 
                    year,
                    month,
                    day, 
                    durationNanos, 
                    silenceNanos, 
                    silencePercentage, 
                    agentSpeakingPercentage, 
                    clientSpeakingPercentage, 
                    agentSentimentScore, 
                    agentSentimentMagnitude, 
                    clientSentimentScore, 
                    clientSentimentMagnitude, 
                    transcript, 
                    turnCount, 
                    languageCode, 
                    medium, 
                    issues,
                    entities,
                    labels,
                    words,
                    sentences,
                    latestSummary,
                    qaScorecardResults,
                    agents
                    FROM `{staging_table}`) S 
                    ON T.conversationName = S.conversationName 
                WHEN MATCHED AND T.conversationUpdateTimestampUtc != S.conversationUpdateTimestampUtc THEN 
                    UPDATE SET
                        audioFileUri = S.audioFileUri, 
                        dialogflowConversationProfileId = S.dialogflowConversationProfileId, 
                        startTimestampUtc = S.startTimestampUtc, 
                        loadTimestampUtc = S.loadTimestampUtc, 
                        analysisTimestampUtc = S.analysisTimestampUtc, 
                        conversationUpdateTimestampUtc = S.conversationUpdateTimestampUtc, 
                        year = S.year,
                        month = S.month,
                        day = S.day, 
                        durationNanos = S.durationNanos, 
                        silenceNanos = S.silenceNanos, 
                        silencePercentage = S.silencePercentage, 
                        agentSpeakingPercentage = S.agentSpeakingPercentage, 
                        clientSpeakingPercentage = S.clientSpeakingPercentage, 
                        agentSentimentScore = S.agentSentimentScore, 
                        agentSentimentMagnitude = S.agentSentimentMagnitude, 
                        clientSentimentScore = S.clientSentimentScore, 
                        clientSentimentMagnitude = S.clientSentimentMagnitude, 
                        transcript = S.transcript, 
                        turnCount = S.turnCount, 
                        languageCode = S.languageCode, 
                        medium = S.medium, 
                        issues = S.issues,
                        entities = S.entities,
                        labels = S.labels,
                        words = S.words,
                        sentences = S.sentences,
                        latestSummary = S.latestSummary,
                        qaScorecardResults = S.qaScorecardResults,
                        agents = S.agents
                WHEN NOT MATCHED THEN
                    INSERT ROW
        '''

        print("Merge query to be executed:")
        print(merge_query)

        merge_job = client.query(merge_query)  # API request
        merge_result = merge_job.result()  # Waits for query to finish

        print("Merge query result:")
        print(f"job_id: {merge_job.job_id}")
        print(f"num_dml_affected_rows: {merge_job.num_dml_affected_rows}")
    
    def get_latest_update_time(self):
        client = bigquery.Client()
        final_table = f'{self.bigquery_project_id}.{self.bigquery_final_dataset}.{self.bigquery_final_table}'

        query = f'''
            SELECT MAX(conversationUpdateTimestampUtc) as maxTimestamp FROM `{final_table}`
        '''

        bq_job = client.query(query)

        bq_job_result = bq_job.result()

        maxTimestamp = None
        for row in bq_job_result:
            maxTimestamp = row['maxTimestamp']

        print(f"maxTimestamp found: `{maxTimestamp}`")

        dt = datetime.datetime.fromtimestamp(maxTimestamp)
        formatted_time = dt.strftime('%Y-%m-%dT%H:%M:%SZ')

        print(f"maxTimestamp found (formatted): `{formatted_time}`")

        return formatted_time
