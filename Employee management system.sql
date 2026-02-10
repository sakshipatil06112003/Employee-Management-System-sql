create database employee;
use employee;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
select * from JobDepartment;

-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
select * from SalaryBonus;

-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
select * from Employee;

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
select * from qualification;

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

select * from Leaves;

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL 
        ON UPDATE CASCADE
);
select * from Payroll;

-- RUN SAFETY CHECKS (Missing Relations)
-- Employees without job
select * from Employee where Job_ID is null;

-- Salary rows without job
select * from SalaryBonus where Job_ID is null;

-- Payroll with missing foreign keys
select * 
from Payroll 
where emp_ID is null 
   or job_ID is null
   or salary_ID is null;

-- Analysis Questions
-- 1. EMPLOYEE INSIGHTS

-- ● How many unique employees are currently in the system?
Select Count(Distinct emp_ID) as unique_employees 
from Employee;

-- ● Which departments have the highest number of employees?
Select jd.jobdept as department, count(e.emp_ID) as employee_count
From Employee e
Join JobDepartment jd on e.Job_ID = jd.Job_ID
Group by jd.jobdept
Order by employee_count Desc;

Select jd.jobdept as department, count(e.emp_ID) as employee_count
From Employee e
Join JobDepartment jd on e.Job_ID = jd.Job_ID
Group by jd.jobdept
Order by employee_count Desc
limit 2;

-- ● What is the average salary per department?
Select jd.jobdept as department, 
	   avg(sb.amount) as avg_monthly_salary
from Employee e
join JobDepartment jd on e.Job_ID = jd.Job_ID
join SalaryBonus sb on jd.Job_ID = sb.Job_ID
Group by jd.jobdept
Order by avg_monthly_salary Desc;

-- ● Who are the top 5 highest-paid employees?
-- by payroll:
Select p.payroll_ID, p.emp_ID, e.firstname, e.lastname, p.total_amount
From Payroll p
Join Employee e on p.emp_ID = e.emp_ID
Order by p.total_amount Desc
Limit 5;

-- ● What is the total salary expenditure across the company?
SELECT sum(total_amount) AS total_salary_expenditure
FROM Payroll;

-- 2. JOB ROLE AND DEPARTMENT ANALYSIS

-- ● How many different job roles exist in each department?
Select jobdept as department, Count(Distinct name) as roles_count
From JobDepartment
Group by jobdept
Order by roles_count Desc;

-- ● What is the average salary range per department?
Select jd.jobdept as department,
       Avg(sb.amount) as avg_monthly_salary
From JobDepartment jd
Join SalaryBonus sb On jd.Job_ID = sb.Job_ID
Group by jd.jobdept
Order by avg_monthly_salary Desc;

-- ● Which job roles offer the highest salary?
Select jd.name as job_role, jd.jobdept as department, sb.amount as monthly_salary, sb.annual as annual_salary
From JobDepartment jd
Join SalaryBonus sb on jd.Job_ID = sb.Job_ID
Order by sb.amount Desc
Limit 1;

-- ● Which departments have the highest total salary allocation?
Select jd.jobdept as department,
       Sum(p.total_amount) as total_salary_allocation
From Payroll p
Join Employee e On p.emp_ID = e.emp_ID
Join JobDepartment jd On e.Job_ID = jd.Job_ID
Group by jd.jobdept
Order by total_salary_allocation Desc
Limit 1;

-- 3. QUALIFICATION AND SKILLS ANALYSIS

-- ● How many employees have at least one qualification listed?
Select Count(Distinct Emp_ID) as Employees_With_Qualification
From qualification;

-- ● Which positions require the most qualifications?
Select Position, Count(QualID) as qualification_count
From Qualification
Group by Position
Order by qualification_count DESC;

-- ● Which employees have the highest number of qualifications?
Select e.emp_ID, e.firstname, e.lastname, Count(q.QualID) as num_quals
From Employee e
Join Qualification q On e.emp_ID = q.Emp_ID
Group by e.emp_ID
Order By num_quals Desc
Limit 1;

-- 4. LEAVE AND ABSENCE PATTERNS

-- ● Which year had the most employees taking leaves?
Select Year(date) as yr, COUNT(distinct Emp_Id) as leave_days
From Leaves
Group by Year(date)
Order by leave_days DESC
Limit 1;

-- ● What is the average number of leave days taken by its employees per department?
Select jd.jobdept as Department,
	Count(l.leave_ID) / COUNT(Distinct e.emp_ID) as Avg_Leave_Days_Per_Employee
From Employee e 
Join JobDepartment jd On e.Job_ID = jd.Job_ID
Join Leaves l On e.emp_ID = l.emp_ID
Group by jd.jobdept
Order by Avg_Leave_Days_Per_Employee Desc;

Select Jobdept, avg(LeaveCount) as Avg_Leave_Days_Per_Employee
From (
    Select e.Emp_ID, jd.Jobdept, COUNT(l.Leave_ID) as LeaveCount
    From employee e
    Join jobdepartment jd on e.Job_ID = jd.Job_ID
    left Join leaves l on e.Emp_ID = l.Emp_ID
    Group By e.Emp_ID, JobDept
) as temp
group by JobDept
Order by Avg_Leave_Days_Per_Employee desc;

-- ● Which employees have taken the most leaves?
Select e.emp_ID, e.firstname, e.lastname, COUNT(l.leave_ID) as leave_days
From Employee e
Join Leaves l on e.emp_ID = l.emp_ID
Group by e.emp_ID
Order by leave_days Desc
Limit 1;

-- ● What is the total number of leave days taken company-wide?
Select Count(*) as total_leave_days_companywide 
From Leaves;

-- ● How do leave days correlate with payroll amounts?
Select e.emp_ID, e.firstname, e.lastname, COUNT(Distinct l.leave_ID) as leave_days,SUM(Distinct p.total_amount) as total_pay
From Employee e
Left join Leaves l on e.emp_ID = l.emp_ID
Left join Payroll p on e.emp_ID = p.emp_ID
group by  e.emp_ID, e.firstname, e.lastname;

-- 5. PAYROLL AND COMPENSATION ANALYSIS

-- ● What is the total monthly payroll processed?
SELECT SUM(Total_Amount) AS Total_Monthly_Payroll
FROM payroll;

-- ● What is the average bonus given per department?
Select jd.jobdept as Department,
       avg(sb.bonus) as Average_Bonus
From salarybonus sb
Join JobDepartment jd on sb.Job_ID = jd.Job_ID
Group by jd.jobdept
Order by Average_Bonus Desc;

-- ● Which department receives the highest total bonuses?
Select jd.jobdept as department,
       SUM(sb.bonus) as total_bonus
From JobDepartment jd
join SalaryBonus sb on jd.Job_ID = sb.Job_ID
Group by jd.jobdept
order by total_bonus Desc
LIMIT 1;

-- ● What is the average value of total_amount after considering leave deductions?
Select Avg(Total_Amount - (Leave_Count * 500)) AS Average_After_Deductions
From (
    Select 
        p.Emp_ID,
        p.Total_Amount,
        COUNT(l.Leave_ID) as Leave_Count
    From payroll p
    Left Join leaves l On p.Emp_ID = l.Emp_ID
    Group by p.Emp_ID, p.Total_Amount
) as t;
