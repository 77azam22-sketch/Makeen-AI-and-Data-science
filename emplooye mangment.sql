-- ===========================================================
-- ProjectManagementDB - Complete SQL Script (small sample dataset)
-- Generated: 2025-11-13
-- Compatible with MySQL / MySQL Workbench
-- ===========================================================

DROP DATABASE IF EXISTS ProjectManagementDB;
CREATE DATABASE ProjectManagementDB;
USE ProjectManagementDB;

-- ===========================================================
-- TABLE: Employee
-- Stores employee information.
-- ===========================================================
CREATE TABLE IF NOT EXISTS Employee (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    JobTitle VARCHAR(100),
    Email VARCHAR(150) UNIQUE,
    HireDate DATE,
    CONSTRAINT chk_email CHECK (Email LIKE '%_@_%_.%')
);

-- ===========================================================
-- TABLE: Project
-- Stores projects. ManagerID references Employee(EmployeeID).
-- ===========================================================
CREATE TABLE IF NOT EXISTS Project (
    ProjectID INT AUTO_INCREMENT PRIMARY KEY,
    ProjectName VARCHAR(150) NOT NULL,
    Description TEXT,
    StartDate DATE,
    EndDate DATE,
    Status VARCHAR(20) DEFAULT 'Planned',
    ManagerID INT NULL,
    CONSTRAINT fk_project_manager FOREIGN KEY (ManagerID)
        REFERENCES Employee(EmployeeID)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT chk_project_dates CHECK (StartDate IS NULL OR EndDate IS NULL OR StartDate <= EndDate)
);

-- ===========================================================
-- TABLE: Task
-- Each task belongs to a project and may be assigned to an employee.
-- ===========================================================
CREATE TABLE IF NOT EXISTS Task (
    TaskID INT AUTO_INCREMENT PRIMARY KEY,
    TaskName VARCHAR(150) NOT NULL,
    Description TEXT,
    StartDate DATE,
    DueDate DATE,
    Status VARCHAR(20) DEFAULT 'To Do', -- To Do, In Progress, Completed, Blocked
    ProjectID INT NOT NULL,
    AssignedTo INT NULL,
    CONSTRAINT fk_task_project FOREIGN KEY (ProjectID)
        REFERENCES Project(ProjectID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_task_assignee FOREIGN KEY (AssignedTo)
        REFERENCES Employee(EmployeeID)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT chk_task_dates CHECK (StartDate IS NULL OR DueDate IS NULL OR StartDate <= DueDate)
);

-- ===========================================================
-- TABLE: ProjectTeam
-- Many-to-many: employees assigned to projects and their role.
-- ===========================================================
CREATE TABLE IF NOT EXISTS ProjectTeam (
    ProjectID INT NOT NULL,
    EmployeeID INT NOT NULL,
    RoleInProject VARCHAR(80),
    PRIMARY KEY (ProjectID, EmployeeID),
    CONSTRAINT fk_pt_project FOREIGN KEY (ProjectID)
        REFERENCES Project(ProjectID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_pt_employee FOREIGN KEY (EmployeeID)
        REFERENCES Employee(EmployeeID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ===========================================================
-- SAMPLE DATA: Employees (20)
-- Insert employees first so we can reference their IDs for managers/assignments.
-- ===========================================================
INSERT INTO Employee (FirstName, LastName, JobTitle, Email, HireDate) VALUES
('Aisha', 'Al-Harthy', 'Project Manager', 'aisha.alharthy@example.com', '2018-02-12'),
('Khalid', 'Salem', 'Senior Developer', 'khalid.salem@example.com', '2017-07-05'),
('Sara', 'Al-Farsi', 'Developer', 'sara.alfarsi@example.com', '2019-11-18'),
('Omar', 'Hassan', 'QA Engineer', 'omar.hassan@example.com', '2020-06-23'),
('Lina', 'Mahmoud', 'UI/UX Designer', 'lina.mahmoud@example.com', '2021-01-09'),
('Yousef', 'Nasser', 'DevOps Engineer', 'yousef.nasser@example.com', '2016-09-30'),
('Fatima', 'Khan', 'Business Analyst', 'fatima.khan@example.com', '2019-04-02'),
('Hamad', 'Al-Balushi', 'Developer', 'hamad.albalushi@example.com', '2022-03-11'),
('Maya', 'Omar', 'QA Engineer', 'maya.omar@example.com', '2018-10-15'),
('Sultan', 'Qureshi', 'Product Owner', 'sultan.qureshi@example.com', '2015-12-01'),
('Rida', 'Ali', 'Developer', 'rida.ali@example.com', '2020-08-20'),
('Noura', 'Saleh', 'Project Manager', 'noura.saleh@example.com', '2014-05-17'),
('Ibrahim', 'Faraj', 'Database Administrator', 'ibrahim.faraj@example.com', '2013-03-28'),
('Dana', 'Yusuf', 'Support Engineer', 'dana.yusuf@example.com', '2021-09-07'),
('Adnan', 'Zaki', 'Junior Developer', 'adnan.zaki@example.com', '2023-02-01'),
('Huda', 'Rahman', 'QA Lead', 'huda.rahman@example.com', '2016-11-22'),
('Tariq', 'Mansoor', 'Senior Developer', 'tariq.mansoor@example.com', '2012-06-14'),
('Zainab', 'Kamal', 'Designer', 'zainab.kamal@example.com', '2019-02-25'),
('Bilal', 'Aziz', 'Developer', 'bilal.aziz@example.com', '2020-12-05'),
('Rana', 'Hussein', 'Analyst', 'rana.hussein@example.com', '2018-08-30');

-- ===========================================================
-- SAMPLE DATA: Projects (8)
-- ManagerIDs reference Employee IDs above (1..20).
-- ===========================================================
INSERT INTO Project (ProjectName, Description, StartDate, EndDate, Status, ManagerID) VALUES
('Website Revamp', 'Complete redesign of corporate website to improve conversions and accessibility.', '2024-01-10', '2024-06-30', 'Completed', 1),
('Mobile App v2', 'Add new features and performance improvements to customer mobile app.', '2024-05-01', '2024-11-15', 'In Progress', 12),
('Billing System Migration', 'Migrate billing system to a new cloud provider with minimal downtime.', '2024-03-01', '2024-09-30', 'In Progress', 1),
('Internal Dashboard', 'Build internal KPI dashboard for business users.', '2024-07-01', '2024-10-15', 'Planned', 7),
('Customer Portal', 'New self-service portal for customers to manage accounts and tickets.', '2024-02-15', '2024-08-31', 'Completed', 12),
('DevOps Automation', 'Automate deployments and monitoring with CI/CD pipelines.', '2024-04-01', '2024-09-01', 'In Progress', 6),
('Data Warehouse', 'Create central data warehouse for reporting and analytics.', '2024-06-01', '2024-12-15', 'In Progress', 11),
('Security Audit', 'Third-party security audit and remediation plan.', '2024-09-01', '2024-10-15', 'Planned', 1);

-- ===========================================================
-- SAMPLE DATA: Tasks (~40)
-- Tasks reference ProjectID and AssignedTo employee IDs.
-- ===========================================================
INSERT INTO Task (TaskName, Description, StartDate, DueDate, Status, ProjectID, AssignedTo) VALUES
-- Website Revamp (ProjectID = 1)
('Create homepage wireframes','Wireframes for homepage and key templates','2024-01-11','2024-01-25','Completed',1,5),
('Implement responsive header/footer','Front-end implementation and cross-browser testing','2024-01-26','2024-02-10','Completed',1,3),
('Migrate CMS content','Move and validate all existing content to new CMS','2024-02-11','2024-03-05','Completed',1,11),
('Accessibility audit','WCAG 2.1 AA compliance fixes','2024-03-06','2024-04-01','Completed',1,16),
('SEO optimization','On-page SEO and analytics setup','2024-04-02','2024-05-01','Completed',1,2),

-- Mobile App v2 (ProjectID = 2)
('Design new onboarding flow','Design screens and user flow for onboarding','2024-05-02','2024-05-20','Completed',2,5),
('Implement offline sync','Ensure app can operate offline and sync later','2024-05-21','2024-07-15','In Progress',2,3),
('Performance profiling','Identify and fix bottlenecks on iOS and Android','2024-07-01','2024-08-15','In Progress',2,17),
('Push notification revamp','Improve reliability and segmentation','2024-08-16','2024-09-10','Planned',2,6),
('Beta testing & feedback','Manage external beta testers and triage bugs','2024-09-11','2024-10-15','Planned',2,9),

-- Billing System Migration (ProjectID = 3)
('Inventory current billing jobs','Document all current billing jobs and data flows','2024-03-02','2024-03-20','Completed',3,7),
('Data export scripts','Create scripts to export and validate data','2024-03-21','2024-04-15','Completed',3,13),
('Staging migration test','Perform dry-run on staging environment','2024-04-16','2024-05-10','Completed',3,6),
('Cutover plan & runbook','Prepare cutover steps and rollback plan','2024-05-11','2024-06-01','Completed',3,1),
('Post-migration validation','Confirm data integrity and jobs','2024-06-02','2024-06-20','Completed',3,11),

-- Internal Dashboard (ProjectID = 4)
('Requirements workshop','Meet with stakeholders to capture KPIs','2024-07-02','2024-07-12','Planned',4,7),
('Data model design','Design star schema and ETL mappings','2024-07-13','2024-08-05','Planned',4,11),
('Build dashboard MVP','Implement MVP charts and filters','2024-08-06','2024-09-01','Planned',4,2),
('User acceptance testing','Collect stakeholder feedback and iterate','2024-09-02','2024-09-18','Planned',4,10),

-- Customer Portal (ProjectID = 5)
('Portal architecture','Define microservices and APIs for portal','2024-02-16','2024-03-10','Completed',5,6),
('Auth & SSO integration','Implement single sign-on and auth flows','2024-03-11','2024-04-05','Completed',5,6),
('Ticketing integration','Connect portal to support ticket system','2024-04-06','2024-05-01','Completed',5,14),
('Customer data export','Allow customers to export their data','2024-05-02','2024-06-01','Completed',5,19),

-- DevOps Automation (ProjectID = 6)
('CI pipeline: build/test','Add CI jobs for unit & integration tests','2024-04-02','2024-04-25','Completed',6,6),
('CD pipeline: staging deploy','Automate staging deployments','2024-04-26','2024-05-20','Completed',6,6),
('Alerting & monitoring','Add dashboards and alert rules','2024-05-21','2024-06-30','In Progress',6,13),
('Infrastructure as code','Define terraform modules and state','2024-06-01','2024-07-15','In Progress',6,6),

-- Data Warehouse (ProjectID = 7)
('Source connectors','Implement connectors for key sources','2024-06-02','2024-07-10','In Progress',7,11),
('ETL orchestration','Add scheduled ETL jobs and monitoring','2024-07-11','2024-08-25','Planned',7,6),
('Reporting layer','Create reporting views and materialized tables','2024-08-26','2024-10-05','Planned',7,2),

-- Security Audit (ProjectID = 8)
('Vendor selection','Select audit vendor and sign contract','2024-09-02','2024-09-10','Planned',8,1),
('Pre-audit checklist','Internal remediation before audit','2024-09-11','2024-09-25','Planned',8,16),
('Audit run & report','Vendor runs audit and produces report','2024-09-26','2024-10-10','Planned',8,1),
('Remediation plan','Prioritize and schedule fixes','2024-10-11','2024-10-15','Planned',8,12);

-- ===========================================================
-- SAMPLE DATA: ProjectTeam assignments
-- Assign a small cross-functional team to each project.
-- ===========================================================
INSERT INTO ProjectTeam (ProjectID, EmployeeID, RoleInProject) VALUES
-- Project 1 team
(1,1,'Project Manager'),
(1,5,'UI/UX Designer'),
(1,3,'Front-end Developer'),
(1,11,'Backend Developer'),
(1,16,'QA'),

-- Project 2 team
(2,12,'Project Manager'),
(2,3,'Mobile Developer'),
(2,17,'Senior Developer'),
(2,9,'QA'),
(2,6,'DevOps'),

-- Project 3 team
(3,1,'Project Manager'),
(3,7,'Business Analyst'),
(3,13,'DBA'),
(3,11,'Developer'),
(3,6,'DevOps'),

-- Project 4 team
(4,7,'Business Analyst'),
(4,2,'Developer'),
(4,5,'Designer'),
(4,10,'Product Owner'),
(4,9,'QA'),

-- Project 5 team
(5,12,'Project Manager'),
(5,6,'DevOps'),
(5,14,'Support Engineer'),
(5,19,'Developer'),
(5,3,'Developer'),

-- Project 6 team
(6,6,'DevOps Lead'),
(6,13,'DBA'),
(6,2,'Developer'),
(6,16,'QA Lead'),
(6,11,'Developer'),

-- Project 7 team
(7,11,'Data Lead'),
(7,2,'Developer'),
(7,6,'DevOps'),
(7,7,'Analyst'),
(7,18,'Designer'),

-- Project 8 team
(8,1,'Sponsor'),
(8,16,'QA Lead'),
(8,12,'Project Manager'),
(8,13,'DBA'),
(8,14,'Support');

-- ===========================================================
-- INDEXES and HELPFUL CONSTRAINTS
-- ===========================================================
CREATE INDEX IF NOT EXISTS idx_employee_name ON Employee(LastName, FirstName);
CREATE INDEX IF NOT EXISTS idx_project_status ON Project(Status);
CREATE INDEX IF NOT EXISTS idx_task_project ON Task(ProjectID);
CREATE INDEX IF NOT EXISTS idx_task_assignee ON Task(AssignedTo);

-- ===========================================================
-- VIEWS - convenience
-- ===========================================================
DROP VIEW IF EXISTS vw_ProjectSummary;
CREATE VIEW vw_ProjectSummary AS
SELECT
  p.ProjectID,
  p.ProjectName,
  p.Status,
  p.StartDate,
  p.EndDate,
  CONCAT(e.FirstName, ' ', e.LastName) AS ManagerName,
  (SELECT COUNT(*) FROM Task t WHERE t.ProjectID = p.ProjectID) AS TotalTasks,
  (SELECT COUNT(*) FROM Task t WHERE t.ProjectID = p.ProjectID AND t.Status = 'Completed') AS CompletedTasks
FROM Project p
LEFT JOIN Employee e ON p.ManagerID = e.EmployeeID;

DROP VIEW IF EXISTS vw_TaskDetails;
CREATE VIEW vw_TaskDetails AS
SELECT
  t.TaskID,
  t.TaskName,
  t.Status,
  t.StartDate,
  t.DueDate,
  p.ProjectName,
  CONCAT(e.FirstName, ' ', e.LastName) AS AssignedToName
FROM Task t
JOIN Project p ON t.ProjectID = p.ProjectID
LEFT JOIN Employee e ON t.AssignedTo = e.EmployeeID;

-- ===========================================================
-- DEMO QUERIES / REPORTS
-- ===========================================================

-- 1) List all projects with progress percentage (CompletedTasks / TotalTasks)
SELECT
  ProjectID,
  ProjectName,
  Status,
  TotalTasks,
  CompletedTasks,
  CASE WHEN TotalTasks = 0 THEN 0
       ELSE ROUND(100.0 * CompletedTasks / TotalTasks, 1)
  END AS PercentComplete
FROM vw_ProjectSummary
ORDER BY PercentComplete DESC, ProjectName;

-- 2) Tasks overdue (not completed and DueDate < today)
SELECT t.TaskID, t.TaskName, t.Status, t.DueDate, p.ProjectName, CONCAT(e.FirstName, ' ', e.LastName) AS AssignedTo
FROM Task t
JOIN Project p ON t.ProjectID = p.ProjectID
LEFT JOIN Employee e ON t.AssignedTo = e.EmployeeID
WHERE t.Status <> 'Completed' AND t.DueDate < CURDATE()
ORDER BY t.DueDate ASC;

-- 3) Employee workload: number of active tasks per employee
SELECT
  e.EmployeeID,
  CONCAT(e.FirstName, ' ', e.LastName) AS Employee,
  COUNT(t.TaskID) AS ActiveTasks
FROM Employee e
LEFT JOIN Task t ON t.AssignedTo = e.EmployeeID AND t.Status <> 'Completed'
GROUP BY e.EmployeeID, e.FirstName, e.LastName
ORDER BY ActiveTasks DESC, Employee;

-- 4) Project timeline (Gantt-like): tasks per project ordered by start date
SELECT p.ProjectName, t.TaskName, t.StartDate, t.DueDate, t.Status
FROM Task t
JOIN Project p ON t.ProjectID = p.ProjectID
ORDER BY p.ProjectID, t.StartDate;

-- 5) Find projects without a manager (should be none in sample)
SELECT * FROM Project WHERE ManagerID IS NULL;

-- 6) Team members for a project (example: ProjectID = 2)
SELECT p.ProjectName, pt.RoleInProject, CONCAT(e.FirstName, ' ', e.LastName) AS Employee
FROM ProjectTeam pt
JOIN Project p ON pt.ProjectID = p.ProjectID
JOIN Employee e ON pt.EmployeeID = e.EmployeeID
WHERE p.ProjectID = 2;

-- 7) Quick KPI: count of projects by status
SELECT Status, COUNT(*) AS ProjectCount
FROM Project
GROUP BY Status;

-- ===========================================================
-- OPTIONAL: Example updates (commented)
-- ===========================================================
-- Mark a task as completed:
-- UPDATE Task SET Status = 'Completed' WHERE TaskID = 3;

-- Reassign a task:
-- UPDATE Task SET AssignedTo = 8 WHERE TaskID = 7;

-- Change project status:
-- UPDATE Project SET Status = 'Completed', EndDate = '2024-06-30' WHERE ProjectID = 1;

-- ===========================================================
-- End of script.
-- Save as ProjectManagementDB.sql and run in MySQL Workbench.
-- ===========================================================
-- ===========================================================
-- PROJECT MANAGEMENT DATABASE
-- GROUP BY / HAVING / ORDER BY PRACTICE
-- ===========================================================
-- This script assumes you already created and loaded data
-- in the ProjectManagementDB database.
-- ===========================================================

USE ProjectManagementDB;

-- ===========================================================
-- SECTION 1: SIMPLE GROUP BY QUERIES
-- ===========================================================

-- 1. Count how many employees are in the table
SELECT COUNT(*) AS TotalEmployees FROM Employee;

-- 2. Count how many projects exist
SELECT COUNT(*) AS TotalProjects FROM Project;

-- 3. Count how many tasks exist
SELECT COUNT(*) AS TotalTasks FROM Task;

-- 4. Count how many employees were hired each year
SELECT 
    YEAR(HireDate) AS HireYear,
    COUNT(EmployeeID) AS EmployeesHired
FROM Employee
GROUP BY YEAR(HireDate)
ORDER BY HireYear;

-- 5. Count how many tasks per project
SELECT 
    ProjectID,
    COUNT(TaskID) AS TotalTasks
FROM Task
GROUP BY ProjectID;

-- ===========================================================
-- SECTION 2: USING ORDER BY WITH GROUP BY
-- ===========================================================

-- 6. Count projects per manager, sorted by most managed
SELECT 
    CONCAT(e.FirstName, ' ', e.LastName) AS ManagerName,
    COUNT(p.ProjectID) AS TotalProjects
FROM Project p
INNER JOIN Employee e ON p.ManagerID = e.EmployeeID
GROUP BY ManagerName
ORDER BY TotalProjects DESC;

-- 7. Show average project duration by status
SELECT 
    Status,
    ROUND(AVG(DATEDIFF(EndDate, StartDate)), 2) AS AvgDurationDays
FROM Project
GROUP BY Status
ORDER BY AvgDurationDays DESC;

-- 8. Show how many tasks each employee is assigned to
SELECT 
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
    COUNT(t.TaskID) AS TotalAssignedTasks
FROM Employee e
LEFT JOIN Task t ON e.EmployeeID = t.AssignedTo
GROUP BY EmployeeName
ORDER BY TotalAssignedTasks DESC;

-- ===========================================================
-- SECTION 3: USING HAVING CLAUSE
-- ===========================================================

-- 9. Show projects that have more than 5 tasks
SELECT 
    ProjectID,
    COUNT(TaskID) AS TotalTasks
FROM Task
GROUP BY ProjectID
HAVING COUNT(TaskID) > 5
ORDER BY TotalTasks DESC;

-- 10. Show employees who are assigned to more than 3 tasks
SELECT 
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
    COUNT(t.TaskID) AS TotalTasks
FROM Employee e
INNER JOIN Task t ON e.EmployeeID = t.AssignedTo
GROUP BY EmployeeName
HAVING COUNT(t.TaskID) > 3
ORDER BY TotalTasks DESC;

-- 11. Show managers who manage more than 1 project
SELECT 
    CONCAT(e.FirstName, ' ', e.LastName) AS ManagerName,
    COUNT(p.ProjectID) AS ManagedProjects
FROM Employee e
INNER JOIN Project p ON e.EmployeeID = p.ManagerID
GROUP BY ManagerName
HAVING COUNT(p.ProjectID) > 1
ORDER BY ManagedProjects DESC;

-- ===========================================================
-- SECTION 4: COMBINED ANALYSIS (HARDER)
-- ===========================================================

-- 12. Count how many members are assigned per project (from ProjectTeam)
SELECT 
    p.ProjectName,
    COUNT(pt.EmployeeID) AS TotalMembers
FROM Project p
LEFT JOIN ProjectTeam pt ON p.ProjectID = pt.ProjectID
GROUP BY p.ProjectName
ORDER BY TotalMembers DESC;

-- 13. Count how many projects each employee is part of
SELECT 
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
    COUNT(pt.ProjectID) AS TotalProjects
FROM Employee e
LEFT JOIN ProjectTeam pt ON e.EmployeeID = pt.EmployeeID
GROUP BY EmployeeName
ORDER BY TotalProjects DESC;

-- 14. Average number of tasks per employee
SELECT 
    ROUND(AVG(TaskCount), 2) AS AvgTasksPerEmployee
FROM (
    SELECT COUNT(TaskID) AS TaskCount
    FROM Task
    GROUP BY AssignedTo
) AS EmployeeTaskCounts;

-- 15. Show the total number of tasks per project status
SELECT 
    p.Status AS ProjectStatus,
    COUNT(t.TaskID) AS TotalTasks
FROM Project p
LEFT JOIN Task t ON p.ProjectID = t.ProjectID
GROUP BY p.Status
ORDER BY TotalTasks DESC;

-- ===========================================================
-- SECTION 5: ADVANCED INSIGHTFUL ANALYSIS
-- ===========================================================

-- 16. Show each project with its number of completed tasks
SELECT 
    p.ProjectName,
    SUM(CASE WHEN t.Status = 'Completed' THEN 1 ELSE 0 END) AS CompletedTasks
FROM Project p
LEFT JOIN Task t ON p.ProjectID = t.ProjectID
GROUP BY p.ProjectName
ORDER BY CompletedTasks DESC;

-- 17. Show employees who are part of the most projects
SELECT 
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
    COUNT(pt.ProjectID) AS TotalProjects
FROM Employee e
INNER JOIN ProjectTeam pt ON e.EmployeeID = pt.EmployeeID
GROUP BY EmployeeName
HAVING COUNT(pt.ProjectID) >= 1
ORDER BY TotalProjects DESC;

-- 18. Show project average task completion rate (percentage)
SELECT 
    p.ProjectName,
    ROUND(100 * SUM(CASE WHEN t.Status = 'Completed' THEN 1 ELSE 0 END) / COUNT(t.TaskID), 2) AS CompletionRate
FROM Project p
LEFT JOIN Task t ON p.ProjectID = t.ProjectID
GROUP BY p.ProjectName
ORDER BY CompletionRate DESC;

-- 19. Show employees with the earliest hire dates who are still active in projects
SELECT 
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
    MIN(e.HireDate) AS HireDate,
    COUNT(pt.ProjectID) AS ActiveProjects
FROM Employee e
INNER JOIN ProjectTeam pt ON e.EmployeeID = pt.EmployeeID
GROUP BY EmployeeName
HAVING ActiveProjects > 0
ORDER BY HireDate ASC;

-- 20. Average task duration (in days) per project
SELECT 
    p.ProjectName,
    ROUND(AVG(DATEDIFF(t.DueDate, t.StartDate)), 1) AS AvgTaskDuration
FROM Project p
LEFT JOIN Task t ON p.ProjectID = t.ProjectID
GROUP BY p.ProjectName
ORDER BY AvgTaskDuration DESC;

-- ===========================================================
-- END OF FILE
-- ===========================================================