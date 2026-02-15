-- 1
alter table TEACHER add (
    BIRTHDAY DATE,
    SALARY NUMBER(10,2)
);

-- 2
BEGIN
    update TEACHER set BIRTHDAY = TO_DATE('04.01.1960', 'DD.MM.YYYY'), SALARY=2500 where TEACHER_NAME LIKE 'Смелов%';
    update TEACHER set BIRTHDAY = TO_DATE('25.05.1980', 'DD.MM.YYYY'), SALARY=3000 where TEACHER_NAME LIKE 'Шиман%';
    update TEACHER set BIRTHDAY = TO_DATE('05.01.1985', 'DD.MM.YYYY'), SALARY=1800 where TEACHER_NAME LIKE 'Иванов%';
    update TEACHER set BIRTHDAY = TO_DATE('14.09.1996', 'DD.MM.YYYY'), SALARY=1800 where TEACHER_NAME LIKE 'Петров%';
    update TEACHER set BIRTHDAY = TO_DATE('11.11.1990', 'DD.MM.YYYY'), SALARY=950 where TEACHER_NAME LIKE 'Сидоров%';
END;
/

select * from TEACHER;

select * from TEACHER where REGEXP_LIKE(TEACHER_NAME, '^[С]');

--регулярные выражения (написать первое задание через регулярные выражения)

-- 3
select TEACHER_NAME, BIRTHDAY, TO_CHAR(BIRTHDAY, 'DAY', 'NLS_DATE_LANGUAGE=RUSSIAN') as "День недели"
from TEACHER where TO_CHAR(BIRTHDAY, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN')='MON';

-- 4
create or replace view birth_next_month AS
select TEACHER_NAME, BIRTHDAY from TEACHER
where EXTRACT(MONTH from BIRTHDAY)=EXTRACT(MONTH from ADD_MONTHS(sysdate, 1));

select * from birth_next_month;

-- 5
create or replace view stat_month AS
select TO_CHAR(BIRTHDAY, 'Month', 'NLS_DATE_LANGUAGE = RUSSIAN') AS "Месяц",
count(*) as "Количество" from TEACHER
group by TO_CHAR(BIRTHDAY, 'Month', 'NLS_DATE_LANGUAGE = RUSSIAN');

select * from stat_month;

-- 6
declare
    cursor jubilee IS
    select TEACHER_NAME, BIRTHDAY from TEACHER;

    next_year NUMBER;
    birth_year NUMBER;
    age NUMBER;
BEGIN  
    next_year := TO_NUMBER(TO_CHAR(sysdate, 'YYYY')) + 1;
    for r in jubilee LOOP
    birth_year:=TO_NUMBER(TO_CHAR(r.BIRTHDAY, 'YYYY'));
    age:=next_year-birth_year;
    if mod(age,10)=0 THEN
    DBMS_OUTPUT.PUT_LINE(r.TEACHER_NAME||age);
    end if;
    end loop;
END;
/

-- 7
DECLARE
    cursor stats IS
    select f.FACULTY_NAME, p.PULPIT_NAME, FLOOR(AVG(t.SALARY)) AS avg_sal
    FROM FACULTY f
    JOIN PULPIT p ON f.FACULTY = p.FACULTY
    JOIN TEACHER t ON p.PULPIT = t.PULPIT
    GROUP BY ROLLUP(f.FACULTY_NAME, p.PULPIT_NAME);
        
    fac_name FACULTY.FACULTY_NAME%TYPE;
    pul_name PULPIT.PULPIT_NAME%TYPE;
    avg_num NUMBER;
BEGIN
    open stats; loop
        fetch stats into fac_name, pul_name, avg_num;
        EXIT WHEN stats%NOTFOUND;
        if fac_name IS NOT NULL AND pul_name IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('Кафедра ' || pul_name || ': ' || avg_num);
            
        elsif fac_name IS NOT NULL AND pul_name IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Среднее по факультету: ' || fac_name || ': ' || avg_num);
            
        elsif fac_name IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Среднее по всему унииверу: ' || avg_num);
        end if;
    end loop;
    close stats;
END;
/

-- 8
DECLARE
    type address is RECORD(
        city VARCHAR2(50),
        street VARCHAR2(50)
    );
    TYPE person IS RECORD (
        fio VARCHAR2(100),
        age NUMBER,
        addr address
    );
    teacher1 person;
    teacher2 person;
BEGIN
    teacher1.fio:='Смелов В.В.';
    teacher1.age:=65;
    teacher1.addr.city:='Минск';
    teacher1.addr.street := 'Свердлова 13';

    teacher2:=teacher1;
    teacher2.fio:='Смелов копия';
    DBMS_OUTPUT.PUT_LINE('1: '||teacher1.fio);
    DBMS_OUTPUT.PUT_LINE('2: '||teacher2.fio);
END;
/