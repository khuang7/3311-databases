drop view if exists q1a;
drop view if exists q1b;
drop view if exists q1c;
drop view if exists q1d;
drop view if exists q1e;
drop view if exists q1f;
drop view if exists q1i;
drop view if exists q1j;

CREATE VIEW q1a 
as

	select s.sname 
	from suppliers as s, parts as p, catalogue as c
	where s.sid = c.sid
	and p.pid = c.pid
	and p.colour = 'red'
;

CREATE VIEW q1b
as
	select s.sname 
	from suppliers as s, parts as p, catalogue as c
	where s.sid = c.sid
	and p.pid = c.pid
	and p.colour in ('red', 'green')
;

CREATE VIEW q1c
as
	select s.sid
	from suppliers as s, parts as p, catalogue as c
	where s.sid = c.sid
	and p.pid = c.pid
	and (p.colour = 'red' or s.address = 'Home1')
;

CREATE VIEW q1d
as 
	select s.sid
	from suppliers as s, parts as p, catalogue as c
	where s.sid = c.sid
	and p.pid = c.pid
	and (p.colour = 'red' and p.colour = 'red');


;

CREATE VIEW q1e
as 
	select s.sid
	from suppliers s
	where not exists (
		select pid from parts
		except
		select c.pid from catalogue c where s.sid = c.sid)
;


CREATE VIEW q1f
as 
	select s.sid
	from suppliers s
	where not exists (
		select pid from parts
		where colour = 'red'
		except
		select c.pid from catalogue c where s.sid = c.sid)
;


-- Find pairs of sids such that the supplier with the 
-- first sid charges more for some part than the supplier with the second sid.


CREATE VIEW q1i
as
	select c1.sid, c2.sid
	from catalogue c1, catalogue c2
	where c1.pid = c2.pid
	and c1.cost > c2.cost
	and c1.sid != c2.sid
;


CREATE VIEW q1j
as
	select distinct c1.pid
	from catalogue c1, catalogue c2
	where c1.pid = c2.pid
	and c1.sid != c2.sid

;