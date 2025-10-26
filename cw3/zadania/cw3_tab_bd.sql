\c karlsruhe;

--3
create table streets_reprojected as
select gid,st_name,st_transform(geom, 3068) as geom
from t2019_kar_streets;
--4
create table input_points(
    gid int primary key,
    geom geometry(point, 4326)
);

insert into input_points (gid, geom) values
(1, st_setsrid(st_makepoint(8.36093, 49.03174), 4326)),
(2, st_setsrid(st_makepoint(8.39876, 49.00644), 4326));

--5
alter table input_points
alter column geom type geometry(Point, 3068)
using st_transform(geom, 3068);

--6
with input_line as (select st_makeLine(geom order by gid) as geom
from input_points
)
select s.*
from t2019_kar_street_node as s
join input_line as l
on st_dwithin(st_transform(s.geom, 3068),l.geom,200);

--7
select count(distinct poi.gid) as ilosc_sklepow
from t2019_kar_poi_table as poi
join t2019_kar_land_use_a as park
on st_dwithin(st_transform(poi.geom, 3068),st_transform(park.geom, 3068),
300
)
where poi.type = 'Sporting Goods Store';


