variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "ccai_insights_project_id" {
  type = string
}

variable "ccai_insights_location_id" {
  type = string
}

variable "bigquery_project_id" {
  type = string
}

variable "bigquery_staging_dataset" {
  type = string
}

variable "bigquery_final_dataset" {
  type = string
}

variable "bigquery_staging_table" {
  type = string
}

variable "bigquery_final_table" {
  type = string
}

variable "export_to_bq_cron" {
  type = string
}

variable "service_account_id" {
  type = string
}

variable "cf_bucket_name" {
  type = string
}

variable "function_name" {
  type = string
}