-- COMP3311 12s1 Exam Q1
-- The Q1 view must have attributes called (team,matches)
-- Write an SQL view that gives the country name of each team and the number of matches it has played.


drop view if exists Q1;
create view Q1
as
	select t.country as team, count(match) as matches
	from teams t, involves i
	where t.id = i.team
	group by t.country
;
