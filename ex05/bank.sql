
-- Q14 BANK DATABASE STUFF

create or replace function q14a1(employee text) returns real
as $$ 

	select salary from employees where name = employee;

$$ language sql;




create or replace function q14a2(employee text) returns real
as $$ 

declare 
salary real;

begin

	select employees.salary into salary from employees where name = employee;

	return salary;
end;

$$ language plpgsql;


create or replace function q14b1(_branch text) returns branches
as $$ 
	select * from branches where location = _branch;
$$ language sql;






create or replace function q14b2 (_branch text) returns setof branches
as $$

declare
	r record;

begin
	for r in select * from branches where location = _branch loop
		return next r;
	end loop;
end;

$$ language plpgsql;



create or replace function q14c1(_sal real) returns setof text
as $$
	select name from employees where salary > _sal;
$$ language sql;


create or replace function q14c2(_sal real) returns setof text
as $$
declare
	r record;
begin
	for r in select name from employees where salary > _sal loop
		return next r;
	end loop;
end;


$$ language plpgsql;



-- Q15


create or replace function q15(_branch text) returns text
as $$

declare
	_name text :='';
	_address text := '';
	_customer text := '';
	_total real := 0;
	_add real := 0;
	_customername text :='';
	r record ;

begin
	select location, address into _name, _address from branches where location = _branch;


	for r in select name from customers where address = _branch loop

		select balance into _add from accounts where holder = r.name;
		_total := _total + _add;
		_customer := _customer || r.name;

	end loop;
return 'Branch: ' || _name || ' ' || _address || '\n' || 'Customers: ' || _customer || '\n' || 'Total Deposits:  $' || _total;
end;
$$ language plpgsql;


-- Q16





