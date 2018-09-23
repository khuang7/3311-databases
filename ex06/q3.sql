
drop table T;
drop table S;
drop table R;



drop trigger q3a on r;
drop trigger q3b on r;
drop trigger q3b1 on r;

drop function check_primary();
drop function check_foreign();
drop function check_foreign_delete();

create table R(a int, b int, c text);
create table S(x int primary key, y int);
create table T(j int primary key, k int);


insert into s values (1, 2);
insert into t values (2, 1);


create function check_primary() returns trigger
as $$

declare
	_a int;
	_b int;
begin
	-- primary key constraint: not null
	if (new.a is null and new.b is null) then
		raise exception 'not null';
	end if;
	-- unique constraint
	select r.a, r.b into _a, _b
	from R
	where R.a = new.a and R.b = new.b;

	if (found) then
		raise exception 'not unique';
	end if;

	return new;
end;
$$ language plpgsql;

create function check_foreign() returns trigger
as $$
	
	declare
		_x int;


	begin 
	-- foreign key constraint: not null FOR TOTAL PARTICIPATION
	if (new.k is null) then
		raise exception 'not null for total participation';
	end if;

	select s.x into _x
	from s
	where s.x = new.k;

	if (not found) then
		raise exception 'whatever doesnt work';
	end if;

	return new;
end;
$$ language plpgsql;

create function check_foreign_delete() returns trigger
as $$
declare
	_x int;


begin

	select k into _x
	from t
	where t.k = old.x;

	if (found) then
		raise exception 'cannot delete because another tuple is referencing this';
	end if;
	return old;
end;
$$ language plpgsql;


create function check_foreign_update() returns trigger
as $$
	
declare
	_k int;
begin
	select k into _k
	from T
	where old.x = t.k;

	if (found) then
		raise exception 'cant do';
	end if;
	return new;
end;
$$ language plpgsql;




create trigger q3a before INSERT on R
	for each row execute procedure check_primary();

create trigger q3b before INSERT on T
	for each row execute procedure check_foreign();

create trigger q3b1 before DELETE on S
	for each row execute procedure check_foreign_delete();

create trigger q3b2 before UPDATE on S
 	for each row execute procedure check_foreign_update();



