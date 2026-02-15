-- 1
select file_name, tablespace_name from DBA_DATA_FILES;
select file_name, tablespace_name from DBA_TEMP_FILES;

-- 2
CREATE TABLESPACE KAA_QDATA
DATAFILE '/opt/oracle/oradata/XE/XEPDB1/KAA_QDATA1.dbf' SIZE 10m
OFFLINE;
drop TABLESPACE KAA_QDATA INCLUDING CONTENTS;

alter TABLESPACE KAA_QDATA ONLINE;
CREATE USER KAA IDENTIFIED by 1111;
GRANT CREATE SESSION TO KAA;
GRANT CREATE TABLE TO KAA;
GRANT UNLIMITED TABLESPACE TO KAA;
GRANT CREATE ANY PROCEDURE TO KAA;

ALTER USER KAA QUOTA 2M ON KAA_QDATA;

--KAA
CREATE TABLE KAA_T1 (
    id NUMBER PRIMARY KEY,
    data VARCHAR2(100)
) TABLESPACE KAA_QDATA;

INSERT INTO KAA_T1 VALUES (1, 'Кулешов');
INSERT INTO KAA_T1 VALUES (2, 'Артем');
INSERT INTO KAA_T1 VALUES (3, 'Алексеевич');
COMMIT;

-- 3
SELECT segment_name, segment_type from dba_segments where TABLESPACE_NAME='KAA_QDATA';

-- 4
drop table KAA_T1;
SELECT segment_name, segment_type from dba_segments where TABLESPACE_NAME='KAA_QDATA';
SELECT object_name, original_name, operation from USER_RECYCLEBIN;

-- 5
FLASHBACK TABLE KAA_T1 to before DROP;
select table_name from user_tables where table_name='KAA_T1';
SELECT segment_name, segment_type FROM dba_segments WHERE tablespace_name = 'KAA_QDATA';

-- 6
drop table KAA_T1 purge;

BEGIN
  FOR i IN 1..10000 LOOP
    INSERT INTO KAA_T1 (id, data) VALUES (i, i);
  END LOOP;
  COMMIT;
END;
/
SELECT COUNT(*) FROM KAA_T1;

-- 7
select segment_name, count(*) as extent_count, sum(blocks) as total_blocks, sum(bytes) as total_size_mb
from dba_extents where SEGMENT_NAME='KAA_T1'
group by segment_name;
select extent_id, file_id, block_id, blocks, bytes as size_kb
from dba_extents where segment_name='KAA_T1'
order by EXTENT_ID;

-- 8
drop tablespace KAA_QDATA INCLUDING CONTENTS and DATAFILES CASCADE CONSTRAINT;
select tablespace_name from DBA_TABLESPACES where TABLESPACE_NAME='KAA_QDATA';

-- 9
--sys
select  group#, thread#, sequence#, bytes as size_mb, members, archived, status, first_time
from v$log order by group#;
select group#, status from v$log where status='CURRENT';

-- 10
select group#, member, type from v$logfile order by group#;

-- 14
SELECT log_mode FROM v$database;
SELECT archiver FROM v$instance;

-- 15
select count(*) as archive_count FROM v$archived_log;
select sequence# as last_archive_number, name as archive_file_name, completion_time
from v$archived_log where sequence# = (select max(sequence#) from v$archived_log);

-- 19
select name from v$controlfile;
select name, is_recovery_dest_file, block_size, file_size_blks 
from v$controlfile;

-- 20
select type, record_size, records_total, records_used 
from v$controlfile_record_section;

-- 21
select value from v$parameter where name = 'spfile';

-- 22
create pfile='/tmp/KAA_PFILE.ORA' from spfile;
select name, value from v$parameter
where name in ('db_name', 'db_block_size', 'processes', 'sessions');

-- 23
select value from v$parameter where name='remote_login_passwordfile';

-- 24
select * from v$diag_info;
select name, value from v$parameter 
where name in ('diagnostic_dest', 'background_dump_dest', 'user_dump_dest', 'core_dump_dest');


-- EX
-- 11
alter session set container=CDB$ROOT;
select to_char(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') as start_time from dual;
alter system switch LOGFILE;
select group#, status, sequence# from v$log where status = 'CURRENT';
select to_char(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') as switch1 from dual;

-- 12
alter database add logfile group 4(
    '/opt/oracle/oradata/XE/XEPDB1/new11.log',
    '/opt/oracle/oradata/XE/XEPDB1/new22.log',
    '/opt/oracle/oradata/XE/XEPDB1/new33.log'
) size 50M;
select group# as size_mb, members, status from v$log;
select group#, member from v$logfile where group# = 4;

-- 13
alter database drop logfile group 4;
select group# from v$log where group#=4;

-- 16
SELECT log_mode FROM v$database;
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;

-- 17
alter session set container=cdb$ROOT;
alter SYSTEM archive log current;

select sequence# as last_archive_number, name as archive_file_name, completion_time
from v$archived_log 
where sequence# = (select MAX(sequence#) from v$archived_log);

-- 18
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE NOARCHIVELOG;
ALTER DATABASE OPEN;
SELECT log_mode FROM v$database;

-- 25
SELECT name, value FROM v$diag_info;

-- 26
SELECT tablespace_name FROM dba_tablespaces WHERE tablespace_name = 'KAA';
SELECT file_name FROM dba_data_files WHERE file_name = 'KAA';
SELECT file_name FROM dba_temp_files WHERE file_name = 'KAA';
SELECT table_name FROM dba_tables WHERE owner = 'KAA';
SELECT username FROM dba_users WHERE username = 'KAA';
drop user KAA;
SELECT original_name FROM dba_recyclebin WHERE owner = 'KAA';
SELECT group# FROM v$log WHERE group# >= 4;