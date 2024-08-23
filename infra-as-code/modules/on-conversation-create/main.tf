
module "cf_handle_ccai_events" {
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

  trigger_config = {
    event_type            = "google.cloud.pubsub.topic.v1.messagePublished"
    service_account_email = var.service_account_email
    pubsub_topic = var.pubsub_topic_id
  }
}