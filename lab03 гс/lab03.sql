SELECT name, cdb FROM v$database;

-- 1
SELECT name, open_mode FROM v$pdbs;

-- 2
SELECT instance_name, host_name, status FROM v$instance;

-- 3
SELECT comp_name, version, status FROM dba_registry;

-- 4
ALTER SESSION SET CONTAINER = CDB$ROOT;

CREATE PLUGGABLE DATABASE KAA_PDB
ADMIN USER pdbadmin IDENTIFIED BY "1111"
ROLES=(DBA)
FILE_NAME_CONVERT=('/opt/oracle/oradata/XE/pdbseed/', '/opt/oracle/oradata/XE/KAA_PDB/'); -- зачем два файла

ALTER PLUGGABLE DATABASE KAA_PDB OPEN;
ALTER PLUGGABLE DATABASE KAA_PDB SAVE STATE;

ALTER PLUGGABLE DATABASE KAA_PDB CLOSE IMMEDIATE;
DROP PLUGGABLE DATABASE KAA_PDB INCLUDING DATAFILES;

-- 5
SELECT name, open_mode FROM v$pdbs WHERE name = 'KAA_PDB';

-- 6
ALTER SESSION SET CONTAINER = KAA_PDB;

CREATE TABLESPACE TS_KAA
DATAFILE 'D:\уник\5 сем\БД\lab03\datafile1.dbf'
SIZE 7M
AUTOEXTEND ON NEXT 5M
MAXSIZE 20M;
drop TABLESPACE TS_KAA;

CREATE ROLE RL_KAA;

GRANT 
    CREATE SESSION,
    CREATE TABLE, DROP ANY TABLE,
    CREATE VIEW, DROP ANY VIEW,
    CREATE PROCEDURE, DROP ANY PROCEDURE
TO RL_KAA;
drop role RL_KAA;

CREATE PROFILE PF_KAA LIMIT
    PASSWORD_LIFE_TIME 180
    SESSIONS_PER_USER 3
    FAILED_LOGIN_ATTEMPTS 7
    PASSWORD_LOCK_TIME 1
    PASSWORD_REUSE_TIME 10
    PASSWORD_GRACE_TIME DEFAULT
    CONNECT_TIME 180
    IDLE_TIME 30;
drop profile PF_KAA;

CREATE USER USERKAA_PDB IDENTIFIED BY 12345
DEFAULT TABLESPACE TS_KAA
PROFILE PF_KAA
ACCOUNT UNLOCK;
drop user UserKAA_PDB CASCADE;

GRANT RL_KAA TO USERKAA_PDB;
GRANT UNLIMITED TABLESPACE TO USERKAA_PDB;

-- 7
CREATE TABLE KAA_table (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(50)
);

INSERT INTO KAA_table (id, name) VALUES (1, 'Artsiom');
INSERT INTO KAA_table (id, name) VALUES (2, 'Arseniiy');
INSERT INTO KAA_table (id, name) VALUES (3, 'Pavel');
INSERT INTO KAA_table (id, name) VALUES (4, 'Vlad');
INSERT INTO KAA_table (id, name) VALUES (5, 'Vadim');
INSERT INTO KAA_table (id, name) VALUES (6, 'Ilya');
INSERT INTO KAA_table (id, name) VALUES (7, 'Anton');
INSERT INTO KAA_table (id, name) VALUES (8, 'Misha');
INSERT INTO KAA_table (id, name) VALUES (9, 'Vasya');
INSERT INTO KAA_table (id, name) VALUES (10, 'Vanya');
COMMIT;

SELECT * FROM KAA_table;
DESC KAA_table;

-- 8
SELECT tablespace_name, status, contents 
FROM user_tablespaces;

SELECT granted_role, admin_option, default_role
FROM user_role_privs;

SELECT privilege, table_name, grantable
FROM user_tab_privs;

SELECT username, user_id, account_status, created
FROM user_users;

SELECT tablespace_name, status, contents, logging
FROM user_tablespaces;

-- 9
ALTER SESSION SET CONTAINER = CDB$ROOT;

CREATE USER C##KAA IDENTIFIED BY 1111
CONTAINER = ALL;
GRANT CREATE SESSION TO C##KAA CONTAINER = ALL;

drop user C##KAA cascade;

ALTER SESSION SET CONTAINER = KAA_PDB;
GRANT CREATE SESSION TO C##KAA;