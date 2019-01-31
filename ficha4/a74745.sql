--1)

CREATE OR REPLACE VIEW emp_detail AS
    SELECT EMPLOYEE_ID,FIRST_NAME || ' ' || LAST_NAME AS FULL_NAME,EMAIL,PHONE_NUMBER,SALARY,
        (SELECT FIRST_NAME || ' ' || LAST_NAME FROM EMPLOYEES e2 WHERE e1.MANAGER_ID=e2.EMPLOYEE_ID) AS MANAGER_NAME,j.JOB_TITLE,d.DEPARTMENT_NAME,l.CITY,c.COUNTRY_NAME
        FROM EMPLOYEES e1, JOBS j, DEPARTMENTS d, LOCATIONS l, COUNTRIES c
            WHERE e1.JOB_ID=j.JOB_ID AND e1.DEPARTMENT_ID=d.DEPARTMENT_ID AND d.LOCATION_ID=l.LOCATION_ID AND l.COUNTRY_ID=c.COUNTRY_ID;
            
INSERT INTO EMPLOYEES 
    VALUES (207,'CARLOS','CAMPOS','CCAMPOS','916.233.772','96.03.20','AD_VP',20000,null,null,90);
    
SELECT * FROM emp_detail;

--2)

ALTER TABLE EMPLOYEES
    ADD (
            EXTRA_SALARY NUMBER(8),
            EXTRA_HOURS NUMBER(4)
        );
        
UPDATE EMPLOYEES
    SET EXTRA_SALARY=0,EXTRA_HOURS=0;

CREATE OR REPLACE PROCEDURE act_extra(horas NUMBER, emp_id NUMBER) IS
    BEGIN
        UPDATE EMPLOYEES
            SET EMPLOYEES.EXTRA_HOURS = horas
                WHERE EMPLOYEES.EMPLOYEE_ID=emp_id;
    END;
    
CALL act_extra(30,100);

CREATE OR REPLACE PROCEDURE extra_salary_calc(perc NUMBER, emp_id NUMBER) IS
    BEGIN
        UPDATE EMPLOYEES e1
            SET e1.EXTRA_SALARY = nvl(perc*e1.SALARY*e1.EXTRA_HOURS, e1.EXTRA_SALARY)
                WHERE e1.EMPLOYEE_ID=emp_id;
    END;

-- usar joins é igual aos '='
-- usamos o IN em vez do '=' porque é para atualizar vários (o '=' devolve mais do que 1 linha)
UPDATE EMPLOYEES E1
    SET E1.EXTRA_HOURS=90 WHERE E1.EMPLOYEE_ID IN (
        SELECT e1.employee_id FROM employees e1,departments de,locations lc
            WHERE e1.department_id=de.department_id 
                AND lc.location_id=de.location_id 
                AND lc.city='Southlake');

CALL extra_salary_calc(0.05,103);
CALL extra_salary_calc(0.05,104);
CALL extra_salary_calc(0.05,105);
CALL extra_salary_calc(0.05,106);
CALL extra_salary_calc(0.05,107);


-- as barras são para concatenar first_name + last_name (PL/SQL -> sql usado pelo oracle)
-- se fose sql normal tens funçao para concatenar
SELECT e1.FIRST_NAME || ' ' || e1.LAST_NAME AS FULL_NAME, e1.SALARY, e1.EXTRA_SALARY FROM employees e1, departments de, locations lc
    WHERE e1.department_id=de.department_id 
        AND lc.location_id=de.location_id 
        AND lc.city='Southlake';

--3)
-- replace altera caso exista
CREATE OR REPLACE FUNCTION da_salario (e_id NUMBER)
    RETURN NUMBER AS salarioTotal NUMBER;
    BEGIN
        SELECT e1.SALARY+e1.EXTRA_SALARY INTO salarioTotal FROM employees e1
            WHERE e1.employee_id = e_id;
    RETURN salarioTotal;
    END;

-- É assim que se chama as functions. Dual é uma tabela do sistema.    
SELECT da_salario(103) FROM dual;

--a)
SELECT e1.EMPLOYEE_ID, e1.FIRST_NAME || ' ' || e1.LAST_NAME AS FULL_NAME, (SELECT da_salario(e1.EMPLOYEE_ID) FROM dual) AS salarioTotal, e1.EMAIL FROM EMPLOYEES e1
    WHERE (SELECT da_salario(e1.EMPLOYEE_ID) FROM dual) >= 20000;
    
--4)
CREATE TABLE TOTAL_COSTS
(
    TOTAL_HOURS NUMBER,
    TOTAL_SALARY NUMBER
);

INSERT INTO TOTAL_COSTS(TOTAL_HOURS,TOTAL_SALARY) 
    VALUES(
        (SELECT SUM(EXTRA_HOURS) FROM EMPLOYEES),
        (SELECT SUM(EXTRA_SALARY) FROM EMPLOYEES)
        );

CREATE SEQUENCE employee_sq START WITH 207 INCREMENT BY 1;

SELECT employee_sq.CURRVAL FROM dual;

SELECT employee_sq.NEXTVAL FROM dual;

CREATE OR REPLACE TRIGGER salary_value
BEFORE INSERT OR UPDATE OR DELETE ON EMPLOYEES
FOR EACH ROW
    BEGIN
        IF inserting
            THEN UPDATE TOTAL_COSTS 
                    SET TOTAL_HOURS = :NEW.EXTRA_HOURS + TOTAL_HOURS,
                        TOTAL_SALARY = :NEW.EXTRA_SALARY + TOTAL_SALARY;
        END IF;
        IF deleting
            THEN UPDATE TOTAL_COSTS 
                    SET TOTAL_HOURS = TOTAL_HOURS - :OLD.EXTRA_HOURS,
                        TOTAL_SALARY = TOTAL_SALARY - :OLD.EXTRA_SALARY;
        END IF;
        IF updating
            THEN UPDATE TOTAL_COSTS
                    SET TOTAL_HOURS = TOTAL_HOURS - :OLD.EXTRA_HOURS + :NEW.EXTRA_SALARY,
                        TOTAL_SALARY = TOTAL_SALARY - :OLD.EXTRA_SALARY + :NEW.EXTRA_SALARY;
        END IF;
    END;

INSERT INTO EMPLOYEES 
    VALUES (207,'CARLOS','CAMPOS','CCAMPOS2','916.233.772','96.03.20','AD_VP',200000,null,null,90,40500,90);
    
DELETE FROM EMPLOYEES
    WHERE EMPLOYEE_ID=207;

UPDATE EMPLOYEES
    SET EXTRA_SALARY=40499
    WHERE EMPLOYEE_ID=207;