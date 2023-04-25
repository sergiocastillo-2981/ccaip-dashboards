view: v_calls {
  label: "Calls"
  # This is the table we will use in prod
  # sql_table_name: `ccaip-reporting-lab.ccaip_ttec_reporting.v_calls` ;;


 # Using Derived Table as temporary while the data gets cleaned
   derived_table: {
    #sql: SELECT distinct call_id,call_ends_at,call_type,disconnected_by
    #    ,agent_info_name,photos_id,wait_duration,queue_duration,call_duration,recording_url
    #    ,service_level_event,menu_path_name ,bcw_duration
    #    ,acw_duration
    #    FROM `ccaip-reporting-lab.ccaip_ttec_reporting.v_calls`
    # ;;
    sql: SELECT distinct c.id as call_id,CAST(c.ends_at AS timestamp) as call_ends_at,call_type
          ,disconnected_by
          ,agent_info.name as agent_info_name
          ,virtual_agent.name as virtual_agent_name
          ,c.status
          ,wait_duration,c.queue_duration,c.call_duration
          ,recording_url
          ,qd.service_level_event
          ,c.menu_path.name AS menu_path_name
          ,hd.bcw_duration
          ,hd.acw_duration
          ,ifnull( date_diff(CAST(c.ends_at AS timestamp),CAST(c.assigned_at as timestamp), second),0) handle_duration
          ,ifnull( date_diff(CAST(c.ends_at AS timestamp),CAST(c.connected_at as timestamp), second),0) talk_duration
          ,pa.type as participant_type
          FROM `ccaip-reporting-lab.ccaip_ttec_reporting.t_calls` c
          left JOIN UNNEST (c.photos) AS p
          left JOIN UNNEST (c.queue_durations) AS qd
          left JOIN UNNEST (c.handle_durations) AS hd
          left join UNNEST (c.participants) pa
          where pa.type != 'end_user'
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
      day_of_week,
      day_of_week_index,
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
    description: "Amount of time that elapsed from when an agent was assigned a call, to when they ended their wrap-up phase"
    type: number
    sql: ${TABLE}.handle_duration ;;
  }

  dimension: handle_duration_hhmmss {
    description: "Amount of time that elapsed from when an agent was assigned a call, to when they ended their wrap-up phase"
    type: number
    sql: ${handle_duration_ss}/86400.0 ;;
    value_format_name: HMS
  }

  #dimension: call_duration_ss {
  #  description: "Deprecated, use Handle Duration Instead"
  #  type: number
  #  sql: ${TABLE}.call_duration ;;
  #}

  #dimension: call_duration_hhmmss {
  #  description: "Deprecated, use Handle Duration Instead"
  #  type: number
  #  sql: ${call_duration_ss}/86400.0 ;;
  #  value_format_name: HMS
  #}

  dimension: talk_duration_ss {
    description: "The total time that the Agent spent talking to a consumer in Seconds"
    type: number
    sql: ${TABLE}.talk_duration ;;
  }

  dimension: talk_duration_hhmmss {
    description: "The total time that the Agent spent talking to a consumer in HH:MM:SS"
    type: number
    sql: ${talk_duration_ss}/86400.0 ;;
    value_format_name: HMS
  }

  dimension: queue_duration_ss {
    type: number
    sql: ${TABLE}.queue_duration ;;
  }

  dimension: queue_duration_hhmmss {
    type: number
    sql: ${queue_duration_ss}/86400.0 ;;
    value_format_name: HMS
  }

  dimension: wait_duration_ss {
    description: "Deprecated, use queue_duration instead"
    type: number
    sql: ${TABLE}.wait_duration ;;
  }

  dimension: wait_duration_hhmmss {
    description: "Deprecated, use queue_duration instead"
    type: number
    sql: ${wait_duration_ss}/86400.0 ;;
     #value_format: "HH:MM:SS"
    value_format_name: HMS
  }

  dimension: service_level_event {
    type: string
    sql: ${TABLE}.service_level_event ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: in_sla {
    type: number
    sql: case when ${service_level_event} = 'in_sla' then 1 else 0 end  ;;
  }

  dimension: out_sla {
    type: number
    sql: case when ${service_level_event} = 'not_in_sla' then 1 else 0 end  ;;
  }

  dimension: agent_type {
    type: string
    sql: ${TABLE}.participant_type  ;;
  }

  dimension: agent_name {
    type: string
    sql: case when ${agent_type} = 'agent' then ${TABLE}.agent_info_name when ${agent_type} = 'virtual_agent' then ${TABLE}.virtual_agent_name end ;;
  }

  ##########################################################################################
  #############################################    MEASURES  ############################
  ##########################################################################################
  measure: count {
    type: count
    drill_fields: [call_detail*]
  }

  #measure: sum_call_duration_ss {
  #  description: "Deprecated, use Handle Duration instead"
  #  type: sum
  #  sql: ${call_duration_ss} ;;
  #}

  #measure: sum_call_duration_hhmmss {
  #  description: "Deprecated, use Handle Duration instead"
  #  type: sum
  #  sql:  ${call_duration_hhmmss} ;;
  #   #value_format: "HH:MM:SS"
  #  value_format_name: HMS
  #}


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
    #sql: ${count_in_sla} / ${count} ;;
    sql: ${count_in_sla} / (${count_in_sla} + ${count_out_sla});;
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

  measure: count_handled {
    label: "Calls Handled"
    description: "The sum of interactions (call or chat) handled by an agent."
    type: count
    filters: [status: "finished,failed"]
  }

  measure: perc_handled {
    label: "Handled %"
    description: "Calls Handled vs Calls Offered"
    type: number
    sql:  ${count_handled}/${count};;
    value_format_name: percent_2
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

  measure: total_handle_duration_hhmmss {
    label: "Total Handle Time HH:MM:SS"
    type: sum
    sql: ${handle_duration_hhmmss} ;;
    value_format_name: HMS
  }

  measure: total_wrapup_time_hhmmss {
    label: "Wrapup Time HH:MM:SS"
    type: sum
    sql: ${acw_duration_hhmmss} ;;
    value_format_name: HMS

  }


# ----- Sets of fields for drilling ------
  set: call_detail {
    fields: [
      call_id,
      call_date,
      agent_type,
      agent_name,
      call_type
    ]
  }



}
