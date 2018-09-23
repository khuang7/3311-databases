CREATE FUNCTION sqr(num real) RETURNS real AS $$
BEGIN
    RETURN num*num;
END;
$$ LANGUAGE plpgsql;

