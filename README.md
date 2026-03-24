# NorthBridge HR Analytics — PostgreSQL Portfolio Project

## Overview
NorthBridge Solutions is a fictional mid sized Canadian company with operations across Toronto, Vancouver, Calgary, and Montreal. Its HR and Workforce Analytics database models the complete employee lifecycle; from the moment someone is hired to the moment they leave, and everything in between.

This project models a comprehensive HR management system for NorthBridge, designed to track the full employee lifecycle from hiring to turnover. By analyzing 7 interconnected tables, the database provides data <img width="1135" height="1084" alt="table schema pgerd" src="https://github.com/user-attachments/assets/2a7296ce-c6d8-42c0-9885-c701c05363c0" />
driven insights into workforce tenure, salary equity, and departmental performance.

## Schema Diagram
![Schema Diagram](path/to/your/screenshot.png) C:\Users\HP\Downloads\table schema.pgerd
*Note: This database consists of 7 tables (Employees, Departments, Salaries, Performance_Reviews, Training, Turnover, and Job_History) linked via Foreign Key relationships.*

## Business Questions Answered

How many active employees does each department have?
Who are the longest-serving active employees?
What is the average salary by department?
Which employees earn MORE than the company average? (Subquery)
Which employees earn LESS than the average for their own department? (Correlated Subquery)
What is the average performance score by department?
Which employees have NEVER had a performance review? (Subquery with NOT IN)
Employees due for a review (no review in the last 12 months)
What is the turnover rate by department?
Which departments have ABOVE-AVERAGE turnover? (Subquery)
Training completion rate by department
Employees with high performance scores but below-average pay (flight risk)

## Key SQL Techniques Used
- **JOINS:** INNER and LEFT JOINs to connect employee records with department and salary data.
- **Subqueries:** Utilized derived table, Scalar and Correlated subqueries for advanced salary benchmarking.
- **GROUP BY + HAVING:** To filter aggregated data like review dates and headcounts.
- **Data Definition (DDL):** Using `ALTER TABLE` to manage constraints and `Views` for reporting.

