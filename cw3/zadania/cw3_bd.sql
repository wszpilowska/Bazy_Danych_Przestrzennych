
--1
select b2019.*
from t2019_kar_buildings as b2019
left join t2018_kar_buildings as b2018
on st_equals(b2019.geom, b2018.geom)
where b2018.geom is null;

with new_buildings as (
    select b2019.*
    from t2019_kar_buildings as b2019
    left join t2018_kar_buildings as b2018
    on st_equals(b2019.geom, b2018.geom)
    where b2018.geom is null
),
--2
new_poi as (
    select poi2019.*
    from t2019_kar_poi_table as poi2019
    left join t2018_kar_poi_table as poi2018
    on st_equals(poi2019.geom, poi2018.geom)
    where poi2018.geom is null
)
select np.type, count(*) as nowe_poi
from new_poi as np
join new_buildings as nb
on st_dwithin(np.geom, nb.geom, 500)
group by np.type
order by nowe_poi desc;



