-- Run this in pgAdmin Query Tool
--CREATE DATABASE called northbridge_hr
-- Then connect to it before running anything else

DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS salaries CASCADE;
DROP TABLE IF EXISTS performance_reviews CASCADE;
DROP TABLE IF EXISTS training CASCADE;
DROP TABLE IF EXISTS job_history CASCADE;
DROP TABLE IF EXISTS turnover CASCADE;

CREATE TABLE departments (
    dept_id       SERIAL PRIMARY KEY,
    dept_name     VARCHAR(100) NOT NULL,
    location      VARCHAR(100),
    mngr_id    INT, -- will add FK after employees exists
    annual_budget NUMERIC(12,2)
);

CREATE TABLE employees (
    employee_id   SERIAL PRIMARY KEY,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    hire_date     DATE NOT NULL,
    job_title     VARCHAR(100),
    dept_id       INT REFERENCES departments(dept_id),
    email         VARCHAR(150) UNIQUE,
    status        VARCHAR(20) DEFAULT 'active'  -- active / terminated
);

CREATE TABLE salaries (
    salary_id      SERIAL PRIMARY KEY,
    employee_id    INT REFERENCES employees(employee_id),
    amount         NUMERIC(10,2) NOT NULL,
    effective_date DATE NOT NULL,
    salary_type    VARCHAR(20) DEFAULT 'annual'
);

CREATE TABLE performance_reviews (
    review_id    SERIAL PRIMARY KEY,
    employee_id  INT REFERENCES employees(employee_id),
    review_date  DATE NOT NULL,
    score        INT CHECK (score BETWEEN 1 AND 5),
    reviewr_id  INT REFERENCES employees(employee_id),
    notes        TEXT
);

CREATE TABLE training (
    training_id      SERIAL PRIMARY KEY,
    employee_id      INT REFERENCES employees(employee_id),
    course_name      VARCHAR(150),
    completion_date  DATE,
    passed           BOOLEAN DEFAULT TRUE
);

CREATE TABLE job_history (
    history_id    SERIAL PRIMARY KEY,
    employee_id   INT REFERENCES employees(employee_id),
    old_title     VARCHAR(100),
    new_title     VARCHAR(100),
    change_date   DATE NOT NULL,
    change_reason VARCHAR(200)
);

CREATE TABLE turnover (
    turnover_id        SERIAL PRIMARY KEY,
    employee_id        INT REFERENCES employees(employee_id),
    termination_date   DATE NOT NULL,
    reason             VARCHAR(200),
    voluntary          BOOLEAN DEFAULT TRUE
);

--ALTER TABLE 

--CHANGE REQUEST 1: ADDING A PHONE NUMBER COLUMN TO EMPLOYEES TABLE

ALTER TABLE employees
ADD COLUMN phone VARCHAR(20);

--Update rows

UPDATE employees SET phone = '618-732-9879' WHERE employee_id = 83;
UPDATE employees SET phone = '918-319-3894' WHERE employee_id = 84;
UPDATE employees SET phone = '588-430-5744' WHERE employee_id = 85;
UPDATE employees SET phone = '229-430-2911' WHERE employee_id = 86;
UPDATE employees SET phone = '782-209-2641' WHERE employee_id = 87;
UPDATE employees SET phone = '360-993-9416' WHERE employee_id = 88;
UPDATE employees SET phone = '905-510-7200' WHERE employee_id = 89;
UPDATE employees SET phone = '805-614-6343' WHERE employee_id = 90;
UPDATE employees SET phone = '566-275-6551' WHERE employee_id = 91;
UPDATE employees SET phone = '489-832-3605' WHERE employee_id = 92;
UPDATE employees SET phone = '314-723-2147' WHERE employee_id = 93;
UPDATE employees SET phone = '802-296-5423' WHERE employee_id = 94;
UPDATE employees SET phone = '522-310-5746' WHERE employee_id = 95;
UPDATE employees SET phone = '235-552-7322' WHERE employee_id = 96;
UPDATE employees SET phone = '298-688-8800' WHERE employee_id = 97;
UPDATE employees SET phone = '395-393-3130' WHERE employee_id = 98;
UPDATE employees SET phone = '464-965-5062' WHERE employee_id = 99;
UPDATE employees SET phone = '995-250-1711' WHERE employee_id = 100;
UPDATE employees SET phone = '889-896-8149' WHERE employee_id = 101;
UPDATE employees SET phone = '926-238-6384' WHERE employee_id = 102;
UPDATE employees SET phone = '578-682-8432' WHERE employee_id = 103;
UPDATE employees SET phone = '804-753-3467' WHERE employee_id = 104;
UPDATE employees SET phone = '438-695-8464' WHERE employee_id = 105;
UPDATE employees SET phone = '954-900-6667' WHERE employee_id = 106;
UPDATE employees SET phone = '831-955-1714' WHERE employee_id = 107;
UPDATE employees SET phone = '484-361-1152' WHERE employee_id = 108;
UPDATE employees SET phone = '428-214-9899' WHERE employee_id = 109;
UPDATE employees SET phone = '488-565-4261' WHERE employee_id = 110;
UPDATE employees SET phone = '614-314-6913' WHERE employee_id = 111;
UPDATE employees SET phone = '548-315-4666' WHERE employee_id = 112;
UPDATE employees SET phone = '821-933-1971' WHERE employee_id = 113;

--CHANGE REQUEST 2: ADD mngr_id fk to departments(you left it empty before)

ALTER TABLE departments
    ADD CONSTRAINT fk_dept_manager
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

-- Now assign managers
UPDATE departments SET mngr_id,  = 90 WHERE dept_id = 1;  
UPDATE departments SET mngr_id,  = 103 WHERE dept_id = 2;
UPDATE departments SET mngr_id,  = 97 WHERE dept_id = 3;
UPDATE departments SET mngr_id,  = 106 WHERE dept_id = 4;
UPDATE departments SET mngr_id,  = 87 WHERE dept_id = 5;

--CHANGE REQUEST 3: RENAME A COLUMN AND ADD A CONSTRAINT
--The salary 'amount' column should be 'gross_salary' for clarity. 
--Also enforce that salaries must be positive.

ALTER TABLE salaries
RENAME COLUMN amount TO gross_salary;

ALTER TABLE salaries
    ADD CONSTRAINT chk_salary_positive CHECK (gross_salary > 0);

--USING DROP TO REMOVE A COLUMN THAT'S NOT NEEDED
-- Always check what's in a column before dropping it

SELECT DISTINCT salary_type FROM salaries;

-- Confirm you are okay losing it, then:
ALTER TABLE salaries
    DROP COLUMN salary_type;


