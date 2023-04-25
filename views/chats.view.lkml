view: chats {
  label: "Chats"
   derived_table: {
     sql:
        SELECT distinct c.id as chat_id
          ,CAST(c.ends_at AS timestamp) as chat_ends_at
          ,c.lang
          ,chat_type
          ,c.status
          ,c.fail_reason
          ,agent_info.name as agent_name
          ,c.queue_duration
          ,qd.service_level_event
          ,c.menu_path.name AS menu_path_name
          ,hd.acw_duration
          ,ifnull( date_diff(CAST(c.ends_at AS timestamp),CAST(c.assigned_at as timestamp), second),0) handle_duration
          FROM `ccaip-reporting-lab.ccaip_laseraway_reporting.t_chats` c
          left JOIN UNNEST (c.queue_durations) AS qd
          left JOIN UNNEST (c.handle_durations) AS hd ;;
    }

  ####################################################################################
  #####################################   DIMENSIONS   ###############################
  ####################################################################################
  dimension: chat_id {
    description: "Unique ID for each call"
    primary_key: yes
    type: number
    sql: ${TABLE}.chat_id ;;
  }

  dimension_group: chat {
    type: time
    timeframes: [
      raw,
      time,
      date,
      hour_of_day,
      day_of_week,
      day_of_week_index,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.chat_ends_at ;;
    drill_fields: [chat_detail*]
  }

  dimension: chat_type {
    type: string
    sql: ${TABLE}.chat_type ;;
  }

  dimension: chat_language {
    type: string
    sql: ${TABLE}.lang ;;
  }

  dimension: agent_name {
    type: string
    sql: ${TABLE}.agent_name ;;
  }

  dimension: service_level_event {
    type: string
    sql: ${TABLE}.service_level_event ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: menu_path {
    type: string
    sql: ${TABLE}.menu_path_name ;;
  }

  dimension: queue_time_ss {
    type: number
    sql: ${TABLE}.queue_duration ;;
  }

  dimension: queue_time_hhmmss {
    type: number
    sql: ${queue_time_ss}/86400.0 ;;
    #value_format: "HH:MM:SS"
    value_format_name: HMS
  }

  #dimension: talk_duration_ss {
  #  description: "The total time that the Agent spent talking to a consumer in Seconds"
  #  type: number
  #  sql: ${TABLE}.talk_duration ;;
  #}

  #dimension: talk_duration_hhmmss {
  #  description: "The total time that the Agent spent talking to a consumer in HH:MM:SS"
  #  type: number
  #  sql: ${talk_duration_ss}/86400.0 ;;
  #  value_format_name: HMS
  #}

  dimension: in_sla {
    type: number
    sql: case when ${service_level_event} = 'in_sla' then 1 else 0 end  ;;
  }

  dimension: out_sla {
    type: number
    sql: case when ${service_level_event} = 'not_in_sla' then 1 else 0 end  ;;
  }

  ####################################################################################
  ####################################    MEASURES   #################################
  ####################################################################################
  measure: count {
    type: count
    drill_fields: [chat_detail*]
  }

  #####################################################################################
  ####################################  DRILL FIELDS  #################################
  #####################################################################################
  set: chat_detail {
    fields: [
      chat_id,
      chat_date,
      agent_name,
      chat_type
    ]
  }

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
