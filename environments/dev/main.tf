# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


locals {
  env = "dev"
}

provider "google" {
  project = "${var.project_id}"
}

data "google_project" "project" {
  project_id = var.project_id
}

module "ccai_insights_sa" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/iam-service-account?ref=v31.1.0&depth=1"
  project_id = var.project_id
  name       = "ccai-insights-demo1"

  # non-authoritative roles granted *to* the service accounts on other resources
  iam_project_roles = {
    "${var.project_id}" = [
      "roles/contactcenterinsights.editor",
      "roles/logging.logWriter",
      "roles/workflows.invoker",


       # only required if GCS/PubSub trigger will be used by Cloud Function v2
      "roles/pubsub.publisher",
      "roles/run.invoker",
      "roles/eventarc.eventReceiver"
    ]
  }
}

# the GCS default Service Account needs to have permissions to publish Eventarc events
resource "google_project_iam_member" "gcs_pubsub_publisher" { 
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
}

# This bucket will be used for storing the Cloud Functions bundle (.zip file with source code)
module "cf_bundle_bucket" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/gcs"
  project_id = var.project_id
  name       = "cf-bucket-24812"
  location   = "US"
}


module "ccai_export_bq_dataset" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/bigquery-dataset"
  project_id = var.project_id
  id         = "ccai_insights"

  tables = {
    export = {
      friendly_name = "export"
    }
  }
}

## This module creates random conversation every 5 minutes (for TESTING purposes!!!!!)
module "demo_conversation_creation" {
  source  = "../../modules/demo-conversation-creation"
  project_id = var.project_id
  region = var.region
  
  create_conversation_cron   = "*/5 * * * *"
  service_account_id = module.ccai_insights_sa.id

  depends_on = [ module.ccai_insights_sa ]
}


## This module creates a Cloud Scheduler job that exports CCAI Insights data to BigQuery
module "ccai_insights_to_bq" {
  source  = "../../modules/export-ccai-insights-to-bq"
  project_id = var.project_id
  region = var.region
  
  ccai_insights_region = var.region
  bigquery_project_id = var.project_id
  bigquery_dataset = module.ccai_export_bq_dataset.dataset_id
  bigquery_table = module.ccai_export_bq_dataset.tables.export.friendly_name
  export_to_bq_cron   = "0 */2 * * *"
  service_account_id = module.ccai_insights_sa.id

  depends_on = [ module.ccai_insights_sa ]
}

# This module shows how to create a Cloud Function that reacts to the creation of GCS objects

module "custom-schema-sample" {
  source  = "../../modules/custom-schema-sample"
  project_id = var.project_id
  region = var.region

  function_name = "custom-schema-sample"
  service_account_email = module.ccai_insights_sa.email
  cf_bucket_name = module.cf_bundle_bucket.name

  trigger_bucket_name = "ccai-sample-data-8854"
  trigger_location = "us"

  depends_on = [ 
    module.ccai_insights_sa,
    module.cf_bundle_bucket,
    google_project_iam_member.gcs_pubsub_publisher
  ]
}

# This module shows 
module "on_conversation_create" {
  source  = "../../modules/on-conversation-create"
  project_id = var.project_id
  region = var.region

  function_name = "on-ccai-insights-conversation-create"
  service_account_email = module.ccai_insights_sa.email
  cf_bucket_name = module.cf_bundle_bucket.name

  pubsub_topic_name = "ccai-insights-conversation-uploaded"

  depends_on = [ 
    module.ccai_insights_sa,
    module.cf_bundle_bucket
  ]
}

