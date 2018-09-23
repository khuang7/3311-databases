-- COMP3311 12s1 Exam Q5
-- The Q5 view must have attributes called (team,reds,yellows)
-- Write an SQL view that produces a list of how many times each type of "card" 
--(yellow or red) has been awarded against each team. 
--(Note: We regard a card as being awarded "against a team" when it is 
-- awarded against one of the players on that team.)





-- ID | Colour
drop view if exists player_id_red_card_type;
create view player_id_red_card_type
as
	select * as nred
	from players p left outer join cards c on (p.id = c.givenTo)
	where c.cardTYpe = 'red'
;




drop view if exists player_id_yellow_card_type;
create view player_id_yellow_card_type
as
	select t.country as country, count(*) as nyellow
	from teams t left outer join players p on t.id = p.memberOf
	              join cards c on c.givenTo = p.id
	where c.cardTYpe = 'yellow'
	group by t.country;
;


drop view if exists yellow_card_countries;
-- Country | Yellow Cards
create view yellow_card_countries
as

	select t.country as country, count(pdyct.nyellow) as yellows
	from teams t 
	left outer join player_id_yellow_card_type pdyct on t.country = pdyct.country
;

drop view if exists red_card_countries;
create view red_card_countries
as
	select t.country as country, count(pdrct.nred) as red
	from teams t 
	left outer join player_id_red_card_type pdrct on t.country = pdrct.country
	group by t.country, red
;
/*
drop view if exists Q5;
create view Q5
as

;
*/