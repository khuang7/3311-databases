-- takes a single argument giving the name of a suburb, and 
--returns the names of all hotels in that suburb, one per line. It is used as follows:


CREATE FUNCTION hotels_in(suburb text) RETURNS setof text AS $$

DECLARE

r record;
hotel text := '';


BEGIN
    FOR r IN select name into hotel from bars 
    WHERE addr = suburb
    LOOP
        -- can do some processing here
        RETURN NEXT r; -- return current row of SELECT
    END LOOP;
    RETURN;

END;
$$ LANGUAGE plpgsql;