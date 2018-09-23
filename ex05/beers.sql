create or replace function hotelsIn(suburb text) returns text
as $$
declare
	r record;
	result text = '';
begin
	for r in select name from bars where addr = suburb loop
		result := result || r.name || '\n';
	end loop;
	return result;
end;
$$ language plpgsql;





create or replace function hotelsIn2 (suburb text) returns text
as $$
declare
	r record;
	result text := 'Hotels in' || suburb || ':' ;
begin
	for r in select * from bars where addr = suburb loop
		result := result || ' ' || r.name;
	end loop;
	return result;
end;
$$ language plpgsql;





create or replace function hotelsIn3 (suburb text) returns text
as $$
declare
	r record;
	result text := 'Hotels in ' || suburb || '\n' ;
	howmany integer;
	counter integer := 1;

begin

	select count(*) into howmany from bars where addr = suburb;


	if (howmany <= 0) then
		return 'There are no hotels in ' || suburb || '\n';
	end if;

	for r in select * from bars where addr = suburb loop
		result := result || ' ' || to_char(counter, '99') || '. ' || r.name || '\n';
		counter := counter + 1;

	end loop;
	

	return result;
end;
$$ language plpgsql;








create or replace function 
happyHourPrice(hotelname text, beername text, discount real) returns text
as $$

declare
	real_price real;
	happy_hour_price real;
	howmany integer;
	barid integer;
	beerid integer;
begin
	select bars.id into barid from bars where name = hotelname;
	if (barid is null) then
		return 'There is no hotel called ' || hotelname;
	end if;

	select beers.id into beerid from Beers where name = beername;
	if (beerid is null) then
		return 'There is no beer called' || beername;
	end if;


	select price into real_price from sells where bar = barid and beer = beerid;
	if (real_price is null) then
		return 'The ' || hotelname || ' does not serve' || beername;
	end if;

	if (real_price < discount) then
		return 'Price reduction is too large; ' || beername || 'only costs' || real_price;
	else
		happy_hour_price := real_price - discount;
		return 'Happy hour price for ' || beername || ' at ' || hotelname || ' is ' || happy_hour_price;
	end if;
end;

$$ language plpgsql;



create or replace function hotelsInyallah(text) returns setof Bars
as $$ 

	select * from Bars where addr = $1;

$$ language sql;





 create or replace function hotelsInyallah1(text) returns setof Bars
as $$ 

declare
	r record;
begin
	for r in select * from Bars where addr = $1 loop
 		return next r;
	end loop;
end;
$$ language plpgsql;



-- Q14 BANK DATABASE STUFF

create or replace function 14a1(employee text) returns real
as $$ 

	select salary from employees where name = employee;

$$ language sql;




