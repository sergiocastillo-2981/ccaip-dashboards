# The name of this view in Looker is "V Agent Activity Logs"
view: v_agent_activity_logs {
  label: "Agent Activity"
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `ccaip-reporting-lab.ccaip_ttec_reporting.v_agent_activity_logs`
    ;;
  drill_fields: [id]
  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Activity" in Explore.

  dimension: activity {
    type: string
    sql: ${TABLE}.activity ;;
  }

  dimension: agent_id {
    type: number
    sql: ${TABLE}.agent_id ;;
  }

  dimension: call_id {
    type: number
    sql: ${TABLE}.call_id ;;
  }

  dimension: chat_id {
    type: number
    sql: ${TABLE}.chat_id ;;
  }

  dimension: duration {
    type: number
    sql: ${TABLE}.duration ;;
  }



  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: ended {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.ended_at ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: full_name {
    type: string
    sql: concat(${first_name},' ',${last_name}) ;;
  }

  dimension_group: started {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.started_at ;;
  }

  dimension: status_color {
    type: string
    sql: ${TABLE}.status_color ;;
  }

  dimension: status_id {
    type: number
    sql: ${TABLE}.status_id ;;
  }

  dimension: status_name {
    type: string
    sql: ${TABLE}.status_name ;;
  }

  dimension: status_wfm_id {
    type: number
    sql: ${TABLE}.status_wfm_id ;;
  }

  dimension: whodunnit_agent_number {
    type: number
    sql: ${TABLE}.whodunnit_agent_number ;;
  }

  dimension: whodunnit_avatar_url {
    type: string
    sql: ${TABLE}.whodunnit_avatar_url ;;
  }

  dimension: whodunnit_first_name {
    type: string
    sql: ${TABLE}.whodunnit_first_name ;;
  }

  dimension: whodunnit_id {
    type: number
    sql: ${TABLE}.whodunnit_id ;;
  }

  dimension: whodunnit_last_name {
    type: string
    sql: ${TABLE}.whodunnit_last_name ;;
  }

  dimension: whodunnit_name {
    type: string
    sql: ${TABLE}.whodunnit_name ;;
  }

# A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_duration_ss {
    type: sum
    sql: ${duration} ;;
  }

  measure: total_duration_hhmmss {
    type: number
    sql: ${total_duration_ss}/86400.0 ;;
    value_format: "HH:MM:SS"
  }

  measure: average_duration {
    type: average
    sql: ${duration} ;;
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      status_name,
      whodunnit_name,
      last_name,
      whodunnit_first_name,
      whodunnit_last_name,
      first_name
    ]
  }
}
