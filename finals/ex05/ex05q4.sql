create type IntValue as ( val integer );


create or replace function seq(int) returns setof IntValue AS $$
DECLARE
	r IntValue%rowtype;
	i integer;
BEGIN
	
	FOR i in 1 .. $1 LOOP
		r.val := i;
		return next r;
	END LOOP;
	

END;
$$ LANGUAGE plpgsql;
