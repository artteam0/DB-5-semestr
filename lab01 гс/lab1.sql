create table XXX_t(
    x number(3) primary key, 
    s varchar2(50)
);

-- 11
insert into XXX_t (x, s) values ('1', 'Dodge Durango SRT');
insert into XXX_t (x, s) values ('2', 'BMW e60 535d');
insert into XXX_t (x, s) values ('3', 'Вкусный Кебаб');
commit;

-- 12
update XXX_T set s='Не вкусный кебаб' where x=3;
update XXX_T set s='BMW M3 g81' where x=2;
commit;

-- 13
select * from XXX_T where s='Dodge Durango SRT';
select count(*) from XXX_T;

-- 14
delete from XXX_T where x=1;
commit;

-- 15
create table XXX_t1(
    x_2 number(3) primary key, 
    y number(3), 
    z varchar(50), 
    constraint xx foreign key (y) references XXX_t(x)
);

insert into XXX_t1(x_2, y, z) values (1, 2, 'вя');
commit;

select * from XXX_t left outer join XXX_t1
on XXX_t.x=XXX_t1.y;

select * from XXX_t right outer join XXX_t1
on XXX_t.x=XXX_t1.y;

select * from XXX_t inner join XXX_t1
on XXX_t.x=XXX_t1.y;

drop table XXX_t purge;
drop table XXX_t1 purge;

--purge, serv.



-- 1
create tablespace TS_KAA
datafile 'TS_KAA.dbf'
size 7M
AUTOEXTEND on next 5M
MAXSIZE 20M

DROP TABLESPACE TS_KAA INCLUDING CONTENTS AND DATAFILES;
select tablespace_name from dba_tablespaces where tablespace_name = 'TS_KAA';
-- 2
create TEMPORARY tablespace TS_KAA_TEMP
tempfile 'TS_KAA_TEMP.dbf'
size 5M
AUTOEXTEND on next 3M
MAXSIZE 30M

drop tablespace TS_KAA_TEMP;

-- 3
select tablespace_name, status, contents from DBA_TABLESPACES;
select FILE_NAME, tablespace_name, bytes/1024/1024 as size_mb from dba_data_files;

-- 4
create role RL_KAACORE
grant create session, create table, create view, create procedure to RL_KAACORE

drop role RL_KAACORE;

-- 5
select role from DBA_ROLES where role='RL_KAACORE';
select PRIVILEGE from DBA_SYS_PRIVS where GRANTEE = 'RL_KAACORE';

-- 6
create profile PF_KAACORE LIMIT
    PASSWORD_LIFE_TIME 180
    SESSIONS_PER_USER 3
    FAILED_LOGIN_ATTEMPTS 7
    PASSWORD_LOCK_TIME 1
    PASSWORD_REUSE_TIME 10 --1
    PASSWORD_GRACE_TIME DEFAULT --1
    CONNECT_TIME 180
    IDLE_TIME 30 --1

    drop profile PF_KAACORE;

-- 7
select profile from DBA_PROFILES;
select * from DBA_PROFILES where profile='PF_KAACORE';
select * from DBA_PROFILES where profile='DEFAULT'; 

-- 8
create user KAACORE1
IDENTIFIED by qwerty12345
DEFAULT TABLESPACE TS_KAA
TEMPORARY TABLESPACE TS_KAA_TEMP
profile PF_KAACORE
account UNLOCK
password EXPIRE;
commit;
drop user KAACORE;
grant RL_KAACORE to KAACORE1;

select * from all_users where username='KAACORE1';
-- 9
-- sqlplus
-- sqlplus kaacore/qwerty12345@//localhost:51521/oracle
-- alter user kaacore identified by 1111;

-- 10
create table last_ex(
    id number,
    description varchar2(100)
);

create view last_ex_view as 
select id, description
from last_ex
where id <100;

-- 11
create tablespace KAA_QDATA
datafile 'kaa_qdata.dbf' size 10M
offline;

alter tablespace KAA_QDATA online;

alter user KAACORE quota 2M on KAA_QDATA;

create table last_table(
    id_2 number,
    info varchar2(50)
)
tablespace KAA_QDATA

insert into last_table (id_2, info) values (1, 'a');
insert into last_table (id_2, info) values (2, 'aa');
insert into last_table (id_2, info) values (3, 'aaa');
commit;

select * from last_table;

drop tablespace KAA_QDATA
drop table last_table