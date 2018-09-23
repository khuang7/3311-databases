create or replace function
	sqr(n integer) returns integer
as $$
begin
	return n * n; 
end;
$$ language plpgsql;

-- When you select a scalar select sqr(16); INSTEAD of select * from sqr(16);

create or replace function
	fac(n integer) returns integer

as $$
declare
	result integer := 1; -- remmeber this
begin

	if (n < 0) then
		return null;
	end if;



	for i in 1..n loop
		result := result * i;
	end loop;

	return result;

end;
$$ language plpgsql;



create or replace function
	facr(n integer) returns integer
as $$



begin

	if (n < 0) then
		return null;
	end if;


	if (n = 1) then
		return 1;
	end if;

	return facr(n-1) * n;  


end;
$$ language plpgsql;



create type IntValue as ( val integer );

create or replace function 
	seq(n int) returns setof IntValue
as $$

declare
	i integer;
	r IntValue%rowtype;
begin
	for i in 1..n loop
		r.val = i;
		return next r;
	end loop; 
	return;

end;
$$ language plpgsql;


create or replace function seq1(lo int,hi int, inc int) returns setof IntValue
as $$

declare
	i integer;
	r IntValue%rowtype; -- remember this retarded line

begin
	
	if (inc = 0) then

		return ;
	end if;


	if (inc > 0) then

		i := lo;
		while (i <= hi) loop
			r.val = i;
			return next r;
			i := i + inc;
		end loop;

	elsif (inc < 0) then

		i := hi;
		while (i >= lo) loop
			r.val = i;
			return next r;
			i := i + inc;
		end loop;
	end if;


end;
$$ language plpgsql;



create or replace function 
	seqSQL(n int) returns setof IntValue
as $$

	select * from seq1(1,n,1);

$$ language sql;



