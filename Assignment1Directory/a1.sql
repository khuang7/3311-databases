-- COMP3311 18s1 Assignment 1
-- Written by Kevin Huang z3461590, April 2018

-- Q1: ...

create or replace view Q1(unswid, name)
as
    select p.unswid, p.name as name
    from people p
    where p.id in (select ce.student
                   from course_enrolments ce
                   group by ce.student
                   having count(*) > 65)
;


-- Count the number of students that are not staff members
create or replace view students_only(nstudents)
as
    select count(*)
    from students s
    where s.id not in (select st.id from staff st)
;


-- Count the number of staff members that are not students
create or replace view staff_only(nstaff)
as
    select count(*)
    from staff st
    where st.id not in (select s.id from students s)
;


-- Count the number of people who are both student and staff members.
create or replace view both_student_staff(nboth)
as
    select count(*)
    from students s
    where s.id in (select st.id from staff st)
;


-- Q2: ...

create or replace view Q2(nstudents, nstaff, nboth)
as
    select (select * from students_only), 
           (select * from staff_only),
           (select * from both_student_staff)
;


-- Retreives the staff id of staff who have been 'Lecturer in Charge' and
-- the number of times they have been in charge.
create or replace view lic_count(id, num_times_lic)
as
    select cs.staff, count(cs.staff)
    from course_staff cs, staff_roles sr
    where cs.role = sr.id and sr.name = 'Course Convenor'
    group by cs.staff
;


-- Retreives the staff id(s) of staff who have been 'Lecturer in Charge' the most
-- and the number of times they have been in charge
create or replace view most_count_id(id, num_times_lic)
as
    select lc1.id, lc1.num_times_lic
    from lic_count lc1
    where lc1.num_times_lic = (select max(lc2.num_times_lic)
                               from lic_count lc2)
;


-- Q3: ...

create or replace view Q3(name, ncourses)
as
    select p.name, m.num_times_lic
    from people p, most_count_id m
    where p.id = m.id
;


-- Q4: ...

create or replace view Q4a(id)
as
    select p.unswid
    from people p, program_enrolments pe, semesters s, programs pr
    where p.id = pe.student and pe.program = pr.id and pe.semester = s.id and 
          pr.code = '3978'and s.year = 2005 and s.term = 'S2'
;


create or replace view Q4b(id)
as
    select p.unswid
    from people p, program_enrolments pe, semesters sem,
         streams s, stream_enrolments se
    where p.id = pe.student and pe.semester = sem.id and 
                 se.partof = pe.id and s.id = se.stream and 
                 sem.year = 2005 and sem.term = 'S2' and s.code = 'SENGA1'
;


create or replace view Q4c(id)
as
    select p.unswid
    from people p, program_enrolments pe, programs pr, orgunits o, semesters sem
    where p.id = pe.student and pe.program = pr.id and pe.semester = sem.id and
          pr.offeredby = o.id and o.longname = 'School of Computer Science and Engineering' and
          sem.year = 2005 and sem.term = 'S2'
;


-- Q5: ...

create or replace view faculty_committees(faculty_id, no_committees)
as
    select facultyOf(ou.member), count(*)
    from orgunit_groups ou, orgunit_types ot, orgunits o
    where facultyOf(ou.member) is not null
                               and ou.member = o.id
                               and o.utype = ot.id and ot.name = 'Committee'
    group by facultyOf(ou.member)
;


create or replace view Q5(name)
as
    select o.name
    from faculty_committees fc, orgunits o
    where fc.faculty_id = o.id
    and fc.no_committees = (select max(no_committees)
                            from faculty_committees fc1)
;


-- Q6: ...

create or replace function Q6(integer) returns text
as $$
    select p.name
    from people p
    where p.id = $1 or p.unswid = $1;
$$ language sql
;


-- Q7: ...

create or replace function Q7(text)
    returns table (course text, year integer, term text, convenor text)
as $$
    select $1, sem.year, text(sem.term), text(p.name)
    from subjects sub, courses c, course_staff cs, staff_roles sr,
         semesters sem, people p
    where sub.id = c.subject and c.semester = sem.id and c.id = cs.course and
          cs.role = sr.id and p.id = cs.staff and sr.name = 'Course Convenor' and 
          sub.code = $1
$$ language sql
;


-- Q8: ...

create or replace function Q8(integer)
    returns setof NewTranscriptRecord
as $$
declare
    r record;
    er NewTranscriptRecord;
    wam_row NewTranscriptRecord;
    peopleid integer;
    semesterid integer;
    term text;
    year text;
    subjectid integer;
    programid integer;
    wam real := 0;
    total_uoc real := 0;
    uoc_passed real := 0;
    current real := 0;
begin
    select p.id into peopleid 
    from people p, students s
    where p.unswid = $1 and p.id = s.id;
    if not found then
        return;
    end if;
    for r in select * from course_enrolments ce where ce.student = peopleid loop
        select c.semester into semesterid from courses c where c.id = r.course;
        select lower(s.term), s.year into term, year from semesters s where s.id = semesterid;
        select c.subject into subjectid from courses c where c.id = r.course;
        er.term := substring(year from 3 for 2) || term; 
        select sub.code, sub.uoc into er.code, er.uoc from subjects sub where sub.id = subjectid;
        select pe.program into programid from program_enrolments pe 
        where pe.student = r.student and pe.semester = semesterid;
        select p.code into er.prog from programs p where p.id = programid;
        select substring(sub.name from 1 for 20) into er.name from subjects sub where sub.id = subjectid;
        er.mark := r.mark;
        er.grade := r.grade;
        if (r.grade = 'SY') then
            uoc_passed := uoc_passed + er.uoc;
        elsif (r.mark is not null) then
            if (r.grade in ('PT', 'PC', 'PS', 'CR', 'DN', 'HD', 'A', 'B', 'C')) then
                uoc_passed := uoc_passed + er.uoc;
            end if;
            total_uoc := total_uoc + er.uoc;
            current := current + (er.uoc * er.mark);
            if (er.grade not in ('PT', 'PC', 'PS', 'CR', 'DN', 'HD', 'A', 'B', 'C')) then
                er.uoc := 0;
            end if;
        end if;
        return next er;
    end loop;
    if (total_uoc = 0) then
        wam_row := (null, null, null, 'No WAM available', null, null, null);
    else
        wam_row := (null, null, null, 'Overall WAM', floor(current/total_uoc), null, uoc_passed);
    end if;
    return next wam_row;
end;
$$ language plpgsql
;


-- Given a pattern returns the appropriate regex expression.
create or replace function q9_helper(_pattern text)
    returns text
as $$
declare
    lo int;
    hi int;
    counter int;
    result text ='';
begin
    if _pattern ~ '^\w{4}\d#{3}$' then
        _pattern := substr(_pattern, 1, 5);
	elsif _pattern ~  '\[\d-\d\]' then        
        select (regexp_matches (_pattern, '(\d)-(\d)'))[1] into lo;
        select (regexp_matches (_pattern, '(\d)-(\d)'))[2] into hi;
        for i in lo..hi loop
            result := result || i;
        end loop;
        _pattern := regexp_replace(_pattern, '(\d)-(\d)', result);
    end if;
    _pattern := regexp_replace(_pattern, '#|x','\\w', 'g' );
    return _pattern;
end;
$$ language plpgsql;


-- Q9: --

create or replace function Q9(integer)
    returns setof AcObjRecord
as $$
declare
    _pattern text;
    _gtype text;
    r record;
    ao AcObjRecord;
    result text:= '';
    i text;
begin
    select definition, gtype into _pattern, _gtype 
    from acad_object_groups 
    where id = $1 and gdefby = 'pattern';
    foreach i in array regexp_split_to_array(_pattern, ',') loop
        if _pattern ~ '\{.*\}' or _pattern ~ '\/F=' then
            return;
        elsif (i ~ '^FREE' or i ~ '^GENG' or i ~ '^ZGEN') then
            if _gtype = 'subject' then
                ao := ('subject', i);
                return next ao;
            end if;
        end if;
        result :=  result || ' or code ~ '|| '''' || q9_helper(i) || '''';	
    end loop;
    if _gtype = 'subject' then
        for r in execute 'select distinct s.code from subjects s where s.id is null' || result loop
            ao.object := r.code;
            ao.objtype := 'subject';
            return next ao;
        end loop;
    end if;
end;
$$ language plpgsql
;
