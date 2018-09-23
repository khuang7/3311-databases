drop function fac(integer);

CREATE FUNCTION fac(num integer) RETURNS integer AS $$
DECLARE

	result integer := 1 ;


BEGIN

	IF num < 0 THEN
		return null;
	end if;

	WHILE num > 0 LOOP
	    result := result * num;
	    num = num - 1;
	END LOOP;
	return result;
END;
$$ LANGUAGE plpgsql;



	
/*
	IF num < 0 THEN
		return null;
	end if;

	IF num = 0 THEN
    	return 1;
	END IF;
    RETURN fac(num - 1) * num;
*/