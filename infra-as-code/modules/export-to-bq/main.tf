# data "local_file" "export_to_bq" {
#   filename = "${path.module}/workflow.yaml"
# }

data "google_service_account" "ccai_insights_sa" {
  account_id = var.service_account_id
}

# resource "google_workflows_workflow" "ccai_to_bq" {
#     name            = "export-ccai-to-bq"
#     region          = var.region
#     description     = "Exports the CCAI Insights conversations to BigQuery"
#     service_account = data.google_service_account.ccai_insights_sa.id

#     source_contents = data.local_file.export_to_bq.content
# }

module "cf_export_to_bq" {
  source      = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/cloud-function-v2"
  project_id  = var.project_id
  region      = var.region
  name        = var.function_name
  bucket_name = var.cf_bucket_name
  bundle_config = {
    path = "${path.module}/function-source-code"
    folder_options = {
        archive_path = "${path.module}/function-source-code/bundle.zip"
        excludes     = ["__pycache__"]
    }
  }
  service_account = data.google_service_account.ccai_insights_sa.email

  environment_variables = {
    CCAI_INSIGHTS_PROJECT_ID = var.ccai_insights_project_id
    CCAI_INSIGHTS_LOCATION_ID = var.ccai_insights_location_id
    BIGQUERY_PROJECT_ID = var.bigquery_project_id
    BIGQUERY_STAGING_DATASET = var.bigquery_staging_dataset
    BIGQUERY_STAGING_TABLE = var.bigquery_staging_table
    BIGQUERY_FINAL_DATASET = var.bigquery_final_dataset
    BIGQUERY_FINAL_TABLE = var.bigquery_final_table

  }
}

resource "google_cloud_scheduler_job" "ccai_to_bq_scheduler" {
  name     = "export-ccai-to-bq-scheduler"
  region = var.region
  schedule = var.export_to_bq_cron
  description = "Schedule to export CCAI Insights conversations to BigQuery"
  attempt_deadline = "120s"
  retry_config {
      retry_count = 3
  }
  http_target {
    uri         = module.cf_export_to_bq.uri
    http_method = "POST"
    oidc_token {
        audience              = "${module.cf_export_to_bq.uri}/"
        service_account_email = data.google_service_account.ccai_insights_sa.email
    }
  }
}
