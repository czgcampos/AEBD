-- criar tablespace principal
CREATE TABLESPACE monitor_tables
    DATAFILE '\u01\app\oracle\oradata\orcl12\orcl\monitor_tables_01.dbf'
    SIZE 300M;
    
-- criar tablespace temporario
CREATE TEMPORARY TABLESPACE monitor_temp
    TEMPFILE '\u01\app\oracle\oradata\orcl12\orcl\monitor_temp_01.dbf'
    SIZE 100M
    AUTOEXTEND ON;
   
-- verificar tablespaces criados
SELECT * FROM DBA_TABLESPACES;

-- criar user Monitor para fornecer dados a partir do script
CREATE USER Monitor
    IDENTIFIED BY monitor
    DEFAULT TABLESPACE monitor_tables
    TEMPORARY TABLESPACE monitor_temp;
    
-- dar privilégios ao utilizador criado
GRANT CONNECT, RESOURCE, DBA TO Monitor;
GRANT CREATE SESSION TO Monitor;
GRANT CREATE table TO Monitor;
GRANT CREATE view TO Monitor;
GRANT CREATE trigger TO Monitor;
GRANT CREATE procedure TO Monitor;
GRANT DROP ANY table TO Monitor;
GRANT UPDATE ANY table TO Monitor;
GRANT ALTER ANY table TO Monitor;

-- verificar user criado
SELECT * FROM DBA_USERS;