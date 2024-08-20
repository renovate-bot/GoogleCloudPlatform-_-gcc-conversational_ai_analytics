

```sh
PROJECT_ID=gsd-ccai-insights-offering
LOCATION_ID=global
```

This is for the legacy summarization:
https://cloud.google.com/contact-center/insights/docs/summarization#use_a_custom_summarization_model

Summarization with custom sections
https://cloud.google.com/agent-assist/docs/summarization-with-custom-sections


Summarize conversation
```sh
GENERATOR_ID="OTY1MDczMDc2NjA5NDU2NTM3Nw"
cat <<EOT > /tmp/summarization_custom_generator.json
{
  "parent": "projects/${PROJECT_ID}/locations/${LOCATION_ID}",
  "generatorName": "projects/${PROJECT_ID}/locations/${LOCATION_ID}/generators/${GENERATOR_ID}",
  "conversationContext": {
    "messageEntries": [{
      "role": "HUMAN_AGENT",
      "text": "Hi, this is ABC messaging, how can I help you today?",
      "languageCode": "en-US"
    }, {
      "role": "END_USER",
      "text": "I want to return my order, it is broken",
      "languageCode": "en-US"
    }, {
      "role": "HUMAN_AGENT",
      "text": "I surely can help you with this. I'm really sorry how are having this problem",
      "languageCode": "en-US"
    }]
  },
  "triggerEvents": [
    "MANUAL_CALL"
  ]
}
EOT

curl -X POST \
     -H "Authorization: Bearer $(gcloud auth print-access-token)" \
     -H "x-goog-user-project: ${PROJECT_ID}" \
     -H "Content-Type: application/json; charset=utf-8" \
     -d @/tmp/summarization_custom_generator.json \
     "https://dialogflow.googleapis.com/v2/projects/${PROJECT_ID}/locations/${LOCATION_ID}/statelessSuggestion:generate"
```


CCAI Insights conversation
```sh
gsutil cp gs://ccai-sample-data-8854/chat_0.json /tmp/ccai_conversation.json

GENERATOR_ID="OTY1MDczMDc2NjA5NDU2NTM3Nw"
cat <<EOT > /tmp/summarization_custom_generator.json
{
  "parent": "projects/${PROJECT_ID}/locations/${LOCATION_ID}",
  "generatorName": "projects/${PROJECT_ID}/locations/${LOCATION_ID}/generators/${GENERATOR_ID}",
  "conversationContext": {
    "messageEntries": [
        {
            "start_timestamp_usec": 1716922939000000,
            "text": "Hi there, what can I help you with today?",
            "role": "HUMAN_AGENT",
            "user_id": 2
        },
        {
            "start_timestamp_usec": 1716922950000000,
            "text": "Hi, I'm having an issue with my mobile phone",
            "role": "END_USER",
            "user_id": 1
        },
        {
            "start_timestamp_usec": 1716922961000000,
            "text": "Sorry to hear. Can you tell me what the problem is?",
            "role": "HUMAN_AGENT",
            "user_id": 2
        },
        {
            "start_timestamp_usec": 1716922972000000,
            "text": "The mobile phone is not connecting to the internet. The mobile phone cannot connect to a Wi-Fi network. The mobile phone cannot connect to the internet when plugged into a wired network.",
            "role": "END_USER",
            "user_id": 1
        },
        {
            "start_timestamp_usec": 1716922983000000,
            "text": "Can you give me more details about the problem with your mobile phone?",
            "role": "HUMAN_AGENT",
            "user_id": 2
        },
        {
            "start_timestamp_usec": 1716922994000000,
            "text": "The mobile phone says that there is an error with the latest update. The mobile phone is stuck on the previous update. The update is not working properly on the mobile phone.",
            "role": "END_USER",
            "user_id": 1
        },
        {
            "start_timestamp_usec": 1716923005000000,
            "text": "And what is the status shown in the settings on the mobile phone?",
            "role": "HUMAN_AGENT",
            "user_id": 2
        },
        {
            "start_timestamp_usec": 1716923016000000,
            "text": "Error: Your account is not authorized to access this resource. Please contact the administrator for assistance.",
            "role": "END_USER",
            "user_id": 1
        },
        {
            "start_timestamp_usec": 1716923027000000,
            "text": "Can you tell me your account number?",
            "role": "HUMAN_AGENT",
            "user_id": 2
        },
        {
            "start_timestamp_usec": 1716923038000000,
            "text": "Sure, it's 700902670",
            "role": "END_USER",
            "user_id": 1
        }]
  },
  "triggerEvents": [
    "MANUAL_CALL"
  ]
}
EOT

curl -X POST \
     -H "Authorization: Bearer $(gcloud auth print-access-token)" \
     -H "x-goog-user-project: ${PROJECT_ID}" \
     -H "Content-Type: application/json; charset=utf-8" \
     -d @/tmp/summarization_custom_generator.json \
     "https://dialogflow.googleapis.com/v2/projects/${PROJECT_ID}/locations/${LOCATION_ID}/statelessSuggestion:generate"

```