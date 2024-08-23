# CCAI Insights Looker Dashboards

## Overview

This CCAI Insights Looker Block uses the BQ export to provide a more holistic view of the business's call center and agent performance via the following dashboards:
Call Center Performance: Executive dashboard displaying high-level metrics intended for call center management. 
Agent Performance: Performance metrics for an individual agent, linked from the Agent ID dimension.
Agent Operations: Performance metrics for agents in aggregate.
Conversation Lookup Dashboard: Detailed transcript and sentiment analysis for an individual conversation, linked from the Conversation Name dimension.

## Instructions

1. Copy each of the folders and files into a new LookML Project
2. Replace the model file connection string with your db connection
3. Find and replace all instances of "insights_demo.insights_export" with your Insight's export "dataset.table"

## Documentation
[BQ Schema](https://cloud.google.com/contact-center/insights/docs/bigquery-all-schemas)
