module "cf_custom_schema" {
  source      = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/cloud-function-v2"
  project_id  = var.project_id
  region      = var.region
  name        = var.function_name
  bucket_name = var.bucket_name
  bundle_config = {
    path = "${path.module}/function-source-code"
    folder_options = {
        archive_path = "${path.module}/function-source-code/bundle.zip"
        excludes     = ["__pycache__"]
    }
  }
  trigger_config = {
    event_type            = "google.cloud.storage.object.v1.finalized"
    service_account_email = var.service_account_email

    retry_policy = "RETRY_POLICY_RETRY"

    region = var.trigger_location

    event_filters = [
      {
        attribute = "bucket"
        value = var.trigger_bucket_name
      }
    ]
  }
}