/*
   Student(id, name, major, stage, age)
   Class(name, meetsAt, room, lecturer)
   Enrolled(student, class, mark)
   Lecturer(id, name, department)
   Department(id, name)
*/

-- Find the names of all first-year 
-- (stage 1) students who are enrolled in a class taught by Andrew Taylor.

CREATE VIEW q2a 
as

	select s.name
	from student s, enrolled e, class c, lecturer l
	where e.student = s.id
	and e.class = c.name
	and c.lecturer = l.id
	and l.name = 'Andrew Taylor'
	and s.stage = 1
;


-- Find the age of the oldest student enrolled in any of John Shepherd's classes.
CREATE VIEW q2b 
as
	select max(s.age)
	from student s, enrolled e, class c, lecturer l
	where e.student = s.id
	and e.class = c.name
	and c.lecturer = l.id
	l.name = 'John Shepherd'
	
;

-- Find the names of all classes that have more than 100 students enrolled.

select e.name
from enrolled e
where e.name in (select e.name
				from 
				where count > 100
				)



create view q2b_helper
as
	select e.class, count(e.class) as count
	from enrolled e
	group by e.class
;


-- Find the names of all students who are enrolled in two classes that meet at the same time.

create view q2d
as


create view meetatsametime
as
	select s.name
	from class c1, class c2, enrolled e1, enrolled e2, student s

	where c1.name = e1.class
	.....
	and c2.name = e2.class
	and c1.meetsAt = c2.meetsAt
	and c1.name != c2.name
	and e1.student = e2.student
;


-- Find the names of faculty members for whom the combined enrollment of the courses they teach is less than five
create view q2e
as
	select l.name 
	from lecturer l
	where l.name in (select name 
					from q2e_helper
					where count < 5)
;



create view q2e_helper
as
	select l.name as name, count(*) as count
	from lecturer l, class c
	where l.id = c.lecturer
	group by l.id

-- for each stage, print the stage and average age of students.

create view q2f
as
	select s.stage, avg(s.stage)
	from students s
	group by s.stage
;



-- THREE WAYS OF DOING THIS
create view q2g
as
	select name
	from student
	where s.id in (
	select id from student 
	except
	select student from enrolled)
;


	select name
	from student
	where s.id not in (select student from enrolled);


	-- left outer join


















