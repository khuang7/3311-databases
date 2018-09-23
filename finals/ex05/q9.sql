drop function hotels_in1(text);

CREATE FUNCTION hotels_in1(suburb text) RETURNS text AS $$
DECLARE

result text := 'Hotels in' || Suburb || ':\n';
r record;
counter int := 1;
count int :=0;

BEGIN

	
	select count(*) into count 
	from bars
	WHERE addr = suburb;
	if count = 0 then
		result := 'There are no hotels in ' || suburb;
	end if;


    FOR r IN select * from bars 
    WHERE addr = suburb
    LOOP
        result := result || to_char(counter,99) || '. ' ||  r.name || '\n';
    END LOOP;

    RETURN result;

END;
$$ LANGUAGE plpgsql;

