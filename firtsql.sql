DECLARE
  CURSOR c_get IS
    SELECT FIRST_NAME, EMPLOYEE_ID, JOB_ID, HIRE_DATE FROM emp WHERE HIRE_DATE = TRUNC(SYSDATE);

  TYPE t_emp_rec IS RECORD (
    FIRST_NAME    emp.FIRST_NAME%TYPE,
    EMPLOYEE_ID      emp.EMPLOYEE_ID%TYPE,
    JOB_ID        emp.JOB_ID%TYPE,
    HIRE_DATE  emp.HIRE_DATE%TYPE
  );
  TYPE t_emp_tab IS TABLE OF t_emp_rec INDEX BY PLS_INTEGER;

  v_type_update t_emp_tab;
BEGIN
  OPEN c_get;
  LOOP
    FETCH c_get BULK COLLECT INTO v_type_update LIMIT 10000;
    EXIT WHEN v_type_update.COUNT = 0;

    BEGIN
      FORALL i IN v_type_update.FIRST .. v_type_update.LAST SAVE EXCEPTIONS
        INSERT INTO emp_sal (FIRST_NAME, EMPLOYEE_ID, JOB_ID, hiredate)
        VALUES (
          v_type_update(i).FIRST_NAME,
          v_type_update(i).EMPLOYEE_ID,
          v_type_update(i).JOB_ID,
          v_type_update(i).HIRE_DATE
        );
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('Bulk DML error: ' || SQLERRM);
    END;
  END LOOP;
  IF c_get%ISOPEN THEN
    CLOSE c_get;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Error code: ' || SQLCODE);
    dbms_output.put_line('Error message: ' || SQLERRM);
END;
/
--------------------------------------------------------
SELECT
    pay_month,
    department_id,
    CASE
        WHEN dept_avg > company_avg THEN 'higher'
        WHEN dept_avg < company_avg THEN 'lower'
        ELSE 'same'
    END AS comparison
FROM (
    SELECT
        TO_CHAR(s.pay_date, 'YYYY-MM') AS pay_month,
        e.department_id,
        AVG(s.amount) AS dept_avg,
        (SELECT AVG(s2.amount)
           FROM salary s2
          WHERE TO_CHAR(s2.pay_date, 'YYYY-MM') = TO_CHAR(s.pay_date, 'YYYY-MM')
        ) AS company_avg
    FROM salary s
    JOIN employee_department e ON s.employee_id = e.employee_id
    GROUP BY TO_CHAR(s.pay_date, 'YYYY-MM'), e.department_id
)
ORDER BY pay_month, department_id;





ABS