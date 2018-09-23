-- accepts the name of a hotel, the name of a beer and the number of dollars 
-- to deduct from the price, and returns a new price. 
--The procedure should check for the following errors:


-- select happyHourPrice('Oz Hotel','New',0.50);

drop function happyhourprice1(text, text, real);

CREATE FUNCTION happyHourPrice1(_suburb text, _beer text, _deduct real) RETURNS text AS $$



DECLARE

suburb_count int := 0;
beer_count int := 0;
beer_in_suburb int := 0;
original_price real;

BEGIN

select count(*) into suburb_count 
from bars 
where name = _suburb;
select count(*) into beer_count 
from beers
where name = _beer;

select count(*) into beer_in_suburb
from sells s, beers be, bars ba
where s.bar = ba.id
and s.beer = be.id
and be.name = _beer
and ba.name = _suburb;

select s.price into original_price
from sells s, beers be, bars ba
where s.bar = ba.id
and s.beer = be.id
and be.name = _beer
and ba.name = _suburb;


if suburb_count = 0 then
	return 'There is no hotel in ' || _suburb;
elsif beer_count = 0 then
	return 'There is no beer called ' || _beer;

elsif beer_in_suburb = 0 then
	return 'The' || _suburb || 'does not serve' || _beer;

elsif original_price < _deduct then
	return 'Price reduction is too large bla bla suburb and beer';
else 
	original_price := original_price - _deduct; --tochar here
	return 'Happy hour price for ' || _beer || ' at ' || _suburb || 'is $' || original_price;
end if;


END;
$$ LANGUAGE plpgsql;