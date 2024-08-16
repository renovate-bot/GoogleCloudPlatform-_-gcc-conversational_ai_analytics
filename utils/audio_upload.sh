#!/bin/bash
### audio_upload.sh

export source_audio_gcs_bucket=<SOURCE BUCKET NAME>
export xml_gcs_bucket=None
export agent_channel=1
export PROJECT_ID=<PROJECT ID>
export deidentify_template=projects/<PROJECT_ID>/locations/global/deidentifyTemplates/insights-demo-deidentify-template
export inspect_template=projects/<PROJECT_ID>/locations/global/inspectTemplates/insights-demo-inspect-template
export audio_format=flac
export agent_id=audio-upload


date +"%T.%3N"

python3 audio_upload.py --source_audio_gcs_bucket $source_audio_gcs_bucket --xml_gcs_bucket $xml_gcs_bucket --agent_channel $agent_channel --inspect_template $inspect_template --deidentify_template $deidentify_template --audio_format $audio_format --agent_id $agent_id $PROJECT_ID

date +"%T.%3N"