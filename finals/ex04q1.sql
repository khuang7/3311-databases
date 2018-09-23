DROP TABLE IF EXISTS SUPPLIERS;
DROP TABLE IF EXISTS PARTS;
DROP TABLE IF EXISTS CATALOGUE;




CREATE TABLE Suppliers (
    sid integer,
    sname text,
    address text,

    primary key(sid)
);

CREATE TABLE Parts (
    pid integer,
    pname text,
    colour text,

    primary key(pid)
);

CREATE TABLE Catalogue (
    pid integer,
    sid integer,
    cost numeric,

    primary key(pid, sid),
    foreign key(sid) references Suppliers(sid),
    foreign key(pid) references Parts(pid)
);


INSERT into Suppliers VALUES(10, 'Optus', 'Home');
INSERT into Suppliers VALUES(20, 'Telstra', 'Home1');
INSERT into Suppliers VALUES(30, 'Vodafone', 'Home2');


INSERT into parts VALUES(1, 'telephone', 'black');
INSERT into parts VALUES(2, 'mobile', 'red');
INSERT into parts VALUES(3, 'phone line', 'green');


INSERT into Catalogue Values(1,10, '20');
INSERT into Catalogue VALUES(2,10, '30');
INSERT into Catalogue Values(1,30, '40');
INSERT into Catalogue VALUES(3,30, '10');

INSERT into Catalogue VALUES(3,10, '50');

