drop table Enrolment;
drop table Course;

drop trigger q7a on Enrolment;
drop trigger q7b on Enrolment;


drop function increaseStudents();
drop function decreaseStudents();


create table Enrolment(course char(8), sid integer, mark integer);
create table Course(code char(8), lic text, quota integer, numStudes integer);



create or replace function increaseStudents() returns trigger
as $$
	
declare
	_numStudes int;
	_quota int;
	_code char(8);

begin
	select numStudes, quota into _numStudes, _quota
	from Course;

	-- check if the course you are adding actually exists
	select code into _code
	from course
	where code = new.course;

	if (not found) then
		raise exception 'Course does not exist';
	end if;

	-- checks if adding a course exceeds the quota
	if (_numStudes >= _quota) then
		raise exception 'number of studies has exceeded quota';
	end if;

	-- increments the numStudes by 1

	update course
	set numStudes = numStudes + 1
	where code = new.course;
	return new;
end;
$$ language plpgsql;


create or replace function decreaseStudents() returns trigger
as $$
	
declare
	_numStudes int;
	_quota int;

begin
	select numStudes, quota into _numStudes, _quota
	from Course;

	if (_numStudes = 0) then
		raise exception 'current no students to delete';
	end if;
	
	update course
	set numStudes = numStudes - 1
	where code = old.course;

	return old;

end;
$$ language plpgsql;


create or replace function updateStudents() returns trigger
as $$
	
declare
_quota int;
_numStudes int;


begin
	
	select quota, numStudes into _quota, _numStudes
	from Course
	where code = new.course;


	if (_quota = _NumStudes) then
		raise exception 'courses full';
	end if;

	update course 
	set numStudes = numStudes + 1 
	where code = new.course;

	update course 
	set numStudes = numStudes - 1 
	where code = old.course;

return new;
end;
$$ language plpgsql;


create trigger q7a before INSERT on Enrolment
for each row execute procedure increaseStudents();

create trigger q7b before DELETE on Enrolment
for each row execute procedure decreaseStudents();

create trigger q7c before UPDATE on Enrolment
for each row execute procedure updateStudents();


insert into course values ('COMP3311', 'licdude', 3, 0);
insert into course values ('COMP1917', 'licdude', 3, 0);	
insert into enrolment values ('COMP3311', 3461591, 94);
insert into enrolment values ('COMP3311', 3461590, 85);

