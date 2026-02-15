SET SERVEROUTPUT ON;

CREATE TABLE AUDITORIUM_TYPE (
    AUDITORIUM_TYPE CHAR(10) PRIMARY KEY,
    AUDITORIUM_TYPENAME VARCHAR2(30)
);
drop table AUDITORIUM;
drop table AUDITORIUM_TYPE;
drop table FACULTY;
drop table PULPIT;
drop table TEACHER;
drop table SUBJECT;

CREATE TABLE AUDITORIUM (
    AUDITORIUM CHAR(10) PRIMARY KEY,
    AUDITORIUM_NAME VARCHAR2(30),
    AUDITORIUM_CAPACITY NUMBER(4),
    AUDITORIUM_TYPE CHAR(10),
    CONSTRAINT FK_AUD_TYPE FOREIGN KEY (AUDITORIUM_TYPE) REFERENCES AUDITORIUM_TYPE(AUDITORIUM_TYPE)
);

CREATE TABLE FACULTY (
    FACULTY CHAR(10) PRIMARY KEY,
    FACULTY_NAME VARCHAR2(50)
);
alter table FACULTY modify (FACULTY_NAME VARCHAR2(100));

CREATE TABLE PULPIT (
    PULPIT CHAR(10) PRIMARY KEY,
    PULPIT_NAME VARCHAR2(100),
    FACULTY CHAR(10),
    CONSTRAINT FK_PUL_FAC FOREIGN KEY (FACULTY) REFERENCES FACULTY(FACULTY)
);

CREATE TABLE TEACHER (
    TEACHER CHAR(10) PRIMARY KEY,
    TEACHER_NAME VARCHAR2(100),
    PULPIT CHAR(10),
    CONSTRAINT FK_TEA_PUL FOREIGN KEY (PULPIT) REFERENCES PULPIT(PULPIT)
);
alter table TEACHER modify (TEACHER VARCHAR2(50));

CREATE TABLE SUBJECT (
    SUBJECT CHAR(10) PRIMARY KEY,
    SUBJECT_NAME VARCHAR2(100),
    PULPIT CHAR(10),
    CONSTRAINT FK_SUB_PUL FOREIGN KEY (PULPIT) REFERENCES PULPIT(PULPIT)
);

INSERT INTO FACULTY VALUES ('ФИТ', 'Факультет информационных технологий');
INSERT INTO FACULTY VALUES ('ИЭФ', 'Инженерно-экономический факультет');
INSERT INTO PULPIT VALUES ('ПИ', 'Программная инженерия', 'ФИТ');
INSERT INTO PULPIT VALUES ('ИСиТ', 'Информационные системы и технологии', 'ФИТ');
INSERT INTO PULPIT VALUES ('ЭУ', 'Экономика и управление', 'ИЭФ');
INSERT INTO TEACHER VALUES ('smelov', 'Смелов В.В.', 'ИСиТ');
INSERT INTO TEACHER VALUES ('dekan', 'Шиман Д.В.', 'ИСиТ');
INSERT INTO TEACHER VALUES ('T3', 'Иванов И.И.', 'ПИ');
INSERT INTO TEACHER VALUES ('T4', 'Петров П.П.', 'ПИ');
INSERT INTO TEACHER VALUES ('T5', 'Сидоров С.С.', 'ИСиТ');
INSERT INTO AUDITORIUM_TYPE VALUES ('ЛК', 'Лекционная');
INSERT INTO AUDITORIUM_TYPE VALUES ('ЛР', 'Лабораторная');
INSERT INTO AUDITORIUM VALUES ('322-1', 'Аудитория', 17, 'ЛР');
INSERT INTO AUDITORIUM VALUES ('301-1', 'Аудитория', 25, 'ЛР');
INSERT INTO AUDITORIUM VALUES ('204-1', 'Аудитория', 35, 'ЛР');
INSERT INTO AUDITORIUM VALUES ('200-3а', 'Аудитория', 350, 'ЛК');
INSERT INTO AUDITORIUM VALUES ('100-3а', 'Аудитория', 250, 'ЛК');
INSERT INTO AUDITORIUM VALUES ('408-2', 'Аудитория', 250, 'ЛК');
INSERT into SUBJECT VALUES ('БД', 'Базы данных', 'ПИ');
INSERT into SUBJECT VALUES ('ОС', 'Операционные системы', 'ПИ');
INSERT into SUBJECT VALUES ('СП', 'Системное программирование', 'ПИ');
COMMIT;

-- 1
BEGIN
   NULL;
END;
/

-- 2
BEGIN
    DBMS_OUTPUT.PUT_LINE('Hello World');
END;
/

-- 3
declare res number;
BEGIN
    res:=1/0;
    exception when others then
    DBMS_OUTPUT.PUT_LINE('Код: ' || SQLCODE);
    DBMS_OUTPUT.PUT_LINE('Сообщение: '||SQLERRM);
END;
/ 

-- 4
BEGIN
    DBMS_OUTPUT.PUT_LINE('внешний блок');
    BEGIN
        DBMS_OUTPUT.PUT_LINE('внутренний блок');
        RAISE_APPLICATION_ERROR(-20001, 'ошибка во вложенном блоке');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ошибка перехвачена во внутреннем блоке: ' || SQLERRM);
    END;
    DBMS_OUTPUT.PUT_LINE('продолжение верхнего блока');
END;
/

-- 5
select * from V$PARAMETER where name = 'plsql_warnings';

-- 6
select keyword from V$RESERVED_WORDS where LENGTH(KEYWORD)=1;

-- 7
select keyword from V$RESERVED_WORDS;

-- 8
select name, value from V$PARAMETER where name like 'plsql%';

DECLARE
    v_int1 NUMBER(5) := 10;
    v_int2 NUMBER(5) := 3;
    v_res_div NUMBER;
    v_res_mod NUMBER;
    v_fixed NUMBER(5,2) := 123.45;
    v_neg_scale NUMBER(5, -1) := 125; 
    v_float BINARY_FLOAT := 123.45f;
    v_double BINARY_DOUBLE := 123.456789d;
    v_sci NUMBER := 1.5E2;
    v_bool BOOLEAN := TRUE;
    
BEGIN
    v_res_div := v_int1 / v_int2;
    v_res_mod := MOD(v_int1, v_int2);

    DBMS_OUTPUT.PUT_LINE('v_int1 = ' || v_int1 || ', v_int2 = ' || v_int2);
    DBMS_OUTPUT.PUT_LINE('деление: ' || v_res_div);
    DBMS_OUTPUT.PUT_LINE('остаток: ' || v_res_mod);
    
    DBMS_OUTPUT.PUT_LINE('фикс. точка: ' || v_fixed);
    DBMS_OUTPUT.PUT_LINE('округдение: ' || v_neg_scale);
    DBMS_OUTPUT.PUT_LINE('Binary Float: ' || v_float);
    DBMS_OUTPUT.PUT_LINE('Binary Double: ' || v_double);
    DBMS_OUTPUT.PUT_LINE('е: ' || v_sci);
    
    IF v_bool THEN
        DBMS_OUTPUT.PUT_LINE('Boolean: TRUE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Boolean: FALSE');
    END IF;
END;
/

-- 18
DECLARE
    c_pi CONSTANT NUMBER := 3.1415;
    c_msg CONSTANT VARCHAR2(50) := 'константа';
BEGIN
    DBMS_OUTPUT.PUT_LINE(c_msg || ': ' || c_pi);
    -- c_pi := 3.14; 
END;
/

-- 19
DECLARE
    v_teacher_name TEACHER.TEACHER_NAME%TYPE;
BEGIN
    v_teacher_name := 'Смелов В.В.';
    DBMS_OUTPUT.PUT_LINE('преподаватель: ' || v_teacher_name);
    DBMS_OUTPUT.PUT_LINE('тип переменной из столбца таблицы');
END;
/

-- 20
DECLARE
    v_pulpit_rec PULPIT%ROWTYPE;
BEGIN
    SELECT * INTO v_pulpit_rec 
    FROM PULPIT 
    WHERE PULPIT = 'ПИ';
    
    DBMS_OUTPUT.PUT_LINE('аббревиатура: ' || v_pulpit_rec.PULPIT);
    DBMS_OUTPUT.PUT_LINE('название: ' || v_pulpit_rec.PULPIT_NAME);
    DBMS_OUTPUT.PUT_LINE('факультет: ' || v_pulpit_rec.FACULTY);
END;
/

-- 21
DECLARE
    v_x NUMBER := 40;
BEGIN
    IF v_x < 10 THEN
        DBMS_OUTPUT.PUT_LINE('X меньше 10');
    ELSIF v_x BETWEEN 10 AND 30 THEN
        DBMS_OUTPUT.PUT_LINE('X между 10 и 30');
    ELSE
        DBMS_OUTPUT.PUT_LINE('X больше 30');
    END IF;
END;
/

-- 23
DECLARE
    grade char(1 char) := 'а';
BEGIN
    CASE grade
        WHEN 'а' THEN DBMS_OUTPUT.PUT_LINE('удовлетворительно');
        WHEN 'б' THEN DBMS_OUTPUT.PUT_LINE('хорошо');
        WHEN 'в' THEN DBMS_OUTPUT.PUT_LINE('отлично');
        ELSE DBMS_OUTPUT.PUT_LINE('друн');
    END CASE;
END;
/

-- 24
DECLARE
    counter NUMBER := 1;
BEGIN
    LOOP
        DBMS_OUTPUT.PUT_LINE('итерация: ' || counter);
        counter := counter + 1;
        EXIT WHEN counter > 1000;
    END LOOP;
END;
/

-- 25
DECLARE
    counter NUMBER := 1;
BEGIN
    WHILE counter <= 5 LOOP
        DBMS_OUTPUT.PUT_LINE('while: ' || counter);
        counter := counter + 1;
    END LOOP;
END;
/

-- 26
BEGIN
    FOR i IN 1..5 LOOP
        DBMS_OUTPUT.PUT_LINE('for: ' || i);
    END LOOP;
END;
/