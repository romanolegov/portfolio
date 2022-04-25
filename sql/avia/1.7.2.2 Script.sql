-- 3.1. � ����� ������� ������ ������ ���������? ��������� � ������:
select city, count(city) as "airport count" from airports group by city having count(city)>1;
-- 3.2. ���� �� �����, �� ������� �� ����������� ��������? ��, �������� ����� ������������ (127901 ������������):
select book_ref from tickets t left join boarding_passes b on t.ticket_no=b.ticket_no where b.ticket_no IS NULL;
-- 3.3. � ����� ����������(!) ���� �����, ������� ������������� ���������� � ������������ ���������� ���������? �����, ��������, ���������, ����������, ����, �����������, �������:
select distinct airport_code, airport_name, city from airports a left join flights f on ((a.airport_code=f.arrival_airport) or (a.airport_code=f.departure_airport)) where aircraft_code in (select aircraft_code from aircrafts where range>=11000);

-- 3.4. ����� ������ ��������(!) ��������� ������ ���������? ������ ������� ������ ��� ������� � ���������� ��������� (626 �������)
-- 3.4.1 ��� ������� ����� ������ �������� ������ ��������� ����? ������ ������� ��� ������� � ���������� ��������� (����� ������ ���� ������� - ������ � �����������)

with flights_new as -- ������� ������, � �������� �������
(select tf.ticket_no, f.departure_airport, f.arrival_airport, --�������� �� ���� ������ ����� ������, �������� ������, �������� ������
        row_number() over (partition by tf.ticket_no order by tf.ticket_no, f.actual_departure) as num, -- ��������� ���������� ����� ������� � ������
        count(tf.ticket_no) over (partition by tf.ticket_no) as flightcount -- � ����� ���������� ������ �� ������
        from ticket_flights tf left join flights f on tf.flight_id=f.flight_id)
,
firstflits as -- ������� ������ �������� � ����������� � �������, � ������� ��� ���������� �������� ������, � �������� ����� ��������� �����
(select fn.ticket_no, a.city as departure_city from flights_new fn left join airports a on fn.departure_airport=a.airport_code where (flightcount>1) and (num=1))
,
lastflights as -- ������� ��������� �������� � ����������� � �������, � ������� ��� ���������� �������� ��������, � �������� ����� ��������� �����
(select fn.ticket_no, a.city as arrival_city from flights_new fn left join airports a on fn.departure_airport=a.airport_code where (flightcount>1) and (num=flightcount))
-- � �������� ������� ���������� ������� ������ � ��������� ��������, ����� ���������� ������ � ������� ����������
select ff.departure_city, lf.arrival_city, count (ff.departure_city) as countflight from firstflits ff left join lastflights lf on ff.ticket_no=lf.ticket_no group by ff.departure_city, lf.arrival_city order by countflight desc
;
--3.4.2* ����� ������ ���������� ��� ��������� ����? ������ ������� �������� ������� (91) � �������� ���������. ����� - ������.
with flights_new as -- ������� ������, � �������� �������
(select tf.ticket_no, f.departure_airport, f.arrival_airport, --�������� �� ���� ������ ����� ������, �������� ������, �������� ������
        row_number() over (partition by tf.ticket_no order by tf.ticket_no, f.actual_departure) as num, -- ��������� ���������� ����� ������� � ������
        count(tf.ticket_no) over (partition by tf.ticket_no) as flightcount -- � ����� ���������� ������ �� ������
        from ticket_flights tf left join flights f on tf.flight_id=f.flight_id)
,
transitflights as -- ������� ������������� �������� � �������, � ������� ��� ���������� �������� ������, � �������� ����� ��������� �����
(select a.city as transit_city from flights_new fn left join airports a on fn.departure_airport=a.airport_code where (flightcount>1) and (num>1))
-- � �������� ������� ������� ���������� ��������� � ���������� �������
select transit_city, count (transit_city) as counttransits from transitflights group by transit_city order by counttransits desc
;
-- 3.4.3* � ����� ������� ��������� ����� ����������?������ ������� ������ ������� �� ������� ������������������ ���������. ������: �����-�������, ������, ������:
with flights_new_time as -- ������� ������, � �������� ������� � ������ ������ � ��������
(select tf.ticket_no, f.departure_airport, f.arrival_airport, scheduled_departure, scheduled_arrival, --�������� �� ���� ������ ����� ������, �������� ������, �������� ������, ����� ������, ����� ��������
        row_number() over (partition by tf.ticket_no order by tf.ticket_no, f.actual_departure) as num, -- ��������� ���������� ����� ������� � ������
        count(tf.ticket_no) over (partition by tf.ticket_no) as flightcount -- � ����� ���������� ������ �� ������
        from ticket_flights tf left join flights f on tf.flight_id=f.flight_id)
,
flights_new as -- ������� ������ �������������������
(select a.ticket_no, a.departure_airport, a.arrival_airport, a.scheduled_departure-b.scheduled_arrival as duration, a.num, a.flightcount 
        from flights_new_time a left join flights_new_time b on ((a.ticket_no=b.ticket_no) and (b.num=a.num-1)))
,
transitflights as -- ������� ������������� �������� � �������, � ������� ��� ���������� �������� ������ � �����������������, � �������� ����� ��������� �����
(select a.city as transit_city, fn.duration from flights_new fn left join airports a on fn.departure_airport=a.airport_code where (flightcount>1) and (num>1))
-- � �������� ������� ������� ���������� ��������� � ���������� �������
select transit_city, avg (duration) as avgduration from transitflights group by transit_city order by avgduration desc -- ���������� ������ � ������� ������� ����������������� ���������
;
-- 3.5*. ����� ������ ��������(!) ��� ������ ������? ������ ������� ������ ��� ����������� � ���� ��� �������, ����� �������� ��� ������ ������ (9584)
with recursive 
discity as --��������������� � ��������������� ������ ������� - 101 �����
(select row_number() over () as num, city from (select distinct city from airports order by city) as t),
st as -- ������� ��� ������� ������� �� ���� ��������� ���������� - 101^2=10201 ����������
(select 1 as i, cast (1 as bigint) as k, cast (1 as bigint) as t
union 
select i+1 as i, i/(select count(city) from discity)+1 as k,  i % (select count(city) from discity) +1 as t from st
where i<(select count(city) from discity)*(select count(city) from discity)),
allvectors as --������� ��� �������� ������� �� ���� ��������� �����������  - 10201 ���������� ����� 101 ����������, ��� ���� ������� �� ���������� �������, ����� - 10100 ���
(select b.city as city1, c.city as city2 from st a left join discity b on a.k=b.num left join discity c on a.t=c.num where b.city<>c.city order by a.i),
flights_new as --������� ���� ��� �������, ����� �������� ���� ����� (�����������) - 516 �����������
(select distinct a.city as departure_airport, a2.city as arrival_airport from flights f
        left join airports a on f.departure_airport=a.airport_code 
        left join airports a2 on f.arrival_airport=a2.airport_code)
--��������� �������� �������� �� ���� �������, ����� �������� ��� ������ ������ - 10100 ����� 516=9584
select a.city1, a.city2 from allvectors a 
      left join flights_new b on ((a.city1=b.departure_airport) and (a.city2=b.arrival_airport)) 
      where b.departure_airport is null order by a.city1, a.city2;

-- 4.1 - �������� ������ 
create table seatsbooking -- ������� � ���������� ����������� �������, ��� ������ �������/��������������� ������ ���� � �������
(
ticket_no char(13), -- ����� ������
flight_id integer, -- ����� �����
CONSTRAINT seatbooking_key FOREIGN KEY (ticket_no, flight_id) REFERENCES ticket_flights(ticket_no, flight_id),
aircraft_code bpchar(3),
seat_no varchar (4),
CONSTRAINT seatbooking_key2 FOREIGN KEY (aircraft_code, seat_no) REFERENCES seats(aircraft_code, seat_no),
primary key (ticket_no, flight_id)
);
COMMENT ON TABLE seatsbooking IS '��������������� �����';

INSERT INTO seatsbooking-- ���������� ������ � ��������� ������ �� ������ ��� ����������� ������
(ticket_no, flight_id, aircraft_code, seat_no)
select a.ticket_no, a.flight_id, b.aircraft_code, c.seat_no from ticket_flights a 
	left join flights b on a.flight_id=b.flight_id left join boarding_passes c on ((a.ticket_no=c.ticket_no) and (a.flight_id=c.flight_id)) where c.seat_no is not null;

create table metar -- ������� � ��������� ������ METAR
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

COMMENT ON TABLE metar IS '���� METAR';
ALTER TABLE flights ADD DepartureMETAR uuid;
ALTER TABLE flights ADD ArrivalMETAR uuid;
ALTER TABLE flights add foreign key (DepartureMETAR) references metar(bID);
ALTER TABLE flights add foreign key (ArrivalMETAR) references metar(bID);

-- 5. ������� ��� ������� ��

-- 5.1. ������� �������� �������� �� ������
select flight_no, avg (actual_arrival-scheduled_arrival) as delay from flights 
	where actual_arrival is not null group by flight_no order by delay desc;

-- 5.2. ������� �������� �������� �� ������� �����������
select a.city, avg (f.actual_arrival-f.scheduled_arrival) as delay from flights f 
	left join airports a on f.departure_airport=a.airport_code 
	where f.actual_arrival is not null group by a.city order by delay desc;

-- 5.3. ������� �������� �������� �� ����������
select f.departure_airport, a.city, avg (f.actual_arrival-f.scheduled_arrival) as delay from flights f 
	left join airports a on f.departure_airport=a.airport_code 
	where f.actual_arrival is not null group by f.departure_airport, a.city order by delay desc;

-- 5.4. ������� �������� �������� �� ������� �������� � ����������� ������
select a.model, count (flight_id) as count_flights,avg (f.actual_arrival-f.scheduled_arrival) as delay from flights f 
	left join aircrafts a on f.aircraft_code=a.aircraft_code 
	where f.actual_arrival is not null group by a.model order by delay desc;

-- 5.5. ������� �������� �������� �� ���������� ����������
select case  -- ��������� ���������� ���������� ����� ����� �������, ����� �������� ������� ���������� ��������
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

-- 5.6. ������� �������� �������� �� ���� ������
select (extract(ISODOW from scheduled_departure::timestamp))::integer  as weekday, avg (actual_arrival-scheduled_arrival) as delay from flights
	where actual_arrival is not null group by weekday order by delay desc;
	
-- 5.7. ������� �������� �������� �� ���� �����
select (extract(hour from scheduled_departure::timestamp))::integer  as weekday, avg (actual_arrival-scheduled_arrival) as delay from flights
	where actual_arrival is not null group by weekday order by delay desc;