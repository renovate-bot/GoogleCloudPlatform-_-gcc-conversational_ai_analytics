view: agent_filter {
  parameter: agent_id_selector {
    type: string
    suggest_dimension: insights_data.agent_id
    suggest_explore: insights_data
  }

  dimension: agent_id_selected {
    type: string
    sql:
    CASE
      WHEN ${insights_data.agent_id} = {% parameter agent_id_selector %} THEN ${insights_data.agent_id}
      ELSE ' All Other Agents'
    END
  ;;
  }

}
