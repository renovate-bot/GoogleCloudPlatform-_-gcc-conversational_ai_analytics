module "pubsub_topic_output_bq" {
  source      = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/pubsub"
  project_id  = var.project_id
  name        = var.pubsub_topic_name_output_bq

  schema = {
    msg_encoding = "JSON"
    schema_type  = "AVRO"
    definition = jsonencode({
      "type" = "record",
      "name" = "Avro",
      "fields" = [{
        "name" = "conversationName",
        "type" = "string"
        }
        ,
        {
          "name" = "latestSummary",
          "type" = "record",
          "fields" = [
            {
              "name":"textSections",
              "type": "array",
              "items":[
                {
                  "type":"record",
                  "name":"textSection",
                  "fields":[
                    {
                      "name":"key",
                      "type":"string"
                    },
                    {
                      "name":"value",
                      "type":"string"
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    })
  }

  subscriptions = {
    test-bigquery = {
      bigquery = {
        table               = "${var.bigquery_project_id}.${var.bigquery_dataset}.${var.bigquery_table}"
        use_topic_schema    = true
        write_metadata      = false
        drop_unknown_fields = true
      }
    }
  }
}


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
    pubsub_topic = var.pubsub_topic_id_input_insights
  }
}