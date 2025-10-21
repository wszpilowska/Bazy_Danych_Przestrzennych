\c mapa;

--a
select sum(st_length(geom)) as dlugosc_drog
 from roads;
--b
select
st_astext(geom) as WKT,
st_area(geom) as Powierzchnia,
st_perimeter(geom) as Obwod
from buildings
where name = 'BuildingA';
--c
select name, st_area(geom) as powierzchnia
from buildings
order by name asc;
--d
select name, st_perimeter(geom) as obwod
from buildings
order by st_area(geom) desc
limit 2;
--e
select st_distance(b.geom, p.geom) as najkrotsza_odleglosc
from buildings b, poi p
where b.name = 'BuildingC' and p.name = 'K';
--f
select st_area(
st_difference(
(select geom from buildings where name = 'BuildingC'),
(select st_buffer(geom, 0.5) from buildings where name = 'BuildingB')
    )
) as "pole_powierzchni";
--g
select name from buildings
where st_y(st_centroid(geom)) > 4.5;
--h
select st_area(
st_symdifference(
(select geom from buildings where name = 'BuildingC'),
st_geomfromtext('polygon((4 7, 6 7, 6 8, 4 8, 4 7))')
    )
) as "pole_powierzchni";
