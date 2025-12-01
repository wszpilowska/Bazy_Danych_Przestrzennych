
--Przykład 1 - ST_Intersects Przecięcie rastra z wektorem.
CREATE TABLE szpilowska.intersects AS
SELECT a.rast, b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';

ALTER TABLE szpilowska.intersects
ADD COLUMN rid SERIAL PRIMARY KEY;

CREATE INDEX idx_intersects_rast_gist ON szpilowska.intersects
USING gist (ST_ConvexHull(rast));


SELECT AddRasterConstraints('szpilowska'::name,
'intersects'::name,'rast'::name);


-- 2 Obcinanie rastra na podstawie wektora.
CREATE TABLE szpilowska.clip AS
SELECT ST_Clip(a.rast, b.geom, true) AS rast, b.municipality AS municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality like 'PORTO';

-- Dodanie klucza głównego
ALTER TABLE szpilowska.clip
ADD COLUMN rid SERIAL PRIMARY KEY;
-- Utworzenie indeksu przestrzennego
CREATE INDEX idx_clip_rast_gist ON szpilowska.clip
USING gist (ST_ConvexHull(rast));
-- Dodanie ograniczeń rastrowych
SELECT AddRasterConstraints('szpilowska'::name,
'clip'::name,'rast'::name);

--3 Połączenie wielu kafelków w jeden raster.
CREATE TABLE szpilowska.union AS
SELECT ST_Union(ST_Clip(a.rast, b.geom, true)) AS rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' AND ST_Intersects(b.geom,a.rast);

-- Dodanie klucza głównego
ALTER TABLE szpilowska.union
ADD COLUMN rid SERIAL PRIMARY KEY;
-- Utworzenie indeksu przestrzennego
CREATE INDEX idx_union_rast_gist ON szpilowska.union
USING gist (ST_ConvexHull(rast));
-- Dodanie ograniczeń rastrowych
SELECT AddRasterConstraints('szpilowska'::name,
'union'::name,'rast'::name);

----------------------------------------------
--Tworzenie rastrów z wektorów (rastrowanie)--
----------------------------------------------

-- Przykład pokazuje użycie funkcji ST_AsRaster w celu rastrowania tabeli z parafiami o takiej samej charakterystyce przestrzennej
CREATE TABLE szpilowska.porto_parishes_raster AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1
)
SELECT ST_AsRaster(a.geom, r.rast, '8BUI', a.id, -32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

-- Dodanie klucza głównego
ALTER TABLE szpilowska.porto_parishes_raster
ADD COLUMN rid SERIAL PRIMARY KEY;
-- Utworzenie indeksu przestrzennego
CREATE INDEX idx_parishes_raster_gist ON szpilowska.porto_parishes_raster
USING gist (ST_ConvexHull(rast));
-- Dodanie ograniczeń rastrowych
SELECT AddRasterConstraints('szpilowska'::name,
'porto_parishes_raster'::name, 'rast'::name);

--łączy rekordy z poprzedniego przykładu przy użyciu funkcji ST_UNION w pojedynczy raster
CREATE TABLE szpilowska.porto_parishes_union AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1
)
SELECT st_union(ST_AsRaster(a.geom, r.rast, '8BUI', a.id, -32767)) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

-- Dodanie klucza głównego
ALTER TABLE szpilowska.porto_parishes_union
ADD COLUMN rid SERIAL PRIMARY KEY;
-- Utworzenie indeksu przestrzennego
CREATE INDEX idx_parishes_union_rast_gist ON szpilowska.porto_parishes_union
USING gist (ST_ConvexHull(rast));
-- Dodanie ograniczeń rastrowych
SELECT AddRasterConstraints('szpilowska'::name,
'porto_parishes_union'::name, 'rast'::name);

--generowanie kafelkow za pomocą funkcji ST_Tile

DROP TABLE IF EXISTS szpilowska.porto_parishes_tiled;

CREATE TABLE szpilowska.porto_parishes_tiled AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1
)
SELECT st_tile(st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id, -32767)), 128, 128, true, -32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

-- Dodanie klucza głównego
ALTER TABLE szpilowska.porto_parishes_tiled
ADD COLUMN rid SERIAL PRIMARY KEY;
-- Utworzenie indeksu przestrzennego
CREATE INDEX idx_parishes_tiled_rast_gist ON szpilowska.porto_parishes_tiled
USING gist (ST_ConvexHull(rast));
-- Dodanie ograniczeń rastrowych
SELECT AddRasterConstraints('szpilowska'::name,
'porto_parishes_tiled'::name, 'rast'::name);

-----------------------------------------------------
--Konwertowanie rastrów na wektory (wektoryzowanie)--
-----------------------------------------------------

--Przykład 1 - ST_Intersection
CREATE TABLE szpilowska.intersection AS
SELECT
a.rid,
(ST_Intersection(b.geom, a.rast)).geom,
(ST_Intersection(b.geom, a.rast)).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' AND ST_Intersects(b.geom, a.rast);

--Przykład 2 - ST_DumpAsPolygons ST_DumpAsPolygons konwertuje rastry w wektory (poligony).

CREATE TABLE szpilowska.dumppolygons AS
SELECT
a.rid,
(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).geom,
(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' AND ST_Intersects(b.geom,a.rast);

-- Utworzenie indeksu przestrzennego na nowej geometrii
CREATE INDEX idx_dumppolygons_geom_gist ON szpilowska.dumppolygons
USING gist (geom);

-------------------
--Analiza rastrow--
-------------------


--Funkcja ST_Band służy do wyodrębniania pasm z rastra
CREATE TABLE szpilowska.landsat_nir AS
SELECT rid, ST_Band(rast, 4) AS rast
FROM rasters.landsat8;
--ST_Clip może być użyty do wycięcia rastra z innego rastra.
CREATE TABLE szpilowska.paranhos_dem AS
SELECT a.rid, ST_Clip(a.rast, b.geom, true) AS rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' AND ST_Intersects(b.geom, a.rast);

--Poniższy przykład użycia funkcji ST_Slope wygeneruje nachylenie przy użyciu poprzednio wygenerowanej tabeli (wzniesienie).
CREATE TABLE szpilowska.paranhos_slope AS
SELECT a.rid, ST_Slope(a.rast, 1, '32BF', 'PERCENTAGE') AS rast
FROM szpilowska.paranhos_dem AS a;

--Aby zreklasyfikować raster należy użyć funkcji ST_Reclass.
CREATE TABLE szpilowska.paranhos_slope_reclass AS
SELECT a.rid, ST_Reclass(a.rast, 1, ']0-15]:1, (15-30]:2, (30-9999:3', '32BF', 0) AS rast
FROM szpilowska.paranhos_slope AS a;

-- Przy użyciu UNION można wygenerować jedną statystykę wybranego rastra
SELECT st_summarystats(ST_Union(a.rast)) AS total_stats
FROM szpilowska.paranhos_dem AS a;
-- ST_SummaryStats z lepszą kontrolą złożonego typu danych
WITH t AS (
    SELECT st_summarystats(ST_Union(a.rast)) AS stats
    FROM szpilowska.paranhos_dem AS a
)
SELECT (stats).min, (stats).max, (stats).mean FROM t;
-- ST_SummaryStats w połączeniu z GROUP BY
WITH t AS (
    SELECT b.parish AS parish,
           st_summarystats(ST_Union(ST_Clip(a.rast, b.geom, true))) AS stats
    FROM rasters.dem AS a, vectors.porto_parishes AS b
    WHERE b.municipality ilike 'porto' AND ST_Intersects(b.geom, a.rast)
    GROUP BY b.parish
)
SELECT parish, (stats).min, (stats).max, (stats).mean FROM t;

-- Aby obliczyć statystyki rastra, można użyć funkcji ST_SummaryStats
SELECT st_summarystats(a.rast) AS stats
FROM szpilowska.paranhos_dem AS a
LIMIT 1; -- Zwykle wystarczy pobrać statystyki dla jednego rekordu, jeśli tabela ma wiele kafelków.

-- st_value
SELECT
    b.name,
    st_value(a.rast, (ST_Dump(b.geom)).geom) AS elevation
FROM
    rasters.dem a,
    vectors.places AS b
WHERE
    ST_Intersects(a.rast, b.geom)
ORDER BY
    b.name;

--------
--TPI--
-------

BEGIN;

DROP TABLE IF EXISTS szpilowska.tpi30;

CREATE TABLE szpilowska.tpi30 AS
SELECT ST_TPI(a.rast, 1) AS rast
FROM rasters.dem a;

-- Optymalizacja TPI (cały obszar)
ALTER TABLE szpilowska.tpi30 ADD COLUMN rid SERIAL PRIMARY KEY;
CREATE INDEX idx_tpi30_rast_gist ON szpilowska.tpi30
USING gist (ST_ConvexHull(rast));
SELECT AddRasterConstraints('szpilowska'::name,
'tpi30'::name, 'rast'::name);

-- -----------------------------------------------------------
-- 2. Obliczenie TPI ZOPTYMALIZOWANE-- Oblicza TPI tylko dla gminy Porto
-- -----------------------------------------------------------
DROP TABLE IF EXISTS szpilowska.porto_tpi30;

CREATE TABLE szpilowska.porto_tpi30 AS
SELECT ST_TPI(a.rast, 1) AS rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom)
  AND b.municipality ilike 'porto';

-- Optymalizacja TPI (Porto)
ALTER TABLE szpilowska.porto_tpi30 ADD COLUMN rid SERIAL PRIMARY KEY;
CREATE INDEX idx_porto_tpi30_rast_gist ON szpilowska.porto_tpi30
USING gist (ST_ConvexHull(rast));
SELECT AddRasterConstraints('szpilowska'::name,
'porto_tpi30'::name, 'rast'::name);

COMMIT;


---------------
--algebra map--
---------------

--Przykład 1 - Wyrażenie Algebry Map
BEGIN;

DROP TABLE IF EXISTS szpilowska.porto_ndvi;

-- tworzenie tabeli NDVI ST_MapAlgebra Expression
--  filtrowanie i przycinanie kafelkow Landsat8 do granic gminy Porto
-- ST_MapAlgebra oblicza wzór NDVI (NIR - Red) / (NIR + Red)

CREATE TABLE szpilowska.porto_ndvi AS
WITH r AS (
    -- Przyciecie Landsat8 do granic Porto
    SELECT a.rid, ST_Clip(a.rast, b.geom, true) AS rast
    FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
    WHERE b.municipality ilike 'porto' AND ST_Intersects(b.geom,a.rast)
)
SELECT
    r.rid,
    ST_MapAlgebra(
        r.rast, 1,
        r.rast, 4,
        '([rast2.val] - [rast1.val]) / ([rast2.val] + [rast1.val])::float',
        '32BF'
    ) AS rast
FROM r;

-- Dodanie klucza głównego
ALTER TABLE szpilowska.porto_ndvi ADD COLUMN rid SERIAL PRIMARY KEY;
-- Utworzenie indeksu przestrzennego
CREATE INDEX idx_porto_ndvi_rast_gist ON szpilowska.porto_ndvi
USING gist (ST_ConvexHull(rast));
-- Dodanie ograniczeń rastrowych
SELECT AddRasterConstraints('szpilowska'::name,
'porto_ndvi'::name,'rast'::name);

COMMIT;


--Przykład 2 – Funkcja zwrotna

CREATE OR REPLACE FUNCTION szpilowska.ndvi(
    value double precision [] [] [],
    pos integer [][],
    VARIADIC userargs text []
)
RETURNS double precision AS
$$
BEGIN
-- value [1][1][1]: wartość piksela z pierwszego pasma wejściowego (Pasmo 1)
-- value [2][1][1]: wartość piksela z drugiego pasma wejściowego (Pasmo 4)
    RETURN (value [2][1][1] - value [1][1][1]) / (value [2][1][1] + value [1][1][1]);
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;

CREATE TABLE szpilowska.porto_ndvi2 AS
WITH r AS (
SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
r.rid,ST_MapAlgebra(
r.rast,
ARRAY[1,4]::integer[],-- Tablica indeksów pasm: [1] i [4]
'szpilowska.ndvi(double precision[], integer[], text[])'::regprocedure,
'32BF'::text
) AS rast
FROM r;


CREATE INDEX idx_porto_ndvi2_rast_gist ON szpilowska.porto_ndvi2
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('szpilowska'::name, 'porto_ndvi2'::name, 'rast'::name);

-------------------------------------------------------------
--eksport rastrow stworzonych we wcześniejszych przykładach--
-------------------------------------------------------------

-- ST_AsTiff tworzy dane wyjściowe jako binarną reprezentację pliku tiff
SELECT ST_AsTiff(ST_Union(rast))
FROM szpilowska.porto_ndvi2;

--ST_AsGDALRaster
SELECT ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])
FROM szpilowska.porto_ndvi2;

-- Zapisywanie danych na dysku za pomocą dużego obiektu (large object, lo)

CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
    ST_AsGDALRaster(ST_Union(rast), 'GTiff',  ARRAY['COMPRESS=DEFLATE',
    'PREDICTOR=2', 'PZLEVEL=9'])
) AS loid
FROM szpilowska.porto_ndvi2;

SELECT lo_export(loid, 'C:\sem_5\Bazy_Danych_Przestrzennych\myraster.tiff')
FROM tmp_out;

SELECT lo_unlink(loid)
FROM tmp_out;

--Rozwiązanie problemu postawionego we wcześniejszej części
CREATE TABLE szpilowska.tpi30_porto AS
SELECT ST_TPI(a.rast, 1) AS rast
FROM rasters.dem AS a
JOIN vectors.porto_parishes AS b
ON ST_Intersects(a.rast, b.geom)
WHERE b.municipality ILIKE 'porto';

CREATE INDEX idx_tpi30_porto_rast_gist ON szpilowska.tpi30_porto
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('szpilowska'::name, 'tpi30_porto'::name, 'rast'::name);


