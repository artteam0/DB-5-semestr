-- 2
-- sqlplus / as sysdba
select name, description from v$parameter;

-- 3
--sqlplus sys/welcome123@localhost:51521/XEPDB1 as sysdba
select tablespace_name from DBA_TABLESPACES;
select file_name, tablespace_name from DBA_DATA_FILES;
select role from DBA_ROLES;
select username from DBA_USERS;

-- 4
-- sqlplus / as sysdba
-- echo "ORACLE_HOME: $ORACLE_HOME"
-- echo "ORACLE_SID: $ORACLE_SID" 
-- echo "ORACLE_BASE: $ORACLE_BASE"
-- echo "PATH: $PATH"

-- docker inspect oracle
select instance_name from v$instance;

-- 5
--sqlplus KAACORE/welcome123@localhost:51521/XEPDB1 as sysdba

-- 7
select table_name from user_tables;
select * from KAA_TABLE;

-- 8
HELP
HELP TIMING

SET TIMING ON
select * from KAA_TABLE;
SET TIMING OFF

-- 9
HELP DESCRIBE;
DESC KAA_TABLE;

-- 10
select segment_name from USER_SEGMENTS;

-- 11
CREATE OR REPLACE VIEW user_segments_all AS
SELECT 
    segment_type,
    COUNT(*) as segment_count,
    SUM(extents) as total_extents,
    SUM(blocks) as total_blocks,
    ROUND(SUM(bytes)/1024, 2) as total_size_kb
    FROM user_segments
GROUP BY segment_type;
select * from USER_SEGMENTS_ALL;
drop view user_segments_all;