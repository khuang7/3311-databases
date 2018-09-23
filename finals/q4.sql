-- COMP3311 12s1 Exam Q4
-- The Q4 view must have attributes called (team1,team2,matches)
-- Write an SQL view that gives the pair(s) of 
--teams that have played matches against each other the most number of times. 

-- The view should give the names of the teams and the number of matches played against each other. 
-- Since we don't want to have "duplicate pairs" (i.e. A+B as a pair and also B+A as a pair), 
--make sure that the name of the first team is always alphabetically less than the name of the second team.


drop view if exists count_of_teams_vs;
create view count_of_teams_vs
as
select i1.team as team1, i2.team as team2, count(*) as count
from involves i1, involves i2
where i1.match = i2.match
and i1.team < i2.team
group by i1.team, i2.team
;

drop view if exists Q4;
create view Q4
as

select t1.country as team1, t2.country as team2, cotv.count as matches
from count_of_teams_vs cotv, teams t1, teams t2
where cotv.team1 = t1.id
and cotv.team2 = t2.id
and cotv.count = (select max(count) from count_of_teams_vs)
;





