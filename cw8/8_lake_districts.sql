CREATE TABLE uk_lake_district AS
    SELECT
        ST_Clip(r.rast,p.geom,true) AS rast
FROM
    uk_250k_2 AS r ,
    national_parks_cliped AS p
WHERE
    p.id = 1
    AND ST_Intersects(r.rast,p.geom);

CREATE TABLE sentinel_green_clip AS
SELECT
    ST_Clip(r.rast, ST_Transform(p.geom, ST_SRID(r.rast)), true) AS rast
FROM
    sentinel_green r,
    national_parks p
WHERE
    p.id = 1
    AND ST_Intersects(r.rast, ST_Transform(p.geom, ST_SRID(r.rast)));


SELECT AddRasterConstraints('sentinel_green_clip', 'rast');
CREATE INDEX sentinel_green_clip_idx ON sentinel_green_clip USING GIST (ST_ConvexHull(rast));


CREATE TABLE sentinel_nir_clip AS
SELECT
    ST_Clip(r.rast, ST_Transform(p.geom, ST_SRID(r.rast)), true) AS rast
FROM
    sentinel_nir r, -- Twoja tabela z zielenią
    national_parks p
WHERE
    p.id = 1
    AND ST_Intersects(r.rast, ST_Transform(p.geom, ST_SRID(r.rast)));


SELECT AddRasterConstraints('sentinel_nir_clip', 'rast');
CREATE INDEX sentinel_nir_clip_idx ON sentinel_nir_clip USING GIST (ST_ConvexHull(rast));




CREATE TABLE lake_district_ndwi_v2 AS
SELECT

    ST_SetSRID(
        ST_MapAlgebra(
            a.rast,
            b.rast,
            '([rast1] - [rast2]) / NULLIF([rast1] + [rast2], 0)::float'
        ),
        ST_SRID(a.rast) -- Pobieramy ID układu z pliku wejściowego
    ) AS rast
FROM
    sentinel_green_clip a,
    sentinel_nir  b
WHERE
    ST_Intersects(a.rast, b.rast);


SELECT AddRasterConstraints('lake_district_ndwi_v2', 'rast');

--sprawdzenie
select count(*) from lake_district_ndwi_v2;