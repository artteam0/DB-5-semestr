ALTER TABLE SUBJECT DISABLE CONSTRAINT FK_SUB_PUL;
ALTER TABLE TEACHER DISABLE CONSTRAINT FK_TEA_PUL;
ALTER TABLE PULPIT DISABLE CONSTRAINT FK_PUL_FAC;

TRUNCATE TABLE SUBJECT;
TRUNCATE TABLE TEACHER;
TRUNCATE TABLE PULPIT;
TRUNCATE TABLE FACULTY;

ALTER TABLE PULPIT ENABLE CONSTRAINT FK_PUL_FAC;
ALTER TABLE TEACHER ENABLE CONSTRAINT FK_TEA_PUL;
ALTER TABLE SUBJECT ENABLE CONSTRAINT FK_SUB_PUL;

INSERT INTO FACULTY (FACULTY, FACULTY_NAME) VALUES ('ФИТ', 'Фак. Информационных Технологий');
INSERT INTO FACULTY (FACULTY, FACULTY_NAME) VALUES ('ИЭФ', 'Инженерно-Экономический');

INSERT INTO PULPIT (PULPIT, PULPIT_NAME, FACULTY) VALUES ('ИСиТ', 'Информационные Системы', 'ФИТ');
INSERT INTO PULPIT (PULPIT, PULPIT_NAME, FACULTY) VALUES ('ПИ', 'Программная Инженерия', 'ФИТ');
INSERT INTO PULPIT (PULPIT, PULPIT_NAME, FACULTY) VALUES ('ЭУ', 'Экономика и Управление', 'ИЭФ');


INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) VALUES ('PETROV', 'Петров П.П.', 'ИСиТ');
INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) VALUES ('SMELOV', 'Смелов В.В.', 'ПИ');
INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) VALUES ('SHIMAN', 'Шиман Д.В.', 'ПИ');
INSERT INTO TEACHER (TEACHER, TEACHER_NAME, PULPIT) VALUES ('SIDOROV', 'Сидоров С.С.', 'ЭУ');

INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) VALUES ('БД', 'Базы Данных', 'ПИ');
INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) VALUES ('ОС', 'Операционные Системы', 'ПИ');
INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) VALUES ('СЯП', 'Скр. Языки Программирования', 'ИСиТ');
INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) VALUES ('СП', 'Системное Программирование', 'ИСиТ');
INSERT INTO SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) VALUES ('МКЭ', 'Макроэкономика', 'ЭУ');

COMMIT;

-- 1
DECLARE
    PROCEDURE GET_TEACHERS(p_pulpit in TEACHER.PULPIT%TYPE) IS
    cursor firstTask IS
    select TEACHER_NAME from TEACHER where PULPIT=p_pulpit;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('преподаватели каферы '|| p_pulpit ||': ');
        for r in firstTask LOOP
            DBMS_OUTPUT.PUT_LINE(r.TEACHER_NAME);
        END LOOP;
    END;

    BEGIN
        GET_TEACHERS('ПИ');
        GET_TEACHERS('ИСиТ');
    END;
    /

-- 2-3
DECLARE
    FUNCTION GET_NUM_TEACHERS(p_pulpit in TEACHER.PULPIT%TYPE) 
    return number IS count_teachers number;
BEGIN
    select count(*) into count_teachers
    from TEACHER where PULPIT=p_pulpit;
    return count_teachers;
END;

BEGIN
    DBMS_OUTPUT.PUT_LINE('преподаватели исита: '||GET_NUM_TEACHERS('ИСиТ'));
    DBMS_OUTPUT.PUT_LINE('преподаватели пи: '||GET_NUM_TEACHERS('ПИ'));
END;
/

-- 4
create or replace procedure GET_TEACHERS_BY_FACULTY(p_faculty in FACULTY.FACULTY%TYPE) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('факультет: '||p_faculty);
    for r in (
        select t.TEACHER_NAME, p.PULPIT
        from TEACHER t join PULPIT p on t.PULPIT=p.PULPIT
        where p.FACULTY=p_faculty) LOOP
    DBMS_OUTPUT.PUT_LINE(r.TEACHER_NAME||'  '||r.PULPIT);
    END LOOP;
END;
/

create or replace procedure GET_SUBJECTS(p_pulpit SUBJECT.PULPIT%TYPE) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('предметы кафедры: '||p_pulpit);
    for r in (select SUBJECT_NAME from SUBJECT where PULPIT = p_pulpit) LOOP
        DBMS_OUTPUT.PUT_LINE(r.SUBJECT_NAME);
    END LOOP;
END;
/

BEGIN
    GET_TEACHERS_BY_FACULTY('ФИТ');
    GET_SUBJECTS('ПИ');
END;
/

-- 5
create or replace FUNCTION GET_NUM_TEACHERS_FACULTY(p_faculty in FACULTY.FACULTY%TYPE) 
return number is count_teach number;
BEGIN
    select count(*) into count_teach from TEACHER t
    join PULPIT p on t.PULPIT=p.PULPIT where p.FACULTY=p_faculty;
    return count_teach;
END;
/

create or replace function GET_NUM_SUBJECTS(p_pulpit in SUBJECT.PULPIT%TYPE)
return number is count_subj number;
BEGIN
    select count(*) into count_subj from SUBJECT
    where PULPIT=p_pulpit;
    return count_subj;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('кол-во преподавателей фита: '||GET_NUM_TEACHERS_FACULTY('ФИТ'));
    DBMS_OUTPUT.PUT_LINE('предметов на пи: ' || GET_NUM_SUBJECTS('ПИ'));
    DBMS_OUTPUT.PUT_LINE('предметов на эу: ' || GET_NUM_SUBJECTS('ЭУ'));
END;
/

-- 6
CREATE OR REPLACE PACKAGE TEACHERS IS
    PROCEDURE GET_TEACHERS_BY_FACULTY(p_faculty in FACULTY.FACULTY%TYPE);
    PROCEDURE GET_SUBJECTS(p_pulpit SUBJECT.PULPIT%TYPE);
    FUNCTION GET_NUM_TEACHERS_FACULTY(p_faculty in FACULTY.FACULTY%TYPE) RETURN NUMBER;
    FUNCTION GET_NUM_SUBJECTS(p_pulpit in SUBJECT.PULPIT%TYPE) RETURN NUMBER;
END TEACHERS;
/


CREATE OR REPLACE PACKAGE BODY TEACHERS IS

    PROCEDURE GET_TEACHERS_BY_FACULTY(p_faculty in FACULTY.FACULTY%TYPE) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('факультет: '||p_faculty);
        for r in (
            select t.TEACHER_NAME, p.PULPIT
            from TEACHER t join PULPIT p on t.PULPIT=p.PULPIT
            where p.FACULTY=p_faculty) LOOP
        DBMS_OUTPUT.PUT_LINE(r.TEACHER_NAME||'  '||r.PULPIT);
        END LOOP;
    END GET_TEACHERS_BY_FACULTY;

    PROCEDURE GET_SUBJECTS(p_pulpit SUBJECT.PULPIT%TYPE) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('предметы кафедры: '||p_pulpit);
        for r in (select SUBJECT_NAME from SUBJECT where PULPIT = p_pulpit) LOOP
            DBMS_OUTPUT.PUT_LINE(r.SUBJECT_NAME);
        END LOOP;
    END GET_SUBJECTS;

    FUNCTION GET_NUM_TEACHERS_FACULTY(p_faculty in FACULTY.FACULTY%TYPE) 
    return number is count_teach number;
    BEGIN
        select count(*) into count_teach from TEACHER t
        join PULPIT p on t.PULPIT=p.PULPIT where p_faculty=p_faculty;
        return count_teach;
    END GET_NUM_TEACHERS_FACULTY;

    function GET_NUM_SUBJECTS(p_pulpit in SUBJECT.PULPIT%TYPE)
    return number is count_subj number;
    BEGIN
        select count(*) into count_subj from SUBJECT
        where PULPIT=p_pulpit;
        return count_subj;
    END GET_NUM_SUBJECTS;

END TEACHERS;
/


-- 7
BEGIN
    TEACHERS.GET_TEACHERS_BY_FACULTY('ФИТ');
    TEACHERS.GET_SUBJECTS('ПИ');
    DBMS_OUTPUT.PUT_LINE('кол-во преподавателей фита: '||TEACHERS.GET_NUM_TEACHERS_FACULTY('ФИТ'));
    DBMS_OUTPUT.PUT_LINE('предметов на пи: ' || TEACHERS.GET_NUM_SUBJECTS('ПИ'));
END;
/