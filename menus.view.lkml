view: menus
{
  derived_table:
  {
     sql:
        with recursive hierarchy as (

        select id,name,parent_id,cast(null as string) as parent_name,0 as level
        from `ccaip-reporting-lab.ccaip_laseraway_reporting.t_menus`
        where parent_id is null
        union all
        select m.id,m.name,m.parent_id,h.name parent_name,level + 1 as level
        from  `ccaip-reporting-lab.ccaip_laseraway_reporting.t_menus` m
        inner join  hierarchy h on m.parent_id = h.id
      ),
       hch as (
      select * from hierarchy
      --where id = 36
      order by parent_id,id
      )
      select * from hch join hierarchy h on hch.parent_id = h.id       ;;
  }
}
