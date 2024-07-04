

## Variables
```sh
PROJECT_ID=gsd-ccai-insights-offering
REGION=us-central1
```

## List conversations
```sh
AGENT_ID="test-import-1"

#with filter
curl -X GET \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    "https://contactcenterinsights.googleapis.com/v1/projects/${PROJECT_ID}/locations/${REGION}/conversations?filter=agent_id=\"${AGENT_ID}\""


#all conversations (saved to file)
curl -X GET \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    "https://contactcenterinsights.googleapis.com/v1/projects/${PROJECT_ID}/locations/${REGION}/conversations" > response.json
```

## Ingest conversations
```sh

gsutil cp gs://testccaiinsights/chat_0.json gs://testccaiinsights/chat_44.json

AGENT_ID="test1"
GCS_SOURCE="gs://ccai-sample-data-8854"

curl -X POST \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json; charset=utf-8" \
    -H "Accept: application/json" \
    -d '{"gcsSource":{"bucketUri":"gs://testccaiinsights/","bucketObjectType": "TRANSCRIPT"}}' \
    "https://contactcenterinsights.googleapis.com/v1/projects/gsd-ccai-insights-offering/locations/us-central1/conversations:ingest"

curl -X POST \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json; charset=utf-8" \
    -H "Accept: application/json" \
    -d @request.json \
    "https://contactcenterinsights.googleapis.com/v1/projects/gsd-ccai-insights-offering/locations/us-central1/conversations:ingest"


    -d '{"conversationConfig":{"agentId":"'"${AGENT_ID}"'"},{"gcsSource":{"bucketUri":"'"${GCS_SOURCE}"'"}}}' \
    
```

## Bulk Analyze
Reference:
https://cloud.google.com/contact-center/insights/docs/reference/rest/v1/projects.locations.conversations/bulkAnalyze
```sh
AGENT_ID="test-import-1"
curl -X POST \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json; charset=utf-8" \
    -H "Accept: application/json" \
    -d '{"filter":"","analysisPercentage":100}' \
    "https://contactcenterinsights.googleapis.com/v1/projects/${PROJECT_ID}/locations/${REGION}/conversations:bulkAnalyze"
```

## DANGER!: Bulk Delete
Reference:
https://cloud.google.com/contact-center/insights/docs/reference/rest/v1/projects.locations.conversations/bulkDelete
```sh
curl -X POST \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json; charset=utf-8" \
    -H "Accept: application/json" \
    -d '{"force":true,"max_delete_count":9999999}' \
    "https://contactcenterinsights.googleapis.com/v1/projects/${PROJECT_ID}/locations/${REGION}/conversations:bulkDelete"
```

