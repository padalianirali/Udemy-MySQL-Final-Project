/* Using employees database */
use employees;

/* 
Query 1 
Find the average salary of the male and female employees in each department. 
*/
select 
	d.dept_name, e.gender, avg(salary) as avg_salary
from 
	salaries s
    join
    dept_emp de  on s.emp_no = de.emp_no
    join 
    departments d on de.dept_no = d.dept_no
    join 
    employees e on de.emp_no = e.emp_no
group by e.gender, d.dept_no
order by d.dept_no;

/* 
Query 2
Find the lowest department number encountered in the 'dept_emp' table. Then, find the highest department number.
*/
select 
	min(dept_no)
from 
	dept_emp;

select
	max(dept_no)
from
	dept_emp;

/* 
Query 3
Obtain a table containing the following three fields for all individuals whose employee number is not greater than 10040:
- employee number
- the lowest department number among the departments where the employee has worked in (Hint: use a subquery to retrieve this value 
from the 'dept_emp' table)
- assign '110022' as 'manager' to all individuals whose employee number is lower than or equal to 10020, and '110039' to those 
whose number is between 10021 and 10040 inclusive.
Use a CASE statement to create the third field.
If you've worked correctly, you should obtain an output containing 40 rows.
*/
select
	emp_no,
    (select min(dept_no) from dept_emp de where e.emp_no = de.emp_no) as dept_no,
    case
		when emp_no = 10020 then 110022
        else 110039
    end as manager
from
	employees e
where
	emp_no <= 10040;
    
/*
Query 4
Retrieve a list of all employees that have been hired in 2000.
*/
select
	* 
from
	employees
where
	year(hire_date) = 2000
order by hire_date;

/* Query 5
Retrieve a list of all employees from the ‘titles’ table who are engineers.
Repeat the exercise, this time retrieving a list of all employees from the ‘titles’ table who are senior
engineers.
After LIKE, you could indicate what you are looking for with or without using parentheses. Both options are
correct and will deliver the same output. We think using parentheses is better for legibility and that’s why
it is the first option we’ve suggested.
*/
select
	*
from
	titles
where 
	title like ('%engineer%');

select
	*
from
	titles
where 
	title like ('%senior engineer%');

/* 
Query 6
Create a procedure that asks you to insert an employee number and that will obtain an output containing
the same number, as well as the number and name of the last department the employee has worked in.
Finally, call the procedure for employee number 10010.
If you've worked correctly, you should see that employee number 10010 has worked for department
number 6 - "Quality Management".
 */

drop procedure if exists query_6;

delimiter $$
create procedure query_6(in p_emp_no int)
begin
	select 
		de.emp_no, de.dept_no, d.dept_name
	from
		dept_emp de
        join
        departments d on de.dept_no = d.dept_no
	where
		de.emp_no = p_emp_no
        and
        de.from_date = (select max(from_date) from dept_emp where emp_no = p_emp_no);
end $$
delimiter ;

call query_6(10010);

/*
Query 7
How many contracts have been registered in the ‘salaries’ table with duration of more than one year and
of value higher than or equal to $100,000?
Hint: You may wish to compare the difference between the start and end date of the salaries contracts.
*/
select
	count(emp_no)
from
	salaries
where
	datediff(to_date, from_date) > 365 and salary >= 100000;

/*
Query 8
Create a trigger that checks if the hire date of an employee is higher than the current date. If true, set the
hire date to equal the current date. Format the output appropriately (YY-mm-dd).
Extra challenge: You can try to declare a new variable called 'today' which stores today's data, and then
use it in your trigger!
After creating the trigger, execute the following code to see if it's working properly.
*/
drop trigger if exists query_7;

delimiter $$
create trigger query_7
before insert on employees
for each row
begin
	declare today date;
    select date_format(sysdate(),'%Y-%m-%d') into today;
	if new.hire_date > today then
    set new.hire_date = today;
    end if;
end $$
delimiter ;

insert into employees values ('999905', '1970-01-31', 'John', 'Johnson', 'M', '2025-01-01'); 

select * from employees where emp_no = '999905';

/* 
Query 9
Define a function that retrieves the largest contract salary value of an employee. Apply it to employee number 11356.
In addition, what is the lowest contract salary value of the same employee? You may want to create a new function that to obtain 
the result.
*/

drop function if exists query_max_9;

delimiter $$
create function query_max_9(p_emp_no integer) returns decimal(10,2)
deterministic
begin
	declare p_max_salary decimal(10,2);
    select max(salary) into p_max_salary from salaries where emp_no = p_emp_no;
    return p_max_salary;
end $$
delimiter ;

select query_max_9(11356);

drop function if exists query_min_9;

delimiter $$
create function query_min_9(p_emp_no integer) returns decimal(10,2)
deterministic
begin
	declare p_min_salary decimal(10,2);
    select min(salary) into p_min_salary from salaries where emp_no = p_emp_no;
    return p_min_salary;
end $$
delimiter ;

select query_min_9(11356);

/* 
Query 10
Based on the previous exercise, you can now try to create a third function that also accepts a second parameter. 
Let this parameter be a character sequence. Evaluate if its value is 'min' or 'max' and based on that retrieve either the 
lowest or the highest salary, respectively (using the same logic and code structure from Exercise 9). 
If the inserted value is any string value different from ‘min’ or ‘max’, let the function return the difference between the highest 
and the lowest salary of that employee.
*/

drop function if exists query_10;

delimiter $$
create function query_10(p_emp_no integer, p_value varchar(25)) returns decimal(10,2)
deterministic
begin
declare p_salary decimal(10,2);
select
	case
		when p_value = 'min' then min(salary)
        when p_value = 'max' then max(salary)
        else max(salary) - min(salary)
    end as emp_salary
into p_salary from salaries where emp_no = p_emp_no;
return p_salary;
end $$
delimiter ;

select query_10 (11356,'min');
select query_10 (11356,'max');
select query_10 (11356,'diff');





    
