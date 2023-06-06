# Define the database connection to be used for this model.
connection: "ccaip_lab"

# include all the views
include: "/views/**/*.view"

# Datagroups define a caching policy for an Explore. To learn more,
# use the Quick Help panel on the right to see documentation.

datagroup: ccaip_dashboards_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: ccaip_dashboards_default_datagroup

# Explores allow you to join together different views (database tables) based on the
# relationships between fields. By joining a view into an Explore, you make those
# fields available to users for data analysis.
# Explores should be purpose-built for specific use cases.

# To see the Explore you’re building, navigate to the Explore menu and select an Explore under "Ccaip-dashboards"



explore: v_agent_activity_logs{
  label: "Agent Activity"
}

explore: v_calls{
  label: "Calls"
}

explore: chats {
  label: "Chats"
}

explore: overal_metrics {
  label: "Overal Metrics"
}

#explore: agent_performance
#{
#  from: v_calls
#  join: v_agent_activity_logs
#  {
#    type: left_outer
#    sql_on: ${agent_performance.agent_id} = $(v_agent_activity_logs.agent_id) ;;
#    relationship: one_to_many
#  }
#}


named_value_format:HMS{
  value_format: "HH:MM:SS"
}
