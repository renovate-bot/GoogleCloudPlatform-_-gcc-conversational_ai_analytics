

## Create the CCAI tables

```sql
CREATE TABLE mydataset.export_staging
LIKE mydataset.export
```

Add clustering to the export table by `conversationName`:
```sh
gcloud config set project <your-project-id>
bq update --clustering_fields=conversationName mydataset.export
```