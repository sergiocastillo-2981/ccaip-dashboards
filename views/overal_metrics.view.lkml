 view: overal_metrics
{
   derived_table:
  {
     sql: SELECT distinct c.id as interaction_id
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
          ,qd.service_level_event
          ,c.menu_path.name AS menu_path_name
          ,hd.acw_duration
          ,ifnull( date_diff(CAST(c.ends_at AS timestamp),CAST(c.assigned_at as timestamp), second),0) handle_duration
          FROM `ccaip-reporting-lab.ccaip_laseraway_reporting.t_calls` c
          left JOIN UNNEST (c.queue_durations) AS qd
          left JOIN UNNEST (c.handle_durations) AS hd
          left join UNNEST (c.participants) pa on pa.type != 'end_user'
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
          ,qd.service_level_event
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

  dimension: interaction_category
  {
    description: "Identifies each interaction as either chat or call"
    type: string
    sql: ${TABLE}.interaction_category ;;
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
      label: "Recording URL"
      url: "https://ttec.cloud.looker.com/dashboards/170"
    }
  }

  measure: chat_count
  {
    label: "Total Calls"
    description: "Total number of calls within the selected time frame"
    type: count
    filters: [interaction_category: "chat"]
    link:
    {
      label: "Recording URL"
      url: "https://ttec.cloud.looker.com/dashboards/187"
    }
  }
}