#!/bin/bash
### convert_from_gcs.sh

export src_gcs_bucket="<Source bucket name>"
export dest_gcs_bucket="<Destination bucket name>"
export project_id="<GCP Project ID>"
export impersonated_service_account=None
export sample_rate="<Sample rate in hertz>"

date +"%T.%3N"

python3 convert_from_gcs.py --src_gcs_bucket $src_gcs_bucket --dest_gcs_bucket $dest_gcs_bucket --project_id $project_id --impersonated_service_account $impersonated_service_account --sample_rate_hertz $sample_rate

date +"%T.%3N"