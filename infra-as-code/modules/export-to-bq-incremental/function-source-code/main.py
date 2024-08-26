import functions_framework
import json
import os
import time
from datetime import datetime, timedelta

from lib import CCCAIHelper

@functions_framework.http
def main(request):
    CCAI_INSIGHTS_PROJECT_ID=os.environ["CCAI_INSIGHTS_PROJECT_ID"]
    CCAI_INSIGHTS_LOCATION_ID=os.environ["CCAI_INSIGHTS_LOCATION_ID"]
    BIGQUERY_PROJECT_ID=os.environ["BIGQUERY_PROJECT_ID"]
    BIGQUERY_STAGING_DATASET=os.environ["BIGQUERY_STAGING_DATASET"]
    BIGQUERY_STAGING_TABLE=os.environ["BIGQUERY_STAGING_TABLE"]
    BIGQUERY_FINAL_DATASET=os.environ["BIGQUERY_FINAL_DATASET"]
    BIGQUERY_FINAL_TABLE=os.environ["BIGQUERY_FINAL_TABLE"]

    ccai_helper = CCCAIHelper(
        ccai_insights_project_id=CCAI_INSIGHTS_PROJECT_ID,
        ccai_insights_location_id=CCAI_INSIGHTS_LOCATION_ID,
        bigquery_project_id=BIGQUERY_PROJECT_ID,
        bigquery_staging_dataset=BIGQUERY_STAGING_DATASET,
        bigquery_staging_table=BIGQUERY_STAGING_TABLE,
        bigquery_final_dataset=BIGQUERY_FINAL_DATASET,
        bigquery_final_table=BIGQUERY_FINAL_TABLE
    )

    now = datetime.now()
    start_time = (now - timedelta(hours=1)).strftime('%Y-%m-%dT%H:%M:%SZ')

    # Filter based on conversation start time and only Analyzed conversations
    filter_expression=f"start_time > \"{start_time}\" latest_analysis:\"*\""

    print(f"Filter for exporting CCAI Insights Data: {filter_expression}")

    export_operation = ccai_helper.submit_export_request(filter=filter_expression)

    for i in range(30):
        operation_result = ccai_helper.get_operation(export_operation["name"])
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

    print("Executing merge operation")
    ccai_helper.execute_merge_query()

    return "ok"