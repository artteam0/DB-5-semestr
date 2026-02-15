
BEGIN
    for r in (select table_name from user_tables where table_name in ('T_Source', 'T_Archive', "T_Log")) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE '||r.table_name;
    end loop;
END;
/

create table T_Source (id number, data VARCHAR2(50));
create table T_Archive (id NUMBER, data VARCHAR2(50), moved_date DATE);
create table T_Log (status VARCHAR2(50), message VARCHAR2(100), log_date DATE);

BEGIN 
    for i in 1..20 loop
    insert into T_SOURCE values (i, 'data '||i);
    end loop;
END;
/

create or replace PROCEDURE job_data IS
count_rows NUMBER:=0;
errormsg VARCHAR2(500);
BEGIN
    insert into T_ARCHIVE (id, data, moved_date)
    select id, data, SYSDATE from T_SOURCE;

    delete from T_SOURCE;

    count_rows:=SQL%ROWCOUNT;
    insert into T_LOG (status, message, log_date) values ('успех', 'перенесено строк: '||count_rows, SYSDATE);
    commit;
EXCEPTION
    when others then rollback;
    errormsg:=SQLERRM;
    insert into T_LOG values ('err', errormsg, SYSDATE);
    commit;
END;
/


create or replace PACKAGE PKG_JOB IS
PROCEDURE START_JOB;
PROCEDURE CHECK_STATUS;
PROCEDURE STOP_JOB;
END PKG_JOB;
/

create or replace PACKAGE BODY PKG_JOB is
job_num NUMBER;
PROCEDURE START_JOB IS
BEGIN
    DBMS_JOB.SUBMIT(job_num, 'JOB_DATA;', SYSDATE, 'SYSDATE+7');
    commit;
    DBMS_OUTPUT.PUT_LINE('задание через DBMS_JOB id: '||job_num);
end START_JOB;

PROCEDURE CHECK_STATUS IS
cursor first IS
    select job, last_date, next_date, broken, failures 
    from USER_JOBS where what like '%JOB_DATA%';
BEGIN
    for r in first LOOP
    DBMS_OUTPUT.PUT_LINE('id: '||r.job);
    DBMS_OUTPUT.PUT_LINE('последний запуск: '||r.last_date);
    DBMS_OUTPUT.PUT_LINE('следующий запуск: ' || r.next_date);
    DBMS_OUTPUT.PUT_LINE('ошибок: ' || r.failures);
    if r.broken = 'Y' then
        DBMS_OUTPUT.PUT_LINE('broken (остановлено)');
    else
        DBMS_OUTPUT.PUT_LINE('активно');
    end if;
end loop;

DBMS_OUTPUT.PUT_LINE('последние записи в логах');
    for r in (select * from T_LOG order by log_date desc fetch first 3 rows only) LOOP
    DBMS_OUTPUT.PUT_LINE(r.log_date||': '||r.status||' - '||r.message);
end loop;

end CHECK_STATUS;

procedure STOP_JOB IS
qq number;
BEGIN
    select job into qq from USER_JOBS where what like '%JOB_DATA%' and rownum=1;
    DBMS_JOB.REMOVE(qq);
    commit;
    DBMS_OUTPUT.PUT_LINE('задание ' || qq || ' удалено');
EXCEPTION
    when no_data_found then 
    DBMS_OUTPUT.PUT_LINE('не найдено');
end STOP_JOB;

END PKG_JOB;
/


create or replace PACKAGE PKG_SCHEDULER IS
    PROCEDURE START_SCHEDULER;
    PROCEDURE STOP_SCHEDULER;
    PROCEDURE CHECK_STATUS;
end PKG_SCHEDULER;
/

create or replace PACKAGE  body PKG_SCHEDULER IS
c_job_name CONSTANT VARCHAR2(100) := 'JOB_WEEK_COPY';

PROCEDURE START_SCHEDULER IS
BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
            job_name        => c_job_name,
            job_type        => 'STORED_PROCEDURE',
            job_action      => 'JOB_DATA',
            start_date      => SYSDATE,
            repeat_interval => 'FREQ=WEEKLY; INTERVAL=1',
            enabled         => TRUE
        );
        DBMS_OUTPUT.PUT_LINE('scheduler Job ' || c_job_name || ' создан.');
END START_SCHEDULER;

PROCEDURE STOP_SCHEDULER IS
BEGIN
    DBMS_SCHEDULER.DROP_JOB(c_job_name);
    DBMS_OUTPUT.PUT_LINE('scheduler Job удален.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('задание не найдено');
END STOP_SCHEDULER;
    
PROCEDURE CHECK_STATUS IS
    v_state VARCHAR2(30);
    last_run TIMESTAMP;
BEGIN
    BEGIN
        SELECT state, last_start_date INTO v_state, last_run 
        FROM USER_SCHEDULER_JOBS 
        WHERE job_name = c_job_name;
            
        DBMS_OUTPUT.PUT_LINE('задание: ' || c_job_name);
        DBMS_OUTPUT.PUT_LINE('состояние: ' || v_state);
        DBMS_OUTPUT.PUT_LINE('последний старт: ' || last_run);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('задание ' || c_job_name || ' не создано.');
    END;
END CHECK_STATUS;
END PKG_SCHEDULER;
/



BEGIN
    DBMS_OUTPUT.PUT_LINE('DBMS_JOB');
    INSERT INTO T_SOURCE VALUES (100, 'Test 1');
    INSERT INTO T_SOURCE VALUES (101, 'Test 2');
    COMMIT;
    PKG_JOB.START_JOB;

    PKG_JOB.CHECK_STATUS;
    
    PKG_JOB.STOP_JOB;
    
    
    DBMS_OUTPUT.PUT_LINE('ТЕСТ DBMS_SCHEDULER');
    INSERT INTO T_SOURCE VALUES (200, 'Test Scheduler');
    COMMIT;
    
    PKG_SCHEDULER.START_SCHEDULER;
    PKG_SCHEDULER.CHECK_STATUS;
    PKG_SCHEDULER.STOP_SCHEDULER;
END;
/

SELECT * FROM T_LOG;



BEGIN
    DELETE FROM T_LOG;
    DELETE FROM T_SOURCE;
    INSERT INTO T_SOURCE VALUES (100, 'Test Data DBMS_JOB');
    INSERT INTO T_SOURCE VALUES (200, 'Test Data SCHEDULER');
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('DBMS_JOB');
    PKG_JOB.START_JOB;
    DECLARE
        v_job NUMBER;
    BEGIN
        SELECT job INTO v_job FROM USER_JOBS WHERE what LIKE '%JOB_DATA%' AND ROWNUM=1;
        DBMS_JOB.RUN(v_job);
        DBMS_OUTPUT.PUT_LINE(v_job || ' выполнено принудительно');
    EXCEPTION 
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Ошибка запуска: ' || SQLERRM);
    END;
    
    PKG_JOB.CHECK_STATUS;
    PKG_JOB.STOP_JOB;
    
    DBMS_OUTPUT.PUT_LINE('DBMS_SCHEDULER');
    PKG_SCHEDULER.START_SCHEDULER;
    
    BEGIN
        DBMS_SCHEDULER.RUN_JOB('JOB_WEEK_COPY');
        DBMS_OUTPUT.PUT_LINE('Scheduler Job выполнен принудительно');
    EXCEPTION 
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Ошибка запуска Scheduler: ' || SQLERRM);
    END;
    
    PKG_SCHEDULER.CHECK_STATUS;
    PKG_SCHEDULER.STOP_SCHEDULER;
END;
/

SELECT * FROM T_LOG;