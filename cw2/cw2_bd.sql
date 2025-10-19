create database mapa;
\c mapa;
create extension postgis;

create table buildings (
  id int primary key,
  name text,
  geom geometry
);

create table roads (
  id int primary key,
  name text,
  geom geometry
);

create table poi (
  id int primary key,
  name text,
  geom geometry
);


insert into buildings (id,name,geom) values
(1,'BuildingA',st_geomfromtext('polygon((8 1.5, 8 4, 10.5 4, 10.5 1.5, 8 1.5))',0)),
(2,'BuildingB',st_geomfromtext('polygon((4 5, 4 7, 6 7, 6 5, 4 5))',0)),
(3,'BuildingC',st_geomfromtext('polygon((5 6, 3 6, 3 8, 5 8, 5 6))',0)),
(4,'BuildingD',st_geomfromtext('polygon((9 9, 10 9, 10 8, 9 8, 9 9))',0)),
(5,'BuildingF',st_geomfromtext('polygon((1 2, 2 2, 2 1,1 1,1 2))',0));

insert into roads (id,name,geom) values
(1,'RoadX', st_geomfromtext('linestring(0 4.5, 12 4.5)',0)),
(2,'RoadY', st_geomfromtext('linestring(7.5 0, 7.5 10.5)',0));

insert into poi (id,name,geom) values
(1,'K', st_geomfromtext('point(6 9.5)',0)),
(2,'J', st_geomfromtext('point(6.5 6)',0)),
(3,'I', st_geomfromtext('point(9.5 6)',0)),
(4,'H', st_geomfromtext('point(5.5 1.5)',0)),
(5,'G', st_geomfromtext('point(1 3.5)',0));




