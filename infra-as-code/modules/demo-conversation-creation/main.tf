data "local_file" "demo_conversation_creation" {
  filename = "${path.module}/workflow.yaml"
}

data "google_service_account" "ccai_insights_sa" {
  account_id = var.service_account_id
}

resource "google_workflows_workflow" "demo_conversation_creation" {
    name            = "create-demo-conversation"
    region          = var.region
    description     = "Creates a demo conversation by randomly picking a file from a bucket"
    service_account = data.google_service_account.ccai_insights_sa.id

    source_contents = data.local_file.demo_conversation_creation.content
}

resource "google_cloud_scheduler_job" "demo_conversation_creation" {
    name     = "create-demo-conversation"
    region = var.region
    schedule = var.create_conversation_cron
    description = "Schedule to create a demo conversation"
    attempt_deadline = "120s"
    retry_config {
        retry_count = 3
    }
    http_target {
        http_method = "POST"
        uri = "https://workflowexecutions.googleapis.com/v1/projects/${var.project_id}/locations/${var.region}/workflows/${google_workflows_workflow.demo_conversation_creation.name}/executions"
        oauth_token {
            service_account_email = data.google_service_account.ccai_insights_sa.email
        }
    }
}
