data "local_file" "export_to_bq" {
  filename = "${path.module}/workflow.yaml"
}

data "google_service_account" "ccai_insights_sa" {
  account_id = var.service_account_id
}

resource "google_workflows_workflow" "ccai_to_bq" {
    name            = "export-ccai-to-bq"
    region          = var.region
    description     = "Exports the CCAI Insights conversations to BigQuery"
    service_account = data.google_service_account.ccai_insights_sa.id

    user_env_vars = {
        bigquery_project = var.project_id
        bigquery_dataset = var.bigquery_dataset,
        bigquery_table = var.bigquery_table,
    }
    source_contents = data.local_file.export_to_bq.content
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
        http_method = "POST"
        uri = "https://workflowexecutions.googleapis.com/v1/projects/${var.project_id}/locations/${var.region}/workflows/${google_workflows_workflow.ccai_to_bq.name}/executions"
        oauth_token {
            service_account_email = data.google_service_account.ccai_insights_sa.email
        }
    }
}
