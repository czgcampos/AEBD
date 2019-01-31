--1
CREATE TABLESPACE AEBD_TABLES
    DATAFILE '\u01\app\oracle\oradata\orcl12\orcl\aebd_tables_01.dbf'
    SIZE 100M;
        
--2
CREATE TEMPORARY TABLESPACE aebd_temp
    TEMPFILE '\u01\app\oracle\oradata\orcl12\orcl\aebd_temp_01.dbf'
    SIZE 50M AUTOEXTEND ON;

--3
SELECT * FROM dba_tablespaces;

--4
CREATE USER diana
    IDENTIFIED BY diana
    DEFAULT TABLESPACE AEBD_TABLES
    TEMPORARY TABLESPACE aebd_temp
    QUOTA 10M ON AEBD_TABLES
    ACCOUNT UNLOCK;

--5
GRANT CONNECT TO diana;

GRANT RESOURCE TO diana;

--7
-- carregar no mais, criar uma connect com o user e a pass que usaste em cima

--8 e 9
-- Criar tabelas com o botão direito em tables da diana
CREATE TABLE PATROCINADOR 
(
  ID_PATROCINADOR NUMBER NOT NULL 
, NOME VARCHAR2(200) 
, MONTANTE NUMBER 
, CONSTRAINT TABLE1_PK PRIMARY KEY 
  (
    ID_PATROCINADOR 
  )
  ENABLE 
);