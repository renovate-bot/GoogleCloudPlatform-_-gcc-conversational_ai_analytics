## Handle CCAI Events

*CCAI Insights* can be configured to publish *PubSub* messages when *CCAI Insights* events happen.

[CCAI Insights Pub/Sub documentation](https://cloud.google.com/contact-center/insights/docs/pub-sub)

This module creates a *PubSub* topic and the *Cloud Function* for handling the events.

*IMPORTANT: CCAI Insights* after creating the resources with Terraform, *CCAI Insights* needs to be configured to publish messages in *PubSub*
Example:
```sh
PROJECT_ID="gsd-ccai-insights-offering"
REGION="us-central1"
PUBSUB_TOPIC_NAME="ccai-insights-conversation-uploaded" # this is the PubSub topic name configured in Terraform

cat > /tmp/request.json <<EOL
{
  "pubsub_notification_settings": {
    "upload-conversation": "projects/${PROJECT_ID}/topics/${PUBSUB_TOPIC_NAME}",
    "create-conversation":"projects/${PROJECT_ID}/topics/${PUBSUB_TOPIC_NAME}"
  }
}
EOL

curl -X PATCH \
     -H "Authorization: Bearer $(gcloud auth print-access-token)" \
     -H "Content-Type: application/json; charset=utf-8" \
     -d @/tmp/request.json \
     "https://contactcenterinsights.googleapis.com/v1/projects/${PROJECT_ID}/locations/${REGION}/settings?updateMask=pubsub_notification_settings"
```