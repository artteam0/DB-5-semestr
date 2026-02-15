-- 1
create tablespace TS_KAA
datafile '/opt/oracle/oradata/XE/XEPDB1/TS_KAA.dbf'
size 7M
AUTOEXTEND on next 5M
MAXSIZE 20M

DROP TABLESPACE TS_KAA INCLUDING CONTENTS AND DATAFILES;
select tablespace_name from dba_tablespaces where tablespace_name = 'TS_KAA';
-- 2
create TEMPORARY tablespace TS_KAA_TEMP
tempfile '/opt/oracle/oradata/XE/XEPDB1/TS_KAA_TEMP.dbf'
size 5M
AUTOEXTEND on next 3M
MAXSIZE 30M;

DROP TABLESPACE TS_KAA_TEMP INCLUDING CONTENTS AND DATAFILES;
drop tablespace TS_KAA_TEMP;

-- 3
select tablespace_name, status, contents from DBA_TABLESPACES;
select FILE_NAME, tablespace_name from dba_data_files;

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
    PASSWORD_REUSE_TIME 10
    PASSWORD_GRACE_TIME DEFAULT
    CONNECT_TIME 180
    IDLE_TIME 30

    drop profile PF_KAACORE;

-- болокировка аккаунта
-- блокировка пароля после ввода
-- 7
select profile from DBA_PROFILES;
select * from DBA_PROFILES where profile='PF_KAACORE';
select * from DBA_PROFILES where profile='DEFAULT'; 

-- 8
create user KAACORE
IDENTIFIED by qwerty12345
DEFAULT TABLESPACE TS_KAA
TEMPORARY TABLESPACE TS_KAA_TEMP
profile PF_KAACORE
account UNLOCK
password EXPIRE;
commit;
drop user KAACORE;
grant RL_KAACORE to KAACORE;
-- 9
-- sqlplus
-- sqlplus kaacore/qwerty12345@//localhost:51521/oracle
-- alter user kaacore identified by 1111;
GRANT create SESSION to KAACORE;
grant create table to KAACORE;
grant create view to KAACORE;
grant create procedure to KAACORE; 
grant create tablespace to KAACORE;
-- 10
create table last_ex(
    id number,
    description varchar2(100)
);

drop table last_ex;
create view last_ex_view as 
select id, description
from last_ex
where id <100;

-- 11
create tablespace KAA_QDATA  --/opt/oracle/XE/XEPDB1/kaa_qdata.dbf
datafile '/opt/oracle/oradata/XE/XEPDB1/kaa_qdata1111.dbf' size 10M
offline;

drop tablespace KAA_QDATA INCLUDING CONTENTS and DATAFILES;
alter tablespace KAA_QDATA online;

alter user KAACORE quota 2M on KAA_QDATA;

create table last_table(
    id_2 number,
    info varchar2(50)
)
tablespace KAA_QDATA
drop table last_table;
insert into last_table (id_2, info) values (1, 'a');
insert into last_table (id_2, info) values (2, 'aa');
insert into last_table (id_2, info) values (3, 'aaa');
commit;

select * from last_table;

drop tablespace KAA_QDATA INCLUDING CONTENTS and DATAFILES;
drop table last_table