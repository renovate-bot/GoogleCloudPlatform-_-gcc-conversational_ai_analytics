from lib import CCCAIHelper
import time
ccai_helper = CCCAIHelper(
    ccai_insights_project_id="gsd-ccai-insights-offering",
    ccai_insights_location_id="global",
    bigquery_project_id="gsd-ccai-insights-offering",
    bigquery_staging_dataset="ccai_insights_export",
    bigquery_staging_table="export_staging",
    bigquery_final_dataset="ccai_insights_export",
    bigquery_final_table="export"
)

filter_expression="start_time > \"2024-07-31T17:00:00.000Z\""

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
# ccai_helper.execute_merge_query()