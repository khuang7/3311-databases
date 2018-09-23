drop table emp;




create table emp(empname text, salary integer, last_date timestamp, last_usr text);

create or replace function check_something() returns trigger
as $$
	

begin
	if (new.empname is null or new.salary < 0) then
		raise exception 'cant do this';
	end if;
	new.last_date := now();
	new.last_usr := current_user;
	return new;
end;
$$ language plpgsql;


create trigger q6 before INSERT or update on emp
	for each row execute procedure check_something();

