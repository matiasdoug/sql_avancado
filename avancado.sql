-- Comandos avançados SQL

-- Subconsultas

SELECT last_name, job_id, salary
FROM   employees
WHERE  job_id =  
                (SELECT job_id
                 FROM   employees
                 WHERE  employee_id = 141)
AND    salary >
                (SELECT salary
                 FROM   employees
                 WHERE  employee_id = 143);

-------------------------------------------------

SELECT employee_id, last_name, job_id, salary
FROM   employees
WHERE  salary < ANY
                    (SELECT salary
                     FROM   employees
                     WHERE  job_id = 'IT_PROG')
AND    job_id <> 'IT_PROG';



--Subconsulta para evitar criação de view

INSERT INTO EMPLOYEES_RETIRED 
   (employee_id, first_name, last_name, email, 
    phone_number, hire_date, retired_date, job_id, 
    salary, commission_pct)
SELECT employee_id, first_name, last_name, email, 
       phone_number, hire_date, sysdate, job_id, 
       salary, commission_pct
FROM employees
WHERE employee_id=110;

SELECT * FROM EMPLOYEES_RETIRED;

-- Inserção em Múltiplas tabelas
-- Insert Incondicional

INSERT  ALL 
INTO sal_hist_dept VALUES(EMP_ID,HIREDATE,SALARY) 
INTO mgr_hist_dept VALUES(EMP_ID,MANAGER,SALARY)
SELECT employee_id EMP_ID, 
       hire_date   HIREDATE,
       salary, 
       manager_id  MANAGER 
FROM  employees   
WHERE department_id = 90 ; 

-- Instrução Merge para atualizar ou inserir novos valores

MERGE INTO catalog1 s1 
USING catalog2 s2 
ON (s1.id = s2.id) 
WHEN MATCHED THEN 
   UPDATE SET s1.price = s2.price  
WHEN NOT MATCHED THEN 
   INSERT (id, item, price) 
   values (s2.id, s2.item, s2.price);

select * from catalog1;

-- Agrupamento Rollup para conjunto de linhas e subtotais

SELECT   department_id dept, job_id job, 
         SUM(salary) sum_salary 
FROM     employees  
WHERE    department_id >= 50
GROUP BY ROLLUP (department_id, job_id);

-- Agrupamento Cube para todas as combinações de totais e subtotais

SELECT   department_id dept, job_id job, 
         SUM(salary) sum_salary 
FROM     employees  
WHERE    department_id >= 50
GROUP BY CUBE (department_id, job_id);

-- Consultas Hierarquícas
-- Árvore de hierarquia percorrida de baixo para cima

SELECT employee_id, last_name, job_id, manager_id
FROM   employees
START  WITH  last_name = 'Kochhar'
CONNECT BY PRIOR manager_id = employee_id ;

-- Árvore  percorrida de cima para baixo:
SELECT  last_name||' Responde para '|| 
PRIOR   last_name "Árvore de Cima para Baixo", 
LEVEL   "Nivel"
FROM    employees
START   WITH employee_id = 100
CONNECT BY PRIOR employee_id = manager_id;

-- CTE (Common Table expression)
-- Esta consulta retorna o departamento e o salario total do deparmento que seja maior que a média da soma dos salários por departamentos

WITH 
    dept_costs AS( SELECT d.department_name, SUM(e.salary) dept_total -- SOMATÓRIOS DOS SALARIOS POR DEPTO
                   FROM  employees e JOIN departments d 
                   ON e.department_id = d.department_id
                   GROUP BY  d.department_name),  
    avg_cost AS (SELECT AVG(dept_total)AS dept_avg -- MÉDIA DOS SOMATÓRIOS DOS SALARIOS POR DEPTO
                 FROM dept_costs)
SELECT  *
FROM   dept_costs
WHERE  dept_total >( SELECT dept_avg
                     FROM   avg_cost )
ORDER BY department_name;





