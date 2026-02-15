SET SERVEROUTPUT ON;

-- 1
declare
v_name AUDITORIUM.AUDITORIUM_NAME%TYPE;
v_cap AUDITORIUM.AUDITORIUM_CAPACITY%TYPE;
BEGIN
    select AUDITORIUM_NAME, AUDITORIUM_CAPACITY into v_name, v_cap from auditorium where AUDITORIUM='200-3а';
    DBMS_OUTPUT.PUT_LINE('аудитория: ' || v_name || ', вместимость: '||v_cap);
end;
/

-- 2
declare 
v_name AUDITORIUM.AUDITORIUM_NAME%TYPE;
BEGIN
    select AUDITORIUM_NAME into v_name from AUDITORIUM;
    exception when others then 
    DBMS_OUTPUT.PUT_LINE('ошибка: '||sqlcode);
    DBMS_OUTPUT.PUT_LINE('сообщение: '||sqlerrm);
end;
/

-- 3
declare v_name AUDITORIUM.AUDITORIUM_NAME%TYPE;
BEGIN
    select AUDITORIUM_NAME into v_name from AUDITORIUM;
    EXCEPTION
    when too_many_rows then
    DBMS_OUTPUT.PUT_LINE('err: запрос вернул более одной строки');
end;
/

-- 4
declare v_name AUDITORIUM.AUDITORIUM_NAME%TYPE;
BEGIN
    update AUDITORIUM set AUDITORIUM_CAPACITY=AUDITORIUM_CAPACITY where AUDITORIUM='qqq';
    if sql%notfound THEN
    DBMS_OUTPUT.PUT_LINE('строка не найдена '||sqlerrm);
    end if;

    select AUDITORIUM_NAME into v_name from auditorium where auditorium = 'qqq';
    exception when no_data_found THEN
    DBMS_OUTPUT.PUT_LINE('no data found '||sqlerrm);
end;
/
-- 5
BEGIN
    update AUDITORIUM set AUDITORIUM_CAPACITY = 100 where auditorium='200-3а';
    DBMS_OUTPUT.PUT_LINE('обновлено '||sql%rowcount||' строк');
    rollback;
    DBMS_OUTPUT.PUT_LINE('изменения отменены');
end;
/

-- 6
BEGIN
    update TEACHER set PULPIT='no_pulpit' where TEACHER='Смелов В.В.';
    exception when OTHERS then 
    DBMS_OUTPUT.PUT_LINE('ошибка целостности fk: '||sqlerrm);
end;
/

-- 7
BEGIN
    insert into AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_TYPE)
    values ('111-1', 'test1', 'ЛК');
    DBMS_OUTPUT.PUT_LINE('вставлено строк: '||sql%rowcount);
    rollback;
end;
/

-- 8
BEGIN
    insert into AUDITORIUM (AUDITORIUM, AUDITORIUM_NAME)
    values ('100-3а', 'дубликат');
    exception when dup_val_on_index THEN
    DBMS_OUTPUT.PUT_LINE('дублирование первичного ключа');
end;
/

-- 9
BEGIN
    delete from AUDITORIUM where AUDITORIUM='100-3а';
    DBMS_OUTPUT.PUT_LINE('удалено строк '||sql%rowcount);
    rollback;
end;
/

-- 10
select * from AUDITORIUM;

BEGIN
    delete from FACULTY where FACULTY='ФИТ';
    exception when others THEN
    DBMS_OUTPUT.PUT_LINE('удаление родителя с детьми '||sqlerrm);
    rollback;
end;
/

-- 11
DECLARE
    CURSOR c_teachers IS SELECT TEACHER_NAME, PULPIT FROM TEACHER;
    v_name TEACHER.TEACHER_NAME%TYPE;
    v_pulpit TEACHER.PULPIT%TYPE;
BEGIN
    OPEN c_teachers;
    LOOP
        FETCH c_teachers INTO v_name, v_pulpit;
        EXIT WHEN c_teachers%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('преподаватель: ' || v_name || ' (' || v_pulpit || ')');
    END LOOP;
    CLOSE c_teachers;
END;
/

-- 12
DECLARE
    CURSOR c_subj IS SELECT * FROM SUBJECT;
    v_rec SUBJECT%ROWTYPE;
BEGIN
    OPEN c_subj;
    FETCH c_subj INTO v_rec;
    
    WHILE c_subj%FOUND LOOP
        DBMS_OUTPUT.PUT_LINE('Предмет: ' || v_rec.SUBJECT_NAME);
        FETCH c_subj INTO v_rec;
    END LOOP;
    
    CLOSE c_subj;
END;
/

-- 13
DECLARE
    CURSOR c_join IS 
        SELECT p.PULPIT_NAME, t.TEACHER_NAME FROM PULPIT p JOIN TEACHER t ON p.PULPIT = t.PULPIT;
BEGIN
    FOR r IN c_join LOOP
        DBMS_OUTPUT.PUT_LINE(r.PULPIT_NAME || ': ' || r.TEACHER_NAME);
    END LOOP;
END;
/

-- 14
DECLARE
    CURSOR c_aud(min_c NUMBER, max_c NUMBER) IS
        SELECT AUDITORIUM, AUDITORIUM_CAPACITY 
        FROM AUDITORIUM 
        WHERE AUDITORIUM_CAPACITY BETWEEN min_c AND max_c;
        
    v_aud AUDITORIUM.AUDITORIUM%TYPE;
    v_cap AUDITORIUM.AUDITORIUM_CAPACITY%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('< 20');
    OPEN c_aud(0, 19);
    LOOP
        FETCH c_aud INTO v_aud, v_cap;
        EXIT WHEN c_aud%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_aud || v_cap);
    END LOOP;
    CLOSE c_aud;
    
    DBMS_OUTPUT.PUT_LINE('21-60');
    OPEN c_aud(21, 60);
    FETCH c_aud INTO v_aud, v_cap;
    WHILE c_aud%FOUND LOOP
        DBMS_OUTPUT.PUT_LINE(v_aud || v_cap);
        FETCH c_aud INTO v_aud, v_cap;
    END LOOP;
    CLOSE c_aud;
    
    DBMS_OUTPUT.PUT_LINE('> 81');
    FOR r IN c_aud(81, 500) LOOP
        DBMS_OUTPUT.PUT_LINE(r.AUDITORIUM || r.AUDITORIUM_CAPACITY);
    END LOOP;
END;
/

-- 15
DECLARE
    TYPE t_ref IS REF CURSOR; --
    cur_var t_ref;
    v_capacity NUMBER(4);
BEGIN
    OPEN cur_var FOR SELECT AUDITORIUM_CAPACITY FROM AUDITORIUM WHERE AUDITORIUM_CAPACITY > 50;
    LOOP
        FETCH cur_var INTO v_capacity;
        EXIT WHEN cur_var%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Вместимость: ' || v_capacity);
    END LOOP;
    CLOSE cur_var;
END;
/

-- 16
DECLARE
    CURSOR c_complex IS
        SELECT * FROM AUDITORIUM 
        WHERE AUDITORIUM_TYPE IN (SELECT AUDITORIUM_TYPE FROM AUDITORIUM_TYPE WHERE AUDITORIUM_TYPE LIKE 'ЛК%');
BEGIN
    FOR r IN c_complex LOOP
        DBMS_OUTPUT.PUT_LINE('лекционные: ' || r.AUDITORIUM);
    END LOOP;
END;
/

-- 17
DECLARE
    CURSOR c_upd IS 
        SELECT AUDITORIUM_CAPACITY FROM AUDITORIUM WHERE AUDITORIUM_CAPACITY BETWEEN 40 AND 80
        FOR UPDATE;
BEGIN
    FOR AUDITORIUM IN c_upd LOOP
        UPDATE AUDITORIUM 
        SET AUDITORIUM_CAPACITY = AUDITORIUM.AUDITORIUM_CAPACITY * 0.9 WHERE CURRENT OF c_upd;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('обновление выполнено.');
    ROLLBACK;
END;
/

-- 18
DECLARE
    CURSOR c_del IS 
        SELECT AUDITORIUM FROM AUDITORIUM WHERE AUDITORIUM_CAPACITY <= 20
        FOR UPDATE;
    v_id AUDITORIUM.AUDITORIUM%TYPE;
BEGIN
    OPEN c_del;
    FETCH c_del INTO v_id;
    WHILE c_del%FOUND LOOP
        DELETE FROM AUDITORIUM WHERE CURRENT OF c_del;
        DBMS_OUTPUT.PUT_LINE('удалена аудитория: ' || v_id);
        FETCH c_del INTO v_id;
    END LOOP;
    CLOSE c_del;
    ROLLBACK;
END;
/

-- 19
DECLARE
    v_rowid UROWID;
    v_cap NUMBER;
BEGIN
    SELECT ROWID, AUDITORIUM_CAPACITY INTO v_rowid, v_cap FROM AUDITORIUM WHERE AUDITORIUM = '322-1';
    UPDATE AUDITORIUM SET AUDITORIUM_CAPACITY = v_cap + 1 WHERE ROWID = v_rowid;
    DBMS_OUTPUT.PUT_LINE('обновлено по ROWID.');
    rollback;
END;
/
-- 20
DECLARE
    CURSOR c_teachers IS 
        SELECT TEACHER_NAME FROM TEACHER ORDER BY TEACHER_NAME;
        
    v_counter NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('преподаватели:');
    
    FOR r IN c_teachers LOOP
        v_counter := v_counter + 1;
        DBMS_OUTPUT.PUT_LINE(v_counter || '. ' || r.TEACHER_NAME);
        IF MOD(v_counter, 3) = 0 THEN
            DBMS_OUTPUT.PUT_LINE('======');
        END IF;
    END LOOP;
END;
/