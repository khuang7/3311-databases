-- COMP3311 18s1 Assignment 2
--
-- updates.sql
--
-- Written by <<YOUR NAME>> (<<YOUR ID>>), May 2018

--  This script takes a "vanilla" MyMyUNSW database and
--  make all of the changes necessary to make the databas
--  work correctly with your PHP scripts.
--  
--  Such changes might involve adding new tables, views,
--  PLpgSQL functions, triggers, etc. Other changes might
--  involve dropping existing tables or redefining existing
--  views and functions
--  
--  Make sure that this script does EVERYTHING necessary to
--  upgrade a vanilla database; if we need to chase you up
--  because you forgot to include some of the changes, and
--  your system will not work correctly because of this, you
--  will receive a 3 mark penalty.



create or replace function latest_sem(stu int)
	returns int
as
$$
declare
	_latestid int;
begin
	select sem.id into _latestid
	from program_enrolments pe, semesters sem
	where pe.student = stu and pe.semester = sem.id and
	      sem.starting = (select max(sem.starting)
                          from program_enrolments pe, semesters sem
	                      where pe.student = stu and pe.semester = sem.id);

	return _latestid;
end;

$$ language plpgsql;



-- Grabs appropriate program that the student is enroled in for the "curr" semester.
create type curr_program_info as (peid int, program int, semid int);

-- Retreive all program enrolments of a particular student,
-- Program ID, Semester starting date shown
create or replace function curr_program(stu int, given_sem int) 
	returns curr_program_info
as $$
declare
	r curr_program_info;
	_latest date;
	_curr date;
	_latestid int;
	_currid int := given_sem;
begin

	select * from latest_sem(stu) into _latestid;
	select starting from semesters where id = _latestid into _latest;
	select starting from semesters where id = given_sem into _curr;


	-- Deal with cases later
	if (_latest < _curr) then
		_currid := _latestid;
	end if;


	select pe.id, pe.program, sem.id into r.peid, r.program, r.semid
	from program_enrolments pe, semesters sem
	where student = stu and sem.id = _currid;

	return r;

end;
$$ language plpgsql;


-- All the program rules id and the type for a specified program

create type ruleid_type as (id int, rulecode ruletype, min integer, max integer, ao_group integer);


create or replace function rules_for_program(_program int)
	returns setof ruleid_type
as
$$
declare
	rec ruleid_type;
begin
	for rec in select pr.rule, r.type, r.min, r.max, r.ao_group
	           from program_rules pr, rules r
	           where program = _program and pr.rule = r.id
	loop
		return next rec;
	end loop;
end;
$$ language plpgsql;


-- All the stream rules id and the type for a specified program enrolment

create or replace function rules_for_stream(_peid int)
	returns setof ruleid_type
as
$$
declare
	rec ruleid_type;
begin
	for rec in select sr.rule, r.type, r.min, r.max, r.ao_group
		       from stream_enrolments se, streams s, stream_rules sr, rules r, program_enrolments pe
		       where pe.id = se.partof and se.stream = s.id and sr.stream = s.id
		             and r.id = sr.rule and se.partof = _peid
    loop
    	return next rec;
    end loop;
end;
$$ language plpgsql;
