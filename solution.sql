-- Guided Project: SQL Window Functions for Analytics



-- Task One: Getting Started
-- In this task, we will get started with the project
-- by retrieving all the data in the projectdb database


-- 1.1: Retrieve all the data in the projectdb database
SELECT * FROM employees;
SELECT * FROM departments;
SELECT * FROM regions;
SELECT * FROM customers;
SELECT * FROM sales;


-- Task Two: Window Functions 


-- 2.1: Retrieve a list of employee_id, first_name, hire_date, 
-- and department of all employees ordered by the hire date

SELECT employee_id, first_name, department, hire_date,
ROW_NUMBER() OVER (order by hire_date) AS Row_N
FROM employees;


-- 2.2: Retrieve the employee_id, first_name, hire_date of employees for different departments

select employee_id, first_name,department,hire_date,
row_number() over(partition by department order by hire_date) as row_num
from employees;

-- 2.3: Retrieve first hire from each department

select * from
(select employee_id, first_name,department,hire_date,
row_number() over(partition by department order by hire_date) as row_num
from employees) as dep_first_hire
where row_num =1;


-- 2.4 Retrieve Latest hire from each department

select * from
(select employee_id, first_name,department,hire_date,
row_number() over(partition by department order by hire_date desc) as row_num
from employees) as dep_first_hire
where row_num =1;


-- Task Three: Ranking
-- In this task, we will learn how to rank the rows of a result set


-- 3.1: Recall the use of ROW_NUMBER()

SELECT first_name, email, department, salary,
ROW_NUMBER() OVER(PARTITION BY department
				  ORDER BY salary DESC)
FROM employees;

-- 3.2: Let's use the RANK() function

select first_name, email, department, salary,
rank() over(partition by department order by salary desc ) rank_num
from employees;


-- Exercise 3.1: Retrieve the hire_date. Return details of
-- employees hired on or before 31st Dec, 2005 and are in
-- First Aid, Movies and Computers departments 

SELECT first_name, email, department, salary, hire_date,
RANK() OVER(PARTITION BY department
			ORDER BY salary DESC)
FROM employees
WHERE hire_date<= '2005-12-31' AND
department in ('First Aid', 'Movies', 'Computers');

-- This returns how many employees are in each department
SELECT department, COUNT(*) dept_count
FROM employees
GROUP BY department
ORDER BY dept_count DESC;

-- 3.3: Return the fifth ranked salary for each department

select * from
(select first_name, department, salary,
rank() over(partition by department order by salary desc) as rank_num
from employees) a
where rank_num=5;


-- Create a common table expression to retrieve the customer_id, 
-- and how many times the customer has purchased from the mall 
WITH purchase_count AS (
SELECT customer_id, COUNT(sales) AS purchase
FROM sales
GROUP BY customer_id
ORDER BY purchase DESC
)


-- 3.4: Understand the difference between ROW_NUMBER, RANK, DENSE_RANK
select customer_id, purchase,
row_number() over(order by purchase desc) as row_num,
rank() over(order by purchase desc) as rank_num,
dense_rank() over(order by purchase desc) as denserank_num
from purchase_count
order by purchase DESC;


-- Task Four: Paging: NTILE()
-- In this task, we will learn how break/page the result set into groups


-- 4.1: Group the employees table into five groups
-- based on the order of their salaries

select first_name, department,
ntile(5) over(order by salary desc) as ntile_group
from employees;

-- 4.2: Group the employees table into five groups for 
-- each department based on the order of their salaries
SELECT first_name, email, department, salary,
NTILE(5) OVER(PARTITION BY department
			  ORDER BY salary DESC)
FROM employees;

-- Create a CTE that returns details of an employee
-- and group the employees into five groups
-- based on the order of their salaries
WITH salary_ranks AS (
SELECT first_name, email, department, salary,
NTILE(5) OVER(ORDER BY salary DESC) AS rank_of_salary
FROM employees)

-- 4.3: Find the average salary for each group of employees

select rank_of_salary, round(avg(salary),2) avg_salary
from salary_ranks
group by 1
order by 2 desc;


-- Task Five: Aggregate Window Functions - Part One
-- In this task, we will learn how to use aggregate window functions in SQL


-- 5.1: This returns how many employees are in each department
SELECT department, COUNT(*) AS dept_count
FROM employees
GROUP BY department
ORDER BY department;


-- 5.2: Retrieve the first names, department and 
-- number of employees working in that department
SELECT first_name, department, 
(SELECT COUNT(*) AS dept_count FROM employees e1 WHERE e1.department = e2.department)
FROM employees e2
GROUP BY department, first_name
ORDER BY department;

-- The solution

select first_name, department,
count(*) over(partition by department order by department) dept_count
from employees;

-- 5.3: Total Salary for all employees

select first_name, department,hire_date,salary,
sum(salary) over(order by hire_date) total_salary
from employees;

-- 5.4: Total Salary for each department

select first_name, department,hire_date, salary,
sum(salary) over(partition by department) total_salary
from employees;


-- Exercise 5.5: Total Salary for each department and
-- order by the hire date. Call the new column running_total
SELECT first_name, hire_date, department, salary,
sum(salary) OVER(partition by department order by hire_date) AS running_total
FROM employees;


-- Task Six: Aggregate Window Functions - Part Two
-- In this task, we will learn how to use aggregate window functions in SQL


-- Retrieve the different region ids
SELECT DISTINCT region_id
FROM employees;

-- 6.1: Retrieve the first names, department and 
-- number of employees working in that department and region

select first_name, department,
count(*) over(partition by department) dept_count, region_id,
count(*) over(partition by region_id) region_count
from employees;



-- Exercise 6.1: Retrieve the first names, department and 
-- number of employees working in that department and in region 2
SELECT first_name, department, 
count(*) OVER(partition by department) AS dept_count
FROM employees
where region_id = 2;

-- Create a common table expression to retrieve the customer_id, 
-- ship_mode, and how many times the customer has purchased from the mall


WITH purchase_count AS (
SELECT customer_id, ship_mode, COUNT(sales) AS purchase
FROM sales
GROUP BY customer_id, ship_mode
ORDER BY purchase DESC
)

-- Exercise 6.2: Calculate the cumulative sum of customers purchase
-- for the different ship mode
SELECT customer_id, ship_mode, purchase, 
sum(purchase) OVER(partition by ship_mode
				   ORDER BY customer_id ASC) AS sum_of_sales
FROM purchase_count;


-- Task Seven: Window Frames - Part One
-- In this task, we will learn how to order data in window frames in the result set


-- 7.1: Calculate the running total of salary

-- Retrieve the first_name, hire_date, salary
-- of all employees ordered by the hire date
SELECT first_name, hire_date, salary
FROM employees
ORDER BY hire_date;

-- The solution
select first_name, hire_date,salary,
sum(salary) over(order by hire_date
					range between
					unbounded preceding and current row) as running_total
from employees;

-- 7.2: Add the current row and previous row

select first_name, hire_date,salary,
sum(salary) over(order by hire_date
					rows between
					1 preceding and current row) as running_total
from employees;


-- 7.3: Find the running average

select first_name, hire_date,salary,
round(avg(salary) over(order by hire_date
					rows between
					1 preceding and current row),2) as running_avg
from employees;

-- What do you think the result of the query will be?
SELECT first_name, hire_date, salary,
SUM(salary) OVER(ORDER BY hire_date 
				 ROWS BETWEEN
				 3 PRECEDING AND CURRENT ROW) AS running_total
FROM employees;


-- Task Eight: Window Frames - Part Two
-- In this task, we will learn how to order data in window frames in the result set


-- 8.1: Review of the FIRST_VALUE() function
SELECT department, division,
FIRST_VALUE(department) OVER(ORDER BY department ASC) first_department
FROM departments;

-- 8.2: Retrieve the last department in the departments table
SELECT department, division,
FIRST_VALUE(department) OVER(ORDER BY department ASC) first_department,
LAST_VALUE(department) over(order by department ASC
								range between unbounded preceding
								and unbounded following) last_department
FROM departments;

-- Create a common table expression to retrieve the customer_id, 
-- ship_mode, and how many times the customer has purchased from the mall
WITH purchase_count AS (
SELECT customer_id, COUNT(sales) AS purchase
FROM sales
GROUP BY customer_id
ORDER BY purchase DESC
)

-- What do you think this will return?
SELECT customer_id, purchase, 
MAX(purchase) OVER(ORDER BY customer_id ASC) AS max_of_sales,
MAX(purchase) OVER(ORDER BY customer_id ASC
				  ROWS BETWEEN
				  CURRENT ROW AND 1 FOLLOWING) AS next_max_of_sales
FROM purchase_count;


-- Task Nine: GROUPING SETS, ROLLUP() & CUBE()
-- In this task, we will learn how the GROUPING SETS, 
-- ROLLUP, and CUBE clauses work in SQL


-- 9.1: Find the sum of the quantity for different ship modes
SELECT ship_mode, SUM(quantity) 
FROM sales
GROUP BY ship_mode;

-- 9.2: Find the sum of the quantity for different categories
SELECT category, SUM(quantity) 
FROM sales
GROUP BY category;

-- 9.3: Find the sum of the quantity for different subcategories
SELECT sub_category, SUM(quantity) 
FROM sales
GROUP BY sub_category;

-- 9.4: Use the GROUPING SETS clause

select ship_mode, category, sub_category, sum(quantity)
from sales
group by grouping sets(ship_mode, category, sub_category);

--9.5: Use the ROLLUP clause

select ship_mode, category, sub_category, sum(quantity)
from sales
group by rollup(ship_mode, category, sub_category);


--9.6: Use the CUBE clause

select ship_mode, category, sub_category, sum(quantity)
from sales
group by cube(ship_mode, category, sub_category);



