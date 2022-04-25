# Проектная работа по модулю “SQL и получение данных”

Выполнение этого задания на примере задачи выборки данных для анализа корреляции параметров перелётов и задержек прибытия демонтрирует работу с SQL, в том числе с оконными функциями. Результаты подобного анализа могут быть использованы для выявления системных организационных проблем, вызывающих задержки рейсов, а также разработки системы рекомендаций запаса времени между стыковочными рейсами, учитывающей риски задержки рейсов. Перечнем из 7 запросов выбираются данные о распределении средних задержек прибытия рейса в зависимости от конкретного рейса, города отправления, аэропорта отправления, модели самолёта, количества пассажиров, дня недели, часа суток. Цель работы – создание скриптов выгрузки данных, результаты анализа целью работы не являются, так как данные являются тестовыми.<br/><br/> В совокупности с ещё 4 домашними заданиями результатом оценки этой работы стало получение [диплома "SQL и получение данных"](https://github.com/romanolegov/portfolio/blob/main/sql/avia/cert.jpg).

## 1.b.1.Описание предметной области и проблемы, которую вы решаете своей работой

Выбранная область – выборка данных для анализа корреляции параметров перелётов и задержек прибытия. Результаты подобного анализа могут быть использованы для выявления системных организационных проблем, вызывающих задержки рейсов, а также разработки системы рекомендаций запаса времени между стыковочными рейсами, учитывающей риски задержки рейсов. Перечнем из 7 запросов (запросы 5.1-5.7) выбираются данные о распределении средних задержек прибытия рейса в зависимости от конкретного рейса, города отправления, аэропорта отправления, модели самолёта, количества пассажиров, дня недели, часа суток. Цель работы – создание скриптов выгрузки данных, результаты анализа целью работы не являются, так как данные являются тестовыми.

1.b.2-3 *Текстовое описание таблиц и логики их связи*

seatsbooking *-* таблица с выбранными пассажирами местами, для модуля продажи/самостоятельного выбора мест в самолёте. Связана с таблицами seats и tickets_flights по их составным ключам. Эти внешние ключи выбраны как ссылающиеся на первичные данные. В качестве первичного ключа выбран составной ключ tickets_flights, так как он должен быть уникальным, в отличие от места самолёта, которое будет повторяться от полёта к полёту в разных билетах.

Metar - таблица для погодных кодов METAR. Содержит связи с таблицей airports по коду аэропорта кода METAR и двойную связь с таблицей flights по добавленным в эту таблицу полям ID кода METAR для вылета и прилёта. В качестве первичного ключа выбран суррогатный ключ (в качестве естественного первичного ключа может выступать только составной ключ из кода аэропорта и даты METAR, что неудобно в качестве связи с таблицей flights) в формате UUID (как лучшая практика).

1.b.4 ER-диаграма:

![](/sql/avia/1.7.2.1.b.4%20ER.png)

2\. Ответы на вопросы пункта 3 (скрипты с соответствующими номерами в приложении и отдельным файлом):

*(2.)3.1. В каких городах больше одного аэропорта? Ульяновск и Москва:*

*(2.)3.2. Были ли брони, по которым не совершались перелеты? Да, перечень кодов бронирования (127901 бронирование):*

*(2.)*3.3. В каких аэропортах(!) есть рейсы, которые обслуживаются самолетами с максимальной дальностью перелетов? Пермь, Кольцово, Толмачёво, Домодедово, Сочи, Шереметьево, Внуково:

*(2.)3.4. Между какими городами(!) пассажиры делали пересадки? Запрос выводит список пар городов и количество пересадок (626 городов)*

*(2.)3.4.1 При полетах между какими городами делают пересадки чаще? Запрос выводит пар городов и количество пересадок (самая частая пара городов - Москва и Новосибирск)*

*(2.)3.4.2\* Какие города используют для пересадок чаще? Запрос выводит перечень городов (91) с частотой пересадок. Лидер - Москва.*

*(2.)3.4.3\* В каких городах пересадки самые длительные?Запрос выводит список городов со средней продолжительностью пересадки. Лидеры: Горно-Алтайск, Усинск, Нягань:*

*(2.)3.5\*. Между какими городами(!) нет прямых рейсов? Запрос выводит список пар направлений в виде пар городов, между которыми нет прямых рейсов (9584)*

Скрипты

```sql
-- 3.1. В каких городах больше одного аэропорта? Ульяновск и Москва:
select city, count(city) as "airport count" from airports group by city having count(city)>1;
-- 3.2. Были ли брони, по которым не совершались перелеты? Да, перечень кодов бронирования (127901 бронирование):
select book_ref from tickets t left join boarding_passes b on t.ticket_no=b.ticket_no where b.ticket_no IS NULL;
-- 3.3. В каких аэропортах(!) есть рейсы, которые обслуживаются самолетами с максимальной дальностью перелетов? Пермь, Кольцово, Толмачёво, Домодедово, Сочи, Шереметьево, Внуково:
select distinct airport_code, airport_name, city from airports a left join flights f on ((a.airport_code=f.arrival_airport) or (a.airport_code=f.departure_airport)) where aircraft_code in (select aircraft_code from aircrafts where range>=11000);

-- 3.4. Между какими городами(!) пассажиры делали пересадки? Запрос выводит список пар городов и количество пересадок (626 городов)
-- 3.4.1 При полетах между какими городами делают пересадки чаще? Запрос выводит пар городов и количество пересадок (самая частая пара городов - Москва и Новосибирск)

with flights_new as -- таблица полётов, с номерами билетов
(select tf.ticket_no, f.departure_airport, f.arrival_airport, --выбираем из двух таблиц номер билета, аэропорт вылета, аэропорт прилёта
        row_number() over (partition by tf.ticket_no order by tf.ticket_no, f.actual_departure) as num, -- добавляем порядковый номер перелёта в билете
        count(tf.ticket_no) over (partition by tf.ticket_no) as flightcount -- и общее количество полётов по билету
        from ticket_flights tf left join flights f on tf.flight_id=f.flight_id)
,
firstflits as -- таблица первых перелётов с пересадками в билетах, в которых нас интересует аэропорт вылета, к которому сразу подбираем город
(select fn.ticket_no, a.city as departure_city from flights_new fn left join airports a on fn.departure_airport=a.airport_code where (flightcount>1) and (num=1))
,
lastflights as -- таблица последних перелётов с пересадками в билетах, в которых нас интересует аэропорт прибытия, к которому сразу подбираем город
(select fn.ticket_no, a.city as arrival_city from flights_new fn left join airports a on fn.departure_airport=a.airport_code where (flightcount>1) and (num=flightcount))
-- в основном запросе объединяем таблицы первых и последних перелётов, сразу группируем парами и считаем количество
select ff.departure_city, lf.arrival_city, count (ff.departure_city) as countflight from firstflits ff left join lastflights lf on ff.ticket_no=lf.ticket_no group by ff.departure_city, lf.arrival_city order by countflight desc
;
--3.4.2* Какие города используют для пересадок чаще? Запрос выводит перечень городов (91) с частотой пересадок. Лидер - Москва.
with flights_new as -- таблица полётов, с номерами билетов
(select tf.ticket_no, f.departure_airport, f.arrival_airport, --выбираем из двух таблиц номер билета, аэропорт вылета, аэропорт прилёта
        row_number() over (partition by tf.ticket_no order by tf.ticket_no, f.actual_departure) as num, -- добавляем порядковый номер перелёта в билете
        count(tf.ticket_no) over (partition by tf.ticket_no) as flightcount -- и общее количество полётов по билету
        from ticket_flights tf left join flights f on tf.flight_id=f.flight_id)
,
transitflights as -- таблица промежуточных перелётов в билетах, в которых нас интересует аэропорт вылета, к которому сразу подбираем город
(select a.city as transit_city from flights_new fn left join airports a on fn.departure_airport=a.airport_code where (flightcount>1) and (num>1))
-- в основном запросе считаем количество пересадок в транзитных городах
select transit_city, count (transit_city) as counttransits from transitflights group by transit_city order by counttransits desc
;
-- 3.4.3* В каких городах пересадки самые длительные?Запрос выводит список городов со средней продолжительностью пересадки. Лидеры: Горно-Алтайск, Усинск, Нягань:
with flights_new_time as -- таблица полётов, с номерами билетов и датами вылета и прибытия
(select tf.ticket_no, f.departure_airport, f.arrival_airport, scheduled_departure, scheduled_arrival, --выбираем из двух таблиц номер билета, аэропорт вылета, аэропорт прилёта, время вылета, время прибытия
        row_number() over (partition by tf.ticket_no order by tf.ticket_no, f.actual_departure) as num, -- добавляем порядковый номер перелёта в билете
        count(tf.ticket_no) over (partition by tf.ticket_no) as flightcount -- и общее количество полётов по билету
        from ticket_flights tf left join flights f on tf.flight_id=f.flight_id)
,
flights_new as -- таблица полётов спродолжительностью
(select a.ticket_no, a.departure_airport, a.arrival_airport, a.scheduled_departure-b.scheduled_arrival as duration, a.num, a.flightcount 
        from flights_new_time a left join flights_new_time b on ((a.ticket_no=b.ticket_no) and (b.num=a.num-1)))
,
transitflights as -- таблица промежуточных перелётов в билетах, в которых нас интересует аэропорт вылета и продолжительность, к которому сразу подбираем город
(select a.city as transit_city, fn.duration from flights_new fn left join airports a on fn.departure_airport=a.airport_code where (flightcount>1) and (num>1))
-- в основном запросе считаем количество пересадок в транзитных городах
select transit_city, avg (duration) as avgduration from transitflights group by transit_city order by avgduration desc -- группируем города и считаем среднюю продолжительность пересадки
;
-- 3.5*. Между какими городами(!) нет прямых рейсов? Запрос выводит список пар направлений в виде пар городов, между которыми нет прямых рейсов (9584)
with recursive 
discity as --пронумерованный и отсортированный список городов - 101 город
(select row_number() over () as num, city from (select distinct city from airports order by city) as t),
st as -- таблица пар НОМЕРОВ городов во всех возможных комбинацих - 101^2=10201 комбинация
(select 1 as i, cast (1 as bigint) as k, cast (1 as bigint) as t
union 
select i+1 as i, i/(select count(city) from discity)+1 as k,  i % (select count(city) from discity) +1 as t from st
where i<(select count(city) from discity)*(select count(city) from discity)),
allvectors as --таблица пар НАЗВАНИЙ городов во всех возможных комбинациях  - 10201 комбинация минус 101 комбинация, где пара состоит из одинаковых городов, итого - 10100 пар
(select b.city as city1, c.city as city2 from st a left join discity b on a.k=b.num left join discity c on a.t=c.num where b.city<>c.city order by a.i),
flights_new as --таблица всех пар городов, между которыми есть рейсы (направлений) - 516 направлений
(select distinct a.city as departure_airport, a2.city as arrival_airport from flights f
        left join airports a on f.departure_airport=a.airport_code 
        left join airports a2 on f.arrival_airport=a2.airport_code)
--следующим запросом выбираем те пары городов, между которыми нет прямых рейсов - 10100 минус 516=9584
select a.city1, a.city2 from allvectors a 
      left join flights_new b on ((a.city1=b.departure_airport) and (a.city2=b.arrival_airport)) 
      where b.departure_airport is null order by a.city1, a.city2;

-- 4.1 - создание таблиц 
create table seatsbooking -- таблица с выбранными пассажирами местами, для модуля продажи/смостоятельного выбора мест в самолёте
(
ticket_no char(13), -- номер билета
flight_id integer, -- номер полёта
CONSTRAINT seatbooking_key FOREIGN KEY (ticket_no, flight_id) REFERENCES ticket_flights(ticket_no, flight_id),
aircraft_code bpchar(3),
seat_no varchar (4),
CONSTRAINT seatbooking_key2 FOREIGN KEY (aircraft_code, seat_no) REFERENCES seats(aircraft_code, seat_no),
primary key (ticket_no, flight_id)
);
COMMENT ON TABLE seatsbooking IS 'Забронированные места';

INSERT INTO seatsbooking-- заполнение данных о выбранных местах на основе уже совершённых рейсов
(ticket_no, flight_id, aircraft_code, seat_no)
select a.ticket_no, a.flight_id, b.aircraft_code, c.seat_no from ticket_flights a 
	left join flights b on a.flight_id=b.flight_id left join boarding_passes c on ((a.ticket_no=c.ticket_no) and (a.flight_id=c.flight_id)) where c.seat_no is not null;

create table metar -- таблица с погодными кодами METAR
(
bID uuid PRIMARY key default uuid_generate_v1(),
airport_code bpchar(3),
datetime bpchar (7),
wind bpchar (20),
visible bpchar (20),
phenom bpchar (20),
cloud bpchar (20),
temper bpchar (20),
press bpchar (20),
other1 bpchar (20),
forecast bpchar (20),
other2 bpchar (20),
foreign key (airport_code) references airports(airport_code)
);

COMMENT ON TABLE metar IS 'Коды METAR';
ALTER TABLE flights ADD DepartureMETAR uuid;
ALTER TABLE flights ADD ArrivalMETAR uuid;
ALTER TABLE flights add foreign key (DepartureMETAR) references metar(bID);
ALTER TABLE flights add foreign key (ArrivalMETAR) references metar(bID);

-- 5. запросы для анализа БД

-- 5.1. средняя задержка прибытия по рейсам
select flight_no, avg (actual_arrival-scheduled_arrival) as delay from flights 
	where actual_arrival is not null group by flight_no order by delay desc;

-- 5.2. средняя задержка прибытия по городам отправления
select a.city, avg (f.actual_arrival-f.scheduled_arrival) as delay from flights f 
	left join airports a on f.departure_airport=a.airport_code 
	where f.actual_arrival is not null group by a.city order by delay desc;

-- 5.3. средняя задержка прибытия по аэропортам
select f.departure_airport, a.city, avg (f.actual_arrival-f.scheduled_arrival) as delay from flights f 
	left join airports a on f.departure_airport=a.airport_code 
	where f.actual_arrival is not null group by f.departure_airport, a.city order by delay desc;

-- 5.4. средняя задержка прибытия по моделям самолётов с количеством полётов
select a.model, count (flight_id) as count_flights,avg (f.actual_arrival-f.scheduled_arrival) as delay from flights f 
	left join aircrafts a on f.aircraft_code=a.aircraft_code 
	where f.actual_arrival is not null group by a.model order by delay desc;

-- 5.5. средняя задержка прибытия по количеству пассажиров
select case  -- диапазоны количества пассажиров взяты таким образом, чтобы содерать близкое количество перелётов
	when passangers>=0 and passangers<5 then '000-005'
	when passangers>=5 and passangers<10 then '005-010'
	when passangers>=10 and passangers<17 then '010-017'
	when passangers>=17 and passangers<25 then '017-025'
	when passangers>=25 and passangers<36 then '025-036'
	when passangers>=36 and passangers<50 then '036-050'
	when passangers>=50 and passangers<75 then '050-075'
	when passangers>=75 and passangers<100 then '075-100'
	when passangers>=100 then '100+'  end
	passangerscount
	, count (passangers) as countflights, avg (f.actual_arrival-f.scheduled_arrival) as delay from flights f 
	inner join (select flight_id, count(ticket_no) passangers from ticket_flights group by flight_id) tf on f.flight_id=tf.flight_id 
	where f.actual_arrival is not null group by passangerscount order by delay desc;

-- 5.6. средняя задержка прибытия по дням недели
select (extract(ISODOW from scheduled_departure::timestamp))::integer  as weekday, avg (actual_arrival-scheduled_arrival) as delay from flights
	where actual_arrival is not null group by weekday order by delay desc;
	
-- 5.7. средняя задержка прибытия по часу суток
select (extract(hour from scheduled_departure::timestamp))::integer  as weekday, avg (actual_arrival-scheduled_arrival) as delay from flights
	where actual_arrival is not null group by weekday order by delay desc;
 ```
