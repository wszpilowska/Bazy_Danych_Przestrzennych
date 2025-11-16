CREATE TABLE obiekty (
    id SERIAL PRIMARY KEY,
    nazwa VARCHAR(50) NOT NULL,
    geometria GEOMETRY
);
INSERT INTO obiekty (nazwa, geometria) VALUES
('obiekt1', ST_GeomFromText('COMPOUNDCURVE((0 1, 1 1), CIRCULARSTRING(1 1, 2 0, 3 1), CIRCULARSTRING(3 1, 4 2, 5 1), (5 1, 6 1))', 0));

INSERT INTO obiekty (nazwa, geometria)
VALUES ('obiekt2',ST_MakePolygon
(ST_CurveToLine(ST_GeomFromText('COMPOUNDCURVE((10 6,10 2),CIRCULARSTRING(10 2,12 0,14 2),CIRCULARSTRING(14 2,16 4,14 6),(14 6,10 6))', 0)),
        ARRAY[ST_CurveToLine(ST_GeomFromText('CIRCULARSTRING(11.2 2, 12.2 3, 13.2 2, 12.2 1, 11.2 2)', 0))])
);


INSERT INTO obiekty (nazwa, geometria) VALUES
('obiekt3', ST_GeomFromText('POLYGON((7 15, 10 17, 12 13, 7 15))', 0));

INSERT INTO obiekty (nazwa, geometria) VALUES
('obiekt4', ST_GeomFromText('LINESTRING(20 20,25 25,27 24, 25 22,26 21,22 19,20.5 19.5)', 0));

INSERT INTO obiekty (nazwa, geometria)VALUES
('obiekt5',ST_GeomFromText('MULTIPOINT Z (30 30 59, 38 32 234)',0));

INSERT INTO obiekty (nazwa, geometria)VALUES
('obiekt6',ST_GeomFromText('GEOMETRYCOLLECTION (POINT (4 2),LINESTRING (1 1, 3 2))',0));

-- zad2
SELECT
    ST_Area(
        ST_Buffer(
            ST_ShortestLine(t1.geometria, t2.geometria),
            5.0
        )
    ) AS pole_powierzchni_bufora
FROM
    obiekty t1, obiekty t2
WHERE
    t1.nazwa = 'obiekt3' AND t2.nazwa = 'obiekt4';
--zad 3
--obiekt musi byc zamkniety
UPDATE obiekty
SET geometria = ST_GeomFromText('LINESTRING(20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5, 20 20)', 0)
WHERE nazwa = 'obiekt4';
--zamieniamy na poligon
UPDATE obiekty
SET geometria = ST_MakePolygon(geometria)
WHERE nazwa = 'obiekt4';
--4
INSERT INTO obiekty (nazwa, geometria)
SELECT
    'obiekt7',
    ST_Collect(o3.geometria, o4.geometria)
FROM
    obiekty o3, obiekty o4
WHERE
    o3.nazwa = 'obiekt3' AND o4.nazwa = 'obiekt4';

--5
SELECT
    SUM(ST_Area(ST_Buffer(geometria, 5.0))) AS calkowite_pole_buforow
FROM obiekty
WHERE
    ST_GeometryType(geometria) NOT IN ('ST_CircularString', 'ST_CompoundCurve', 'ST_CurvePolygon', 'ST_MultiCurve');