drop table t_interval CASCADE CONSTRAINT;
drop table t_hash CASCADE CONSTRAINT;
drop table t_list CASCADE CONSTRAINT;
drop table t_range CASCADE CONSTRAINT;
drop table t_exchange CASCADE CONSTRAINT;

-- 1
create table t_range(
    id NUMBER,
    info VARCHAR2(100)
)

PARTITION BY range (id) (
    partition p1 values less than (100),
    partition p2 values less than (200),
    partition p3 values less than (300),
    partition pmax values less than (maxvalue)
) enable row movement;

-- 2
create table t_interval (
    create_date DATE,
    info VARCHAR2(50)
)

partition by range (create_date) interval (NUMTOYMINTERVAL(1, 'MONTH')) ( --1 шаг = 1 месяц
    partition startt values less than (TO_DATE('09.01.2026', 'DD.MM.YYYY'))
) enable row movement;

-- 3
create table t_hash (
    kkey VARCHAR2(50),
    value_hash VARCHAR2(50)
)

partition by hash (kkey) partitions 4
enable row MOVEMENT;

-- 4
create table t_list (
    category char(1),
    information VARCHAR2(50)
)

partition by list (category) (
    partition p_a values ('A'),
    partition p_b values ('B'),
    partition p_c values ('C'),
    partition p_def values (DEFAULT)
) enable row movement;

-- 5
BEGIN
    insert into t_range values (50,  '1 секция');
    insert into t_range values (150, '2 секция');
    insert into t_range values (250, '3 секция');
    insert into t_range values (400, 'maxvalue');

    insert into t_interval values (TO_DATE('26.12.2005', 'DD.MM.YYYY'), 'др 2005 год');
    insert into t_interval values (TO_DATE('09.05.2026', 'DD.MM.YYYY'), '9 мая 2026 год');
    insert into t_interval values (TO_DATE('05.08.2026', 'DD.MM.YYYY'), '5 августа 2026 год');

    insert into t_hash values ('key1', 'hash 1');
    insert into t_hash values ('key2', 'hash 2');
    insert into t_hash values ('key3', 'hash 3');
    insert into t_hash values ('key4', 'hash 4'); 

    insert into t_list values ('A', 'категория A');
    insert into t_list values ('B', 'категория B');
    insert into t_list values ('C', 'категория C');
    insert into t_list values ('Z', 'чето другое');
    commit;
END;
/

select * from t_range partition (p2);
select * from t_list partition (p_c);

-- 6
select 'before' as status, id, info from t_range partition(p1) where id=50;
update t_range set id=150 where id=50;
commit;
select 'old' as loc, id, info from t_range partition(p1);
select 'new' as loc, id, info from t_range partition(p1) where id=150;

-- 7
alter table t_range merge partitions p2, p3 into partition p23;
select * from t_range partition(p23);

-- 8
alter table t_range split partition pmax at (500)
into (partition p_500, partition pmax);

select * from t_range PARTITION(p_500);

-- 9
create table t_exchange (
    id NUMBER,
    info VARCHAR2(100)
);

insert into t_range values (10, 'exchange');
commit;

alter table t_range exchange partition p1
with table t_exchange;

select * from t_range PARTITION(p1);
select * from t_exchange;