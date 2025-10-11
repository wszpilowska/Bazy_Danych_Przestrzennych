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
    liczba_godzin numeric(6,2),
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

--pracownicy
insert into ksiegowosc.pracownicy (id_pracownika, imie, nazwisko, adres, telefon) values
(1, 'Jan', 'Nowak', 'Warszawa, ul. Lipowa 12', '500123123'),
(2, 'Anna', 'Kowalska', 'Kraków, ul. Różana 5', '501234234'),
(3, 'Piotr', 'Wiśniewski', 'Gdańsk, ul. Morska 10', '502345345'),
(4, 'Julia', 'Nowicka', 'Poznań, ul. Słoneczna 7', '503456456'),
(5, 'Kamil', 'Lewandowski', 'Łódź, ul. Polna 3', '504567567'),
(6, 'Joanna', 'Kubiak', 'Wrocław, ul. Długa 9', '505678678'),
(7, 'Tomasz', 'Nowakowski', 'Lublin, ul. Mickiewicza 2', '506789789'),
(8, 'Jakub', 'Pawlak', 'Katowice, ul. Ogrodowa 8', '507890890'),
(9, 'Magda', 'Zielińska', 'Rzeszów, ul. Parkowa 4', '508901901'),
(10, 'Jacek', 'Adamski', 'Szczecin, ul. Krótka 1', '509012012');

--godziny
insert into ksiegowosc.godziny (id_godziny, data, liczba_godzin, id_pracownika) values
(1, '2025-09-30', 170, 1),
(2, '2025-09-30', 165, 2),
(3, '2025-09-30', 150, 3),
(4, '2025-09-30', 180, 4),
(5, '2025-09-30', 160, 5),
(6, '2025-09-30', 200, 6),
(7, '2025-09-30', 155, 7),
(8, '2025-09-30', 175, 8),
(9, '2025-09-30', 162, 9),
(10, '2025-09-30', 158, 10);

--pensja
insert into ksiegowosc.pensja (id_pensji, stanowisko, kwota) values
(1, 'kierownik', 4000),
(2, 'księgowy', 2800),
(3, 'asystent', 1800),
(4, 'magazynier', 1600),
(5, 'sprzedawca', 2000),
(6, 'informatyk', 3500),
(7, 'kadrowy', 2500),
(8, 'specjalista', 3000),
(9, 'stażysta', 1200),
(10, 'kierownik', 4200);

--premia
insert into ksiegowosc.premia (id_premii, rodzaj, kwota) values
(1, 'brak', 0),
(2, 'uznaniowa', 500),
(3, 'świąteczna', 800),
(4, 'brak', 0),
(5, 'za wyniki', 600),
(6, 'brak', 0),
(7, 'świąteczna', 1000),
(8, 'uznaniowa', 300),
(9, 'brak', 0),
(10, 'za wyniki', 700);

--wynagrodzenie
insert into ksiegowosc.wynagrodzenie (id_wynagrodzenia, data, id_pracownika, id_godziny, id_pensji, id_premii) values
(1, '2025-09-30', 1, 1, 1, 2),
(2, '2025-09-30', 2, 2, 2, 3),
(3, '2025-09-30', 3, 3, 3, 1),
(4, '2025-09-30', 4, 4, 4, 5),
(5, '2025-09-30', 5, 5, 5, 4),
(6, '2025-09-30', 6, 6, 6, 1),
(7, '2025-09-30', 7, 7, 7, 8),
(8, '2025-09-30', 8, 8, 8, 9),
(9, '2025-09-30', 9, 9, 9, 1),
(10, '2025-09-30', 10, 10, 10, 7);




