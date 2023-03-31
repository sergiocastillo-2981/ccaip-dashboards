view: v_calls {
  label: "Calls"
  # This is the table we will use in prod
  # sql_table_name: `ccaip-reporting-lab.ccaip_ttec_reporting.v_calls` ;;


 # Using Derived Table as temporary while the data gets cleaned
   derived_table: {
     sql: SELECT distinct call_id,call_ends_at,call_type,disconnected_by
          ,agent_info_name,photos_id,wait_duration,queue_duration,call_duration,recording_url
          ,service_level_event,menu_path_name ,bcw_duration
          ,acw_duration
          FROM `ccaip-reporting-lab.ccaip_ttec_reporting.v_calls`
       ;;
   }

  #DIMENSIONS
   dimension: call_id {
     description: "Unique ID for each call"
      primary_key: yes
     type: number
     sql: ${TABLE}.call_id ;;
   }

  dimension_group: call {
    type: time
    timeframes: [
      raw,
      time,
      date,
      hour_of_day,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.call_ends_at ;;
    drill_fields: [call_detail*]
  }

  dimension: call_type {
    type: string
    sql: ${TABLE}.call_type ;;
  }

  dimension: disconnected_by {
    type: string
    sql:  INITCAP(SUBSTR(${TABLE}.disconnected_by, 17))   ;;
  }

  dimension: agent_name {
    type: string
    sql: ${TABLE}.agent_info_name ;;
  }

  dimension: menu_path {
    type: string
    sql: ${TABLE}.menu_path_name ;;
  }

  dimension: recording_url {
    sql: ${TABLE}.recording_url ;;
    link: {
      label: "Recording URL"
      url: "{{value}}"
      icon_url: "https://t2.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL"
    }
  }

  dimension: acw_duration_ss {
    type: number
    sql: ${TABLE}.acw_duration ;;
  }

  dimension: acw_duration_hhmmss {
    type: number
    sql: ${acw_duration_ss}/86400.0 ;;
    value_format_name: HMS
  }

  dimension: bcw_duration_ss {
    type: number
    sql: ${TABLE}.bcw_duration ;;
  }

  dimension: bcw_duration_hhmmss {
    type: number
    sql: ${bcw_duration_ss}/86400.0 ;;
    value_format_name: HMS
  }

  dimension: handle_duration_ss {
    type: number
    sql: ${bcw_duration_ss}+${acw_duration_ss} ;;
  }

  dimension: handle_duration_hhmmss {
    description: "Amount of time that elapsed from when an agent accepts a call, to when they end their wrap-up phase"
    type: number
    sql: ${bcw_duration_hhmmss}+${acw_duration_hhmmss} ;;
    value_format_name: HMS
  }


  dimension: call_duration_ss {
    type: number
    sql: ${TABLE}.call_duration ;;
  }

  dimension: call_duration_hhmmss {
    type: number
    sql: ${call_duration_ss}/86400.0 ;;
    value_format_name: HMS
  }

  dimension: queue_duration_ss {
    type: number
    sql: ${TABLE}.queue_duration ;;
  }

  dimension: queue_duration_hhmmss {
    type: number
    sql: ${queue_duration_ss}/86400.0 ;;
     #value_format: "HH:MM:SS"
    value_format_name: HMS
  }

  dimension: wait_duration_ss {
    type: number
    sql: ${TABLE}.wait_duration ;;
  }

  dimension: wait_duration_hhmmss {
    type: number
    sql: ${wait_duration_ss}/86400.0 ;;
     #value_format: "HH:MM:SS"
    value_format_name: HMS
  }

  dimension: service_level_event {
    type: string
    sql: ${TABLE}.service_level_event ;;
  }

  dimension: in_sla {
    type: number
   sql: case when ${service_level_event} = 'in_sla' then 1 else 0 end  ;;
  }

  dimension: out_sla {
    type: number
    sql: case when ${service_level_event} = 'not_in_sla' then 1 else 0 end  ;;
  }


  #############################################    MEASURES  ############################
  measure: count {
    type: count
    drill_fields: [call_detail*]
  }

  measure: sum_call_duration_ss {
    type: sum
    sql: ${call_duration_ss} ;;
  }

  measure: sum_call_duration_hhmmss {
    type: sum
    sql:  ${call_duration_hhmmss} ;;
     #value_format: "HH:MM:SS"
    value_format_name: HMS
  }

  measure: percent_of_total {
    type: percent_of_total
    sql: ${count} ;;
  }

  measure: count_in_sla {
    description: "Count of chat queue durations where queued time is less than the SLA threshold"
    type: sum
    sql: ${in_sla} ;;

  }

  measure: count_out_sla {
    description: "Count of call queue durations where queued time is equal to or greater than the SLA threshold."
    type: sum
    sql: ${out_sla} ;;

  }

  measure: perc_in_sla {
    label: "SLA %"
    type: number
    sql: ${count_in_sla} / ${count} ;;
    value_format_name: percent_2
  }

  measure: max_queue_duration_hhmmss {
    label: "Max Queue Time HH:MM:SS"
    type: max
    sql: ${queue_duration_hhmmss} ;;
    value_format_name: HMS
  }

  measure: avg_queue_duration_hhmmss {
    label: "Avg Queue Time"
    type: average
    sql: ${queue_duration_hhmmss} ;;
    value_format_name: HMS
  }


  measure: avg_queue_duration_ss {
    label: "Avg Queue Time Seconds"
    type: average
    sql: ${queue_duration_ss} ;;
  }

  measure: total_queue_duration_hhmmss {
    label: "Total Queue Time"
    type: sum
    sql: ${queue_duration_hhmmss} ;;
    value_format_name: HMS
  }

  measure: avg_handle_duration_hhmmss {
    label: "Avg Handle Time HH:MM:SS"
    type: average
    sql: ${handle_duration_hhmmss} ;;
    value_format_name: HMS
  }


# ----- Sets of fields for drilling ------
  set: call_detail {
    fields: [
      call_id,
      call_date,
      agent_name,
      call_type
    ]
  }



  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}


#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
