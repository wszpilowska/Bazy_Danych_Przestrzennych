\c firma;

--a
select id_pracownika, nazwisko from ksiegowosc.pracownicy;
--b
select p.id_pracownika, p.imie, p.nazwisko, pe.kwota
from ksiegowosc.pracownicy p
join ksiegowosc.wynagrodzenie w on p.id_pracownika = w.id_pracownika
join ksiegowosc.pensja pe on w.id_pensji = pe.id_pensji
where kwota > 1000;
--c
select w.id_pracownika, pe.kwota
from ksiegowosc.pensja pe
join ksiegowosc.wynagrodzenie w on pe.id_pensji = w.id_pensji
join ksiegowosc.premia pr on w.id_premii = pr.id_premii
where pr.kwota = 0 and pe.kwota > 2000;
--d
select imie, nazwisko from ksiegowosc.pracownicy
where imie like 'J%';
--e
select imie, nazwisko from ksiegowosc.pracownicy
where imie like '%a' and (nazwisko like '%n%' or nazwisko like '%N%');
--f
select p.imie, p.nazwisko,
case
    when g.liczba_godzin < 160 then 0
    else g.liczba_godzin - 160
end as liczba_nadgodzin
from ksiegowosc.pracownicy p
join ksiegowosc.godziny g on p.id_pracownika = g.id_pracownika;
--g
select p.imie, p.nazwisko, pe.kwota
from ksiegowosc.pracownicy p
join ksiegowosc.wynagrodzenie w on p.id_pracownika = w.id_pracownika
join ksiegowosc.pensja pe on w.id_pensji = pe.id_pensji
where kwota > 1500 and kwota < 3000;
--h
select p.imie, p.nazwisko, g.liczba_godzin - 160 as liczba_nadgodzin
from ksiegowosc.pracownicy p
join ksiegowosc.godziny g on p.id_pracownika = g.id_pracownika
join ksiegowosc.wynagrodzenie w on g.id_godziny = w.id_godziny
join ksiegowosc.premia pr on w.id_premii = pr.id_premii
where g.liczba_godzin > 160 and pr.kwota = 0;

