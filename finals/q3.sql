-- COMP3311 12s1 Exam Q3
-- The Q3 view must have attributes called (team,players)

-- Write an SQL view that gives the country name of the team which has 
--the most players who have never scored a goal. 
-- The view should show the number of goal-less players, as well as the country name.

create view nogoals
as
select p.id as player
from players p left outer join goals g on p.id = g.scoredBy
where g.scoredBy is null
;


create view team_count_of_goaless
as
select t.country as team, count(*) as players
from players p, teams t
where p.memberOf = t.id
and p.id in (select player from nogoals)
group by t.country
;


drop view if exists Q3;
create view Q3
as

select team, players
from team_count_of_goaless tcog
where tcog.players = (select max(players) from team_count_of_goaless)
;
