create database firma;
\c firma;
create schema ksiegowosc;

create table ksiegowosc.pracownicy (
    id_pracownika int primary key,
    imie varchar(50),
    nazwisko varchar(50),
    adres varchar(100),
    telefon varchar(15)
);
comment on table ksiegowosc.pracownicy is 'Dane pracowników firmy.';

create table ksiegowosc.godziny (
    id_godziny int primary key,
    data date,
    liczba_godzin numeric(4,2),
    id_pracownika int references ksiegowosc.pracownicy(id_pracownika)
);
comment on table ksiegowosc.godziny is 'Godziny pracy pracowników.';

create table ksiegowosc.pensja (
    id_pensji int primary key,
    stanowisko varchar(50),
    kwota money
);
comment on table ksiegowosc.pensja is 'Pensje na stanowiskach.';

create table ksiegowosc.premia (
    id_premii int primary key,
    rodzaj varchar(50),
    kwota money
);
comment on table ksiegowosc.premia is 'Rodzaje premii.';

create table ksiegowosc.wynagrodzenie (
    id_wynagrodzenia int primary key,
    data date,
    id_pracownika int references ksiegowosc.pracownicy(id_pracownika),
    id_godziny int references ksiegowosc.godziny(id_godziny),
    id_pensji int references ksiegowosc.pensja(id_pensji),
    id_premii int references ksiegowosc.premia(id_premii)
);
comment on table ksiegowosc.wynagrodzenie is 'Wynagrodzenia pracowników.';




