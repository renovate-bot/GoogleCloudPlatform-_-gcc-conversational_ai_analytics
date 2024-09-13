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

## CCAI Insights Service Account BigQuery access
resource "google_project_iam_binding" "project" {
  project = var.project_id
  role    = "roles/bigquery.admin"

  members = [
    "serviceAccount:service-${data.google_project.project.number}@gcp-sa-contactcenterinsights.iam.gserviceaccount.com",
  ]
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
      "roles/eventarc.eventReceiver",
      "roles/bigquery.dataEditor",
      "roles/bigquery.jobUser"
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
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/gcs?ref=v31.1.0&depth=1"
  project_id = var.project_id
  name       = "cf-bucket-24812"
  location   = "US"
}


module "ccai_export_bq_dataset" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/bigquery-dataset?ref=v31.1.0&depth=1"
  project_id = var.project_id
  id         = "ccai_insights_export"
  location   =  "US" # needs to be in the same location as CCAI Insights

  tables = {
    export = {
      # deletion_protection = false
      friendly_name = "export"
    }
    export_staging = {
      # deletion_protection = false
      friendly_name = "export_staging"
    }
    custom_export = {
      friendly_name = "custom_export"
      schema = jsonencode([
        { 
          name = "conversationName", 
          type = "STRING" 
        },
        { 
          name = "latestSummary", 
          type = "RECORD",
          mode: "NULLABLE"
          fields = [
            {
              name: "textSections",
              type: "RECORD",
              mode: "REPEATED",
              fields: [
                {
                  name = "key", 
                  type = "STRING",
                },
                {
                  name = "value", 
                  type = "STRING",
                }
              ]
              }
            ]
        }
      ])
    } 
  }
}

module "pubsub_topic_conversation_created" {
  source      = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/pubsub?ref=v31.1.0&depth=1"
  project_id  = var.project_id
  name        = "ccai-insights-conversation-created"
}



## This module creates random conversation every 5 minutes (for TESTING purposes!!!!!)
# module "demo_conversation_creation" {
#   source  = "../../modules/demo-conversation-creation"
#   project_id = var.project_id
#   region = var.region
  
#   create_conversation_cron   = "*/5 * * * *"
#   service_account_id = module.ccai_insights_sa.id

#   depends_on = [ module.ccai_insights_sa ]
# }

module "ccai_insights_to_bq_incremental" {
  source  = "../../modules/export-to-bq-incremental"
  project_id = var.project_id
  region = var.region

  function_name = "export-to-bq-incremental"
  cf_bucket_name = module.cf_bundle_bucket.name
  
  ccai_insights_location_id = var.region
  ccai_insights_project_id = var.project_id
  bigquery_project_id = var.project_id
  bigquery_staging_dataset = module.ccai_export_bq_dataset.dataset_id
  bigquery_staging_table = module.ccai_export_bq_dataset.tables.export_staging.friendly_name
  bigquery_final_dataset = module.ccai_export_bq_dataset.dataset_id
  bigquery_final_table = module.ccai_export_bq_dataset.tables.export.friendly_name
  export_to_bq_cron   = "0 * * * *"
  service_account_email = module.ccai_insights_sa.id

  depends_on = [ module.ccai_insights_sa ]
}


# This module shows 
# module "on_conversation_create" {
#   source  = "../../modules/on-conversation-create"
#   project_id = var.project_id
#   region = var.region

#   function_name = "on-ccai-insights-conversation-create"
#   service_account_email = module.ccai_insights_sa.email
#   cf_bucket_name = module.cf_bundle_bucket.name

#   pubsub_topic_id = module.pubsub_topic_conversation_created.topic.id

#   depends_on = [ 
#     module.ccai_insights_sa,
#     module.cf_bundle_bucket
#   ]
# }


## Insights to PubSub to BQ
# Grant the PubSub Service Account permission to write data to BigQuery
resource "google_project_iam_member" "pubsub_bq_editor" {
  project = data.google_project.project.project_id
  role   = "roles/bigquery.dataEditor"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "pubsub_bq_metadata_viewer" {
  project = data.google_project.project.project_id
  role   = "roles/bigquery.metadataViewer"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}


