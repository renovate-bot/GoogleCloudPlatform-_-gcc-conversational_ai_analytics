variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "function_name" {
  type = string
}

variable "service_account_email" {
  type = string
}

variable "pubsub_topic_name" {
  type = string
}

variable "cf_bucket_name" {
  type = string
  description = "Bucket used for storing the Cloud Function bundle"
}

