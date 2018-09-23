-- What beers are made by Toohey's?
create view q4a
as
    select name
    from beers
    where manf = 'Toohey''s' --dont really understand how ' works
;


create view q4b
as
    select name as Beer, manf as Brewer
    from beers;
;


create view q4c
as
    
    select b.manf --REMEMBER DISTINCT!
    from likes l, beers b, drinkers d, 
    where l.beer = b.id
    and l.drinker = d.id
    and d.name = 'John';
;

-- Find pairs of beers by the same manufacturer.
create view q4d
as 

select b1.name, b2.name
from beers b1, beers b2
where b1.manf = b2.manf
and b1.name < b2.name  -- the answers used b1.name < b2.name; instead?
;

--Find beers that are the only one by their brewer.
create view q4e
as

;

-- Find the beers sold at bars where John drinks.
create view q4f
as
    select be.name
    from frequents f, drinkers d, bars b, sells s, beers be
    where f.drinker = d.id
    and b.id = s.bars
    and be.id = s.beer
    and d.name = 'John'
;

-- How many different beers are there?
create view q4g
as 
    select count(*)
    from beers
;


-- How many different brewers are there?
create view q4h
as
    select count(distinct manf)
    from beers
;

-- How many beers does each brewer make?
create view q4i
as
    select brewer, count(name) as count
    from beers
    group by brewer
;

-- Which brewer makes the most beers?
create view q4j
as
select brewer from q4i
where count = (select max(count) from q4i)
;

-- Bars where either Gernot or John drink.
create view q4k
as



