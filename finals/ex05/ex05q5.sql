create type IntValue as ( val integer );

create or replace function seq(int,int,int) returns setof IntValue AS $$

DECLARE
	r IntValue%rowtype;
	i int := $1;

BEGIN

	if ($1 < $2 and $3 > 0) then
		
		WHILE i <= $2 LOOP
    		r.val := i;
    		i := i + $3;
			return next r;
		END LOOP;

	elsif ($1 > $2 and $3 < 0) then
		WHILE i >= $2 LOOP
    		r.val := i;
    		i := i + $3;

			return next r;
		END LOOP;

	end if; 


END;
$$ LANGUAGE plpgsql;


