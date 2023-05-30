view: menu_tree
{

  derived_table:
  {
     sql: SELECT
          m.id,
          m.name,
          m.parent_id,
          m.position,
          m.menu_type,
          children.id l1_id,
          children.name l1_name,
          children.parent_id,
          level2children.id l2_id,
          level2children.name l2 name,
          level2children.parent_id,
          level3children.id l3_id,
          level3children.name l3_name,
          level3children.parent_id,
          concat(children.name,'/',level2children.name,'/',level3children.name) as Full_path
        FROM
          `ccaip-reporting-lab.ccaip_laseraway_reporting.t_menus_tree` m
        LEFT JOIN
          UNNEST (m.children) children
        LEFT JOIN
          UNNEST (children.children) level2children
        LEFT JOIN
          UNNEST (level2children.children) level3children  ;;
  }
  dimension: menu_id
  {
    type: number
    sql:  ${TABLE}.id;;
  }
  dimension: menu_name
  {
    type: number
    sql:  ${TABLE}.name;;
  }

  dimension: menu_l1_id
  {
    type: number
    sql:  ${TABLE}.l1_id;;
  }
  dimension: menu_l1_name
  {
    type: number
    sql:  ${TABLE}.l1_name;;
  }



}
