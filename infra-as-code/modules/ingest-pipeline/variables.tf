#    Copyright 2024 Google LLC

#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at

#        http://www.apache.org/licenses/LICENSE-2.0

#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

variable "project_id" {
  type = string
}

variable "env" {
  type = string
}

variable "ccai_insights_project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "service_account_email" {
  type = string
}

variable "service_account_id" {
  type = string
}

variable "service_account_id_2" {
  type = string
}

variable "insights_endpoint" {
  type = string
}

variable "insights_api_version" {
  type = string
}

variable "ccai_insights_location_id" {
  type = string
  description = "Location ID of CCAI Insights"
}

variable "pipeline_name" {
  type = string
}

variable "recognizer_path" {
  type = string
}

variable "stt_function_name" {
  type = string
}

variable "model_name" {
  type = string
  description = "Name of the Gemini Model to be used in the Cloud Function"
}

variable genai_function_name {
  type = string
}

variable "audio_redaction_function_name" {
  type = string
  default = "cf_audio_redaction"
  description = "Cloud Function name"
}

variable "feedback_generator_function_name" {
  type = string
  description = "Cloud Function name"
}

variable "dataset_name" {
  type = string
  description = "BigQuery Dataset name"
}

variable "feedback_table_name" {
  type = string
  description = "BigQuery feedback table name"
}

variable "scorecard_id" {
  type = string
  description = "CCAI Insights Scorecard ID"
}

variable "target_tags" {
  type = string
  description = "Comma-separated list of target tags"
  default = "tag1,tag2" 
}

variable "target_values" {
  type = string
  description = "Comma-separated list of target tags"
  default = "val1,val2" 
}

variable "client_specific_constraints" {
  type = string
  description = "Client specific contraints for GenAI prompt"
} 

variable "client_specific_context" {
  type = string
  description = "Client specific context for GenAI prompt"
} 

variable "few_shot_examples" {
  type = string
  description = "Few examples of correct transcripts for the GenAI prompt"
} 

variable "hash_secret_name" {
  type = string
  description = "Name or ID of the secret for the hashing key"
}

variable "hash_key" {
  type = string
}
