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
          ,qd.transfer
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

  dimension: transfer {
    type: yesno
    sql: ${TABLE}.transfer ;;
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


  measure: count_in_sla {
    label: "Count In SLA"
    description: "Count of chat queue durations where queued time is less than the SLA threshold"
    type: count
    drill_fields: [chat_detail*]
    filters: [service_level_event: "in_sla"]
  }

  measure: count_out_sla {
    label: "Count Out SLA"
    description: "Count of call queue durations where queued time is equal to or greater than the SLA threshold."
    type: count
    drill_fields: [chat_detail*]
    filters: [service_level_event: "not_in_sla"]
  }

  measure: count_non_sla {
    label: "Count Non SLA"
    description: "Count of calls that didnt get SLA recorded"
    type: count
    filters: [service_level_event: "-in_sla,-not_in_sla"]
    drill_fields: [chat_detail*]
  }

  measure: perc_in_sla
  {
    label: "SLA %"
    description: "Count of chats In SLA /(Count of chats  In SLA + count of chats Out SLA"
    type: number
    #sql: ${count_in_sla} / ${count} ;;
    sql: case when (${count_in_sla} + ${count_out_sla}) = 0 then 0 else ${count_in_sla} / (${count_in_sla} + ${count_out_sla}) end;;
    value_format_name: percent_2
  }

  measure: perc_in_sla_numeric
  {
    label: "SLA Numeric%"
    description: "Count of chats In SLA /(Count of chats  In SLA + count of chats Out SLA"
    type: number
    #sql: ${count_in_sla} / ${count} ;;
    sql: case when (${count_in_sla} + ${count_out_sla}) = 0 then 0 else (${count_in_sla} / (${count_in_sla} + ${count_out_sla}) )*100.0 end;;

  }


  measure: num_transfers
  {
    label: "Transfers"
    description: "Total Number of Transfers "
    type: count
    filters: [transfer: "Yes"]
    #drill_fields: [transfer_type,agent_id]
    value_format_name: decimal_0
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
