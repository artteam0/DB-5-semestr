-- 1-2
create table First_Task (
    ID number primary key,
    value varchar2(50)
);

BEGIN
    for i in 1..10 loop
    insert into First_Task (ID, value) values (i, 'value || i');
    end loop;
END;
/

drop table First_Task CASCADE CONSTRAINT;
drop table AUDIT_LOG CASCADE CONSTRAINT;


SHOW USER;
EXIT;

-- 9 (таблица для триггеров)
create table AUDIT_LOG (
    OperationDate DATE,
    OperationType VARCHAR2(20),
    TriggerName VARCHAR2(50),
    Data VARCHAR2(200)
);

-- 3
create or replace trigger trig_before
before insert or delete or update on First_Task
BEGIN
    DBMS_OUTPUT.PUT_LINE('trig_before');
    insert into AUDIT_LOG values (sysdate, 'commit', 'trig_before', 'start');
END;
/

-- 5-6
CREATE OR REPLACE TRIGGER trig_before_row
BEFORE INSERT OR DELETE OR UPDATE ON First_Task
FOR EACH ROW
DECLARE
    v_type VARCHAR2(20);
    v_data VARCHAR2(200);
BEGIN
    IF INSERTING THEN
        v_type := 'INSERT';
        v_data := 'NEW: ' || :NEW.ID || ' ' || :NEW.value;
    ELSIF UPDATING THEN
        v_type := 'UPDATE';
        v_data := 'OLD: ' || :OLD.ID || ' -> NEW: ' || :NEW.value;
    ELSIF DELETING THEN
        v_type := 'DELETE';
        v_data := 'OLD: ' || :OLD.ID;
    END IF;

    DBMS_OUTPUT.PUT_LINE('2. trig_before_row');
    INSERT INTO AUDIT_LOG VALUES (SYSDATE, v_type, 'trig_before_row', v_data);
END;
/

-- 7
create or replace trigger trig_after_stmt
after insert or delete or update on First_Task
BEGIN
    DBMS_OUTPUT.PUT_LINE('trig_after_stmt');
    INSERT INTO AUDIT_LOG VALUES (SYSDATE, 'STMT', 'trig_after_stmt', 'All done');
END;
/

-- 8
create or replace trigger trig_after_row
after insert or delete or update on First_Task
for each row
BEGIN
    DBMS_OUTPUT.PUT_LINE('trig_after_row');
    insert into AUDIT_LOG values (sysdate, 'ROW', 'trig_after_row', 'Finished row');
END;
/

INSERT INTO First_Task (ID, value) values (55, 'testtest');

-- 11
BEGIN
    insert into First_Task values (1, 'test_duplicate');
EXCEPTION when others then 
    DBMS_OUTPUT.PUT_LINE(sqlcode || sqlerrm);
END;
/

select * from AUDIT_LOG order by OperationDate DESC; --срабатывает автоматический rollback

-- 12
create or replace trigger del_table
before drop on SCHEMA
BEGIN
    IF ora_dict_obj_name = 'FIRST_TASK' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Нельзя удалять таблицу First_Task');
    END IF;
END;
/

drop TRIGGER del_table;

drop table First_Task;

-- 13
drop table AUDIT_LOG;
select trigger_name, status from USER_TRIGGERS where TABLE_NAME='FIRST_TASK';

INSERT INTO First_Task (ID, value) values (100, 'testdropaudit');

-- 14
create or replace view view_lab12 as select * from First_Task;

CREATE OR REPLACE TRIGGER trig_instead_of
INSTEAD OF INSERT ON view_lab12
BEGIN
    DBMS_OUTPUT.PUT_LINE('INSTEAD OF');
    INSERT INTO First_Task (ID, value) values (:NEW.ID, :NEW.value);
END;
/

insert into view_lab12 VALUES (25, 'test instead of');
commit;

-- 15
SET SERVEROUTPUT ON;
INSERT INTO First_Task (ID,value) values (79654, 'order');