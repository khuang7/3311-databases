-- COMP3311 12s1 Exam Q2
-- The Q2 view must have one attribute called (player,goals)
-- Write an SQL view that gives the names of all players who have scored 
-- more than one goal that is rated as "amazing".
-- Each tuple in the result should also include the number of amazing goals scored.


drop view if exists Q2;
create view Q2
as

select p.name as player, count(*) as goals
from goals g, players p
where g.rating = 'amazing'
and g.scoredBy = p.id
group by p.name
having count(*) > 1

;
