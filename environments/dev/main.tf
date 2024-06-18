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

module "cf_bundle_bucket" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/gcs"
  project_id = var.project_id
  name       = "cf-bucket-24812"
  location   = "US"
}

module "ccai_insights_to_bq" {
  source  = "../../modules/ccai-insights-to-bq"
  project_id = var.project_id
  region = var.region
  
  bigquery_dataset = var.bigquery_dataset
  bigquery_table = var.bigquery_dataset
  export_to_bq_cron   = var.export_to_bq_cron
  service_account_id = module.ccai_insights_sa.id

  depends_on = [ module.ccai_insights_sa ]
}



module "custom-schema-sample" {
  source  = "../../modules/custom-schema-sample"
  project_id = var.project_id
  region = var.region

  service_account_email = module.ccai_insights_sa.email
  bucket_name = module.cf_bundle_bucket.name
}

