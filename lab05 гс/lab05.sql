-- 1
select * from v$sga;
-- 2
select component, current_size from v$sga_dynamic_components;
-- 3
select component, granule_size from V$SGA_DYNAMIC_COMPONENTS;
-- 4
select component, current_size from V$SGA_DYNAMIC_COMPONENTS where COMPONENT='free memory';
-- 5
select name, value from V$PARAMETER where name in ('sga_max_size', 'sga_target', 'memory_target');
-- 6
select name, block_size, current_size from V$BUFFER_POOL where name in ('DEFAULT', 'KEEP', 'RECYCLE');
-- 7
create table keep_tbl (
    id number primary key,
    data varchar2(100)
) storage (buffer_pool keep);

select segment_name, tablespace_name, buffer_pool from USER_SEGMENTS where segment_name='KEEP_TBL';
-- 8
create table default_tbl (
    id number primary key,
    description varchar2(200)
);

select segment_name, tablespace_name, buffer_pool from USER_SEGMENTS where segment_name='DEFAULT_TBL';
-- 9
select * from V$SGAINFO where name = 'Redo Buffers';
-- 10
select pool, name, bytes from V$SGASTAT where pool = 'large pool' and name = 'free memory';
-- 11
select username, program, server from v$session where status = 'ACTIVE';
-- 12
select program from V$PROCESS where BACKGROUND=1; -- pid spid
-- 13
select spid, program, username, terminal, background from v$process where background = 0;
-- 14
select count(*) from v$bgprocess where name like 'DBW%' and paddr !='00'; -- paddr !=00;
-- 15
DESC v$services;
select name, name_hash, network_name, creation_date, goal, pdb from V$SERVICES;
-- 16
select name, value from V$PARAMETER where name like '%dispatcher%';
-- 17
--sc query | find /i "Oracle" ???
-- 18

-- 19

-- 20 

-- 17
-- docker exec -it oracle sh -c "ps -ef | grep tnslsnr"

--18
-- cat /opt/oracle/oradata/dbconfig/XE/listener.ora
--19
-- docker exec -it oracle lsnrctl

--20
-- docker exec -it oracle lsnrctl services
