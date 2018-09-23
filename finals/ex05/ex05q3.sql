-- select spread('My Text');

CREATE FUNCTION spread(my_text text) RETURNS text AS $$

DECLARE
result text := '';
len integer := 0;

BEGIN

	len = char_length(my_text);
	
    FOR i in 1 .. len LOOp
    	result := result || ' ' || substr(my_text, i, 1);

    END LOOP;

    return result;

END;
$$ LANGUAGE plpgsql;
