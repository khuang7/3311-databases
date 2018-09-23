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


/*
-- give student id as argument
CREATE or REPLACE function max_semester(int) RETURNS int
AS $$


DECLARE
semester_id int;

begin
    select semester_id into 
        select max(sem.starting) into $semester_id
        from semesters sem, course_enrolments ce, courses c
        where ce.course = c.id
        and c.semester = sem.id
        and ce.student = $1

--1182627 201 554

end
$$ LANGUAGE plpgsql;
*/

create type program_and_peid as ( program integer, peid integer );
-- give the student id
CREATE or REPLACE function latest_program(int) RETURNS program_and_peid 
AS $$
    
DECLARE
    rec program_and_peid;
    program int;

BEGIN
    select pe.program, pe.id into rec.program, rec.peid
    from program_enrolments pe, semesters sem
    where student = $1
    and sem.starting = (select max(sem.starting)
                        from program_enrolments pe, semesters sem
                        where student = $1 and pe.semester = sem.id);

    return rec;
end
$$ LANGUAGE plpgsql;



-- enter program id
/*
CREATE or REPLACE function latest_stream(int) RETURNS int
AS $$
    
DECLARE
    stream int;
    pe_id int;

BEGIN
    select id into pe_id from program_enrol

    return program;
end
$$ LANGUAGE plpgsql;
*/



-- Program enrolment id, semester the program_enrolment occurred and the 
-- starting date
create type prog_sem_starting as (peid int, semid int, starting date);

-- Retreive all program enrolments of a particular student,
-- Program ID, Semester starting date shown
create or replace function all_program_enrolments(int) 
    returns setof prog_sem_starting
as $$
declare
    r prog_sem_starting;
begin
    for r in select pe.id, sem.id, sem.starting
             from program_enrolments pe, semesters sem
             where pe.student = $1 and pe.semester = sem.id
    loop
        return next r;
    end loop;
end;
$$ language plpgsql;

-- Inputs: Student ID, Term ID
-- Output: program_enrolments.id
-- Example usage:

-- If the semester S falls after all known program enrolments for this student, the
-- use the last semester L of their enrolment to determine which program/stream they
-- were enrolled in,

