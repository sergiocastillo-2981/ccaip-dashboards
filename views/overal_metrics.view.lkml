view: overal_metrics
{
  derived_table:
  {
    sql:
      SELECT distinct c.id as interaction_id
      ,CAST(c.ends_at AS timestamp) as ended_at
      ,call_type as interaction_type
      ,'call' as interaction_category
      ,agent_info.name as agent_info_name
      ,cast(virtual_agent as string) as virtual_agent_name        --when virtual agent not enabled
      ,c.lang
      ,c.status
      ,c.fail_reason
      ,c.wait_duration
      ,c.queue_duration
      ,ifnull(qd.service_level_event,'not_recorded') service_level_event
      ,c.menu_path.name AS menu_path_name
      ,sum(hd.acw_duration)acw_duration
      ,ifnull( date_diff(CAST(c.ends_at AS timestamp),CAST(c.assigned_at as timestamp), second),0) handle_duration
      FROM `ccaip-reporting-lab.ccaip_laseraway_reporting.t_prev3calls` c
      left JOIN UNNEST (c.queue_durations) AS qd
      left JOIN UNNEST (c.handle_durations) AS hd
      group by
        c.id
        ,c.ends_at
        ,call_type
        ,disconnected_by
        ,agent_info.name
        ,c.lang
        ,cast(virtual_agent as string)
        ,c.status,c.fail_reason,c.fail_details
        ,wait_duration,c.queue_duration,c.call_duration
        ,recording_url
        ,ifnull(qd.service_level_event,'not_recorded')
        ,c.menu_path.name
        ,c.assigned_at
        ,c.connected_at
      union all
      SELECT distinct c.id as interaction_id
      ,CAST(c.ends_at AS timestamp) as ended_at
      ,chat_type as interaction_type
      ,'chat' as interaction_category
      ,agent_info.name as agent_info_name
      ,cast(virtual_agent as string) as virtual_agent_name
      ,c.lang
      ,c.status
      ,c.fail_reason
      ,c.wait_duration
      ,c.queue_duration
      ,ifnull(qd.service_level_event,'not_recorded') service_level_event
      ,c.menu_path.name AS menu_path_name
      ,hd.acw_duration
      ,ifnull( date_diff(CAST(c.ends_at AS timestamp),CAST(c.assigned_at as timestamp), second),0) handle_duration
      FROM `ccaip-reporting-lab.ccaip_laseraway_reporting.t_chats` c
      left JOIN UNNEST (c.queue_durations) AS qd
      left JOIN UNNEST (c.handle_durations) AS hd    ;;
  }

  ####################################################################################
  #####################################   DIMENSIONS   ###############################
  ####################################################################################
  dimension: interaction_id
  {
    description: "Unique ID for each interaction"
    primary_key: yes
    type: number
    sql: ${TABLE}.interaction_id ;;
  }

  dimension_group: interaction
  {
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
    sql: ${TABLE}.ended_at ;;
    #drill_fields: [chat_detail*]
  }

  dimension: interaction_category
  {
    description: "Identifies each interaction as either chat or call"
    type: string
    sql: ${TABLE}.interaction_category ;;
  }

  dimension: interaction_type
  {
    description: "Type on the interaction"
    type: string
    sql: ${TABLE}.interaction_type ;;
  }

  dimension: service_level_event {
    type: string
    sql: ${TABLE}.service_level_event ;;
  }

  dimension: status
  {
    description: "The possible values are: scheduled, queued, assigned, connecting, switching, connected, finished, failed, recovered, deflected, selecting, action_only, action_only_finished, voicemail, voicemail_received, voicemail_read"
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: fail_reason
  {
    description: " Description for a call that ended before successfully connected"
    type: string
    sql:  ${TABLE}.fail_reason ;;

  }

  dimension: handle_duration_ss
  {
    description: "Amount of time that elapsed from when an agent was assigned a call, to when they ended their wrap-up phase"
    group_label: "Durations"
    type: number
    sql: ${TABLE}.handle_duration ;;
  }


  dimension: handle_duration_hhmmss
  {
    description: "Amount of time that elapsed from when an agent was assigned a call, to when they ended their wrap-up phase"
    group_label: "Durations"
    type: number
    sql: ${handle_duration_ss}/86400.0 ;;
    value_format_name: HMS
  }


  ####################################################################################
  ####################################    MEASURES   #################################
  ####################################################################################
  measure: count
  {
    type: count
    #drill_fields: [interaction_detail*]
  }

  measure: call_count
  {
    label: "Total Calls"
    description: "Total number of calls within the selected time frame"
    type: count
    filters: [interaction_category: "call"]
    link:
    {
      label: "Calls Dashboard"
      url: "https://ttec.cloud.looker.com/dashboards/170?Call+Date={{_filters['overal_metrics.interaction_date']|url_encode}}"
    }
  }

  measure: count_in_sla {
    label: "Count In SLA"
    description: "Count of chat queue durations where queued time is less than the SLA threshold"
    type: count
    #drill_fields: [chat_detail*]
    filters: [service_level_event: "in_sla"]
  }

  measure: count_out_sla {
    label: "Count Out SLA"
    description: "Count of call queue durations where queued time is equal to or greater than the SLA threshold."
    type: count
    #drill_fields: [chat_detail*]
    filters: [service_level_event: "not_in_sla"]
  }

  measure: chat_count
  {
    label: "Total Chats"
    description: "Total number of chats within the selected time frame"
    type: count
    filters: [interaction_category: "chat"]
    link:
    {
      label: "Chats Dashboard"
      #url: "https://ttec.cloud.looker.com/dashboards/171?Agent+ID={{ v_agent_activity_logs.agent_id._value }}&Activity+Date={{_filters['v_agent_activity_logs.activity_date']|url_encode}}"
      url: "https://ttec.cloud.looker.com/dashboards/187?Chat+Date={{_filters['overal_metrics.interaction_date']|url_encode}}"
    }
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

  measure: count_handled
  {
    label: "Calls Handled"
    description: "The sum of interactions (call or chat) handled by an agent."
    type: count
    filters: [status: "finished,failed"]
  }

  measure: perc_handled
  {
    label: "Handled %"
    description: "Contacts Handled vs Calls Offered"
    type: number
    sql:  ${count_handled}/${count};;
    value_format_name: percent_2
  }

  measure: count_abandoned
  {
    description: "The sum of calls that were abandoned by the consumer while waiting in queue"
    type: count
    filters: [fail_reason: "eu_abandoned"]
    #drill_fields: [call_detail*,fail_reason,fail_details]
  }

  measure: perc_abandoned
  {
    label: "Abandoned %"
    description: "Contacts Abandoned vs Calls Offered"
    type: number
    sql:  ${count_abandoned}/${count};;
    value_format_name: percent_2
  }

  measure: avg_handle_duration_hhmmss
  {
    label: "Avg Handle Time HH:MM:SS"
    type: average
    sql: ${handle_duration_hhmmss} ;;
    value_format_name: HMS
  }

}
