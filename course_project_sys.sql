ALTER DATABASE OPEN;
alter session set "_ORACLE_SCRIPT"=true;

--- создание табличных пространств
create tablespace  agency_ts
DATAFILE 'agency_ts.dbf' 
SIZE 10m
AUTOEXTEND ON NEXT 10m MAXSIZE UNLIMITED;

create temporary tablespace  agency_ts_tmp
TempFILE 'agency_ts_temp.dbf' 
SIZE 10m
     AUTOEXTEND ON NEXT 10m MAXSIZE UNLIMITED;

--- создание профил€ безопасности и роли дл€ админа
create role AdminDB_role;

grant 
create session,
create table,
create view,
create procedure,
create user,
create role,
create profile
to AdminDB_role with admin option;
grant dba to AdminDB;

CREATE PROFILE pf_AdminDB LIMIT
PASSWORD_LIFE_TIME 640
SESSIONS_PER_USER 200 
FAILED_LOGIN_ATTEMPTS 7 
PASSWORD_LOCK_TIME 1 
PASSWORD_REUSE_TIME 10 
PASSWORD_GRACE_TIME DEFAULT 
CONNECT_TIME 180 
IDLE_TIME 30;

--- создание AdminDB
create user AdminDB 
identified by Admin
default tablespace agency_ts
temporary tablespace agency_ts_tmp
profile pf_AdminDB
account unlock
password expire;
ALTER USER AdminDB IDENTIFIED BY Admin1;

grant AdminDB_role to AdminDB;

ALTER TABLE AdminDB.DataUsers DROP COLUMN Address;

select * from User_tables

SELECT * FROM DBA_SYS_PRIVS WHERE GRANTEE = 'ADMINDB';
SELECT * FROM DBA_ROLE_PRIVS WHERE GRANTEE = 'ADMINDB';

SELECT * FROM DBA_TAB_PRIVS WHERE GRANTEE = 'AGENT';
SELECT * FROM DBA_ROLE_PRIVS WHERE GRANTEE = 'AGENT';
SELECT * FROM DBA_SYS_PRIVS WHERE GRANTEE = 'AGENT';



