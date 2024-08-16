#!/bin/bash
### ingest_transcript_from_gcs.sh

export source_voice_transcript_gcs_bucket=None
export source_chat_transcript_gcs_bucket="<Source GCS bucket name>"
: '
If transcript location is gs://bucket_name/folder/transcript.json then 
source_chat_transcript_gcs_bucket="bucket_name"
'
export source_folder_path="<Folder path of input files>"
: '
If transcript location is gs://bucket_name/folder/path/transcript.json then 
source_folder_path="folder"
'
export xml_gcs_bucket=None
export transcript_metadata_flag=True
export agent_channel=2
export PROJECT_ID="<GCS Project ID>"
export analyze=False
export agent_id="<Agent ID>"
export redact=True


date +"%T.%3N"

python3 import_conversations_v2.py --source_chat_transcript_gcs_bucket $source_chat_transcript_gcs_bucket --xml_gcs_bucket $xml_gcs_bucket --transcript_metadata_flag $transcript_metadata_flag --folder_name $source_folder_path --agent_channel $agent_channel --analyze $analyze --agent_id $agent_id $PROJECT_ID  --redact $redact

date +"%T.%3N"