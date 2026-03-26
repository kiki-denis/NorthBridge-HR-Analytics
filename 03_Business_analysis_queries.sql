--BUSINESS QUESTIONS
--VIEW DEPT VS SALARY
CREATE  VIEW view_dept_salary_summary AS 

SELECT * FROM  view_dept_salary_summary
    d.dept_name,
    ROUND(AVG(s.gross_salary), 2)  AS avg_salary
FROM departments  d
JOIN  employees e ON e.dept_id = d.dept_id
JOIN salaries     s  ON e.employee_id = s.employee_id
WHERE e.status ILIKE 'active'
GROUP BY  d.dept_name, s.gross_salary

--VIEW DEPT VS EMP_NAME VS SALARY
CREATE  VIEW  v_name_dept_salary_summary AS 
SELECT
    d.dept_name, e.employee_id,
	e.first_name || ' ' || e.last_name  AS  Name,
    ROUND(AVG(s.gross_salary), 2)  AS avg_salary
FROM departments  d
JOIN  employees e ON e.dept_id = d.dept_id
JOIN salaries     s  ON e.employee_id = s.employee_id
WHERE e.status ILIKE 'active'
GROUP BY  d.dept_name, e.employee_id, e.first_name || ' ' || e.last_name
	
--##HEADCOUNT AND STRUCTURE

--How many active employees does each department have?

SELECT
    d.dept_name,
    COUNT(e.employee_id) AS headcount
FROM departments d
LEFT JOIN employees e
    ON d.dept_id = e.dept_id
    AND e.status ILIKE 'active'
GROUP BY d.dept_name
ORDER BY headcount DESC;

--longest serving active employee

SELECT first_name  last_name, hire_date,
date_part ('year', age(now(), hire_date)) AS years_of_service
FROM employees 
WHERE status ILIKE 'active'
ORDER BY years_of_service DESC
LIMIT 10;

--You can also use the query below to answer find the longest serving
--employee. Both works

SELECT 
    e.first_name || ' ' || e.last_name AS employee,
    d.dept_name,
    e.hire_date,
    -- This version shows exact tenure down to number of days
    AGE(NOW(), e.hire_date) AS exact_tenure
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.status ILIKE 'active'
ORDER BY e.hire_date ASC -- Oldest hire date at the top
LIMIT 10;

--##SALARY ANALYTICS

--The AVG Salary by department
select d.dept_name,
ROUND(avg(s.gross_salary),2) AS AVG_Salary,
MIN(s.gross_salary) AS Min_Salary,
MAX(s.gross_salary) AS Max_Salary
FROM departments d
JOIN employees e ON d.dept_id = e.dept_id
JOIN salaries s ON e.employee_id = s.employee_id
WHERE e.status ILIKE 'active'
GROUP BY d.dept_name
ORDER BY AVG_Salary DESC

--Employees that earn more than company average
SELECT e.first_name || ' ' || e.last_name AS employee,
Job_title,
s.gross_salary,
ROUND(s.gross_salary - (SELECT AVG(gross_salary) FROM salaries),2) AS Above_avg
FROM employees e 
JOIN salaries s ON s.employee_id = e.employee_id
WHERE  s.gross_salary > (SELECT AVG(gross_salary) FROM salaries)
AND e.status ILIKE 'active'
ORDER BY s.gross_salary DESC
--We used subquerey here

--Employees that earn less than average for their own department
SELECT e.first_name || ' ' || e.last_name AS employee,
d.dept_name,
s.gross_salary,
    ROUND(
	(SELECT AVG(ss.gross_salary) 
           FROM salaries ss 
           JOIN employees ee ON ss.employee_id = ee.employee_id 
           WHERE ee.dept_id = e.dept_id) - s.gross_salary, 2) AS Below_Dept_Avg
FROM employees e
JOIN departments d ON d.dept_id = e.dept_id
JOIN salaries s ON e.employee_id = s.employee_id
WHERE s.gross_salary < (
    SELECT AVG(ss.gross_salary) 
    FROM salaries ss 
    JOIN employees ee ON ss.employee_id = ee.employee_id 
    WHERE ee.dept_id = e.dept_id
)
AND e.status ILIKE 'active'
ORDER BY s.gross_salary 
--We used correlated subquerey here

--## PERFORMANCE ANALYTICS

--What is the average performance score by department
SELECT d.dept_name,
       ROUND(AVG(pr.score),2) AS AVG_pr_score,
	   COUNT(review_id)     AS Totalnumber_reviews
FROM departments d
    JOIN employees e ON d.dept_id = e.dept_id
    JOIN performance_reviews pr ON e.employee_id = pr.employee_id
  
  GROUP BY dept_name
  ORDER BY AVG_pr_score DESC

  --Which employees have NEVER had a performance review? 
--(Subquery with NOT IN)-identifies a gap in the data.

SELECT e.first_name || ' ' ||  e.last_name AS employee,
        e.job_title,
		e.hire_date
FROM employees e
WHERE e.employee_id NOT IN (
      SELECT DISTINCT employee_id FROM performance_reviews
)
AND e.status ILIKE 'active'
ORDER BY e.hire_date

--Employees due for a review(no review in the last 12 months)
SELECT
    e.first_name || ' ' || e.last_name  AS employee,
    d.dept_name,
    MAX(pr.review_date)  AS last_review_date
FROM employees e
JOIN departments d  ON e.dept_id = d.dept_id
LEFT JOIN performance_reviews pr ON e.employee_id = pr.employee_id
WHERE e.status ILIKE 'active'
GROUP BY e.employee_id, e.first_name, e.last_name, d.dept_name
HAVING MAX(pr.review_date) < NOW() - INTERVAL '12 months'
    OR MAX(pr.review_date) IS NULL
ORDER BY last_review_date ASC NULLS FIRST;

--## TURNOVER AND RETENTION ANALYTICS 

--What is the turnover rate by dept
SELECT
    d.dept_name,
    COUNT(t.employee_id)   AS terminations,
    COUNT(e.employee_id)   AS total_ever_employed,
    ROUND(
        100.0 * COUNT(t.employee_id) / NULLIF(COUNT(e.employee_id), 0),
    1)  AS turnover_rate_pct
FROM departments d
LEFT JOIN employees e  ON d.dept_id = e.dept_id
LEFT JOIN turnover  t  ON e.employee_id = t.employee_id
GROUP BY d.dept_name
ORDER BY turnover_rate_pct DESC;


--The departments that have ABOVE-AVERAGE turnover? (Subquery)
SELECT dept_name, turnover_rate_pct
FROM (
    SELECT
        d.dept_name,
        ROUND(
            100.0 * COUNT(t.employee_id) / NULLIF(COUNT(e.employee_id), 0),
        1) AS turnover_rate_pct
    FROM departments d
    LEFT JOIN employees e ON d.dept_id = e.dept_id
    LEFT JOIN turnover  t ON e.employee_id = t.employee_id
    GROUP BY d.dept_name
) AS dept_turnover
WHERE turnover_rate_pct > (
    SELECT AVG(turnover_rate_pct) FROM (
        SELECT
            ROUND(100.0 * COUNT(tt.employee_id) / NULLIF(COUNT(ee.employee_id),0), 1)
            AS turnover_rate_pct
        FROM departments dd
        LEFT JOIN employees ee ON dd.dept_id = ee.dept_id
        LEFT JOIN turnover  tt ON ee.employee_id = tt.employee_id
        GROUP BY dd.dept_name
    ) sub
)
ORDER BY turnover_rate_pct DESC

--##MORE QUERIES 

--What's the Training completion rate by department
SELECT
    d.dept_name,
    COUNT(tr.training_id)        AS total_trainings,
    SUM(CASE WHEN tr.passed THEN 1 ELSE 0 END)    AS passed,
    ROUND(100.0 * SUM(CASE WHEN tr.passed THEN 1 ELSE 0 END)
          / NULLIF(COUNT(tr.training_id), 0), 1)  AS pass_rate_pct
FROM departments d
JOIN employees e  ON d.dept_id = e.dept_id
JOIN training  tr ON e.employee_id = tr.employee_id
GROUP BY d.dept_name
ORDER BY pass_rate_pct DESC;

--Who are the Employees with high performance scores but below-average pay (flight risk)?
--This combines a subquery with a JOIN and is a genuinely useful HR insight 
-- high performers who are underpaid are more likely to leave.

SELECT
    e.first_name || ' ' || e.last_name  AS employee,
    d.dept_name,
    s.gross_salary,
    ROUND(AVG(pr.score), 2)  AS avg_performance_score
FROM employees e
JOIN departments  d  ON e.dept_id = d.dept_id
JOIN salaries     s  ON e.employee_id = s.employee_id
JOIN performance_reviews pr ON e.employee_id = pr.employee_id
WHERE e.status ILIKE 'active'
