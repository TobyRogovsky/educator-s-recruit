-- Educators Recruit business scenario
-- T-SQL script to create tables, insert sample data and run report queries

-- Drop existing objects if they exist
DROP TABLE IF EXISTS dbo.Application;
DROP TABLE IF EXISTS dbo.Vacancy;
DROP TABLE IF EXISTS dbo.Candidate;
DROP TABLE IF EXISTS dbo.School;
GO

-- Create table for schools
CREATE TABLE dbo.School(
    SchoolID INT IDENTITY(1,1) PRIMARY KEY,
    SchoolName NVARCHAR(100) NOT NULL
);
GO

-- Create table for candidates
CREATE TABLE dbo.Candidate(
    CandidateID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Phone NVARCHAR(20)
);
GO

-- Create table for vacancies
CREATE TABLE dbo.Vacancy(
    VacancyID INT IDENTITY(1,1) PRIMARY KEY,
    SchoolID INT NOT NULL,
    Subject NVARCHAR(100) NOT NULL,
    StartDate DATE NOT NULL,
    Status NVARCHAR(20) NOT NULL,
    CONSTRAINT CHK_Vacancy_Status CHECK (Status IN ('Open','Closed')),
    CONSTRAINT FK_Vacancy_School FOREIGN KEY (SchoolID) REFERENCES dbo.School(SchoolID)
);
GO

-- Create table for applications
CREATE TABLE dbo.Application(
    ApplicationID INT IDENTITY(1,1) PRIMARY KEY,
    CandidateID INT NOT NULL,
    VacancyID INT NOT NULL,
    ApplicationDate DATE NOT NULL,
    Status NVARCHAR(20) NOT NULL,
    CONSTRAINT CHK_Application_Status CHECK (Status IN ('Pending','Interview','Hired')),
    CONSTRAINT UQ_Application UNIQUE (CandidateID, VacancyID),
    CONSTRAINT FK_Application_Candidate FOREIGN KEY (CandidateID) REFERENCES dbo.Candidate(CandidateID),
    CONSTRAINT FK_Application_Vacancy FOREIGN KEY (VacancyID) REFERENCES dbo.Vacancy(VacancyID)
);
GO

-- Insert sample data into School
INSERT INTO dbo.School (SchoolName)
VALUES
    ('Northside Elementary'),
    ('Westview High');
GO

-- Insert sample data into Candidate
INSERT INTO dbo.Candidate (FirstName, LastName, Email, Phone)
VALUES
    ('Alice', 'Johnson', 'alice.johnson@example.com', '555-0101'),
    ('Bob', 'Smith', 'bob.smith@example.com', '555-0202'),
    ('Carol', 'Davis', 'carol.davis@example.com', '555-0303');
GO

-- Insert sample data into Vacancy
INSERT INTO dbo.Vacancy (SchoolID, Subject, StartDate, Status)
VALUES
    (1, 'Math', '2025-08-15', 'Open'),
    (1, 'English', '2025-08-15', 'Open'),
    (2, 'Science', '2025-08-01', 'Closed');
GO

-- Insert sample data into Application
INSERT INTO dbo.Application (CandidateID, VacancyID, ApplicationDate, Status)
VALUES
    (1, 1, '2025-07-01', 'Interview'),
    (2, 1, '2025-07-02', 'Pending'),
    (2, 3, '2025-06-20', 'Hired'),
    (3, 2, '2025-07-03', 'Pending');
GO

-- Report 1: List open vacancies with number of applicants
SELECT v.VacancyID, s.SchoolName, v.Subject, COUNT(a.ApplicationID) AS ApplicantCount
FROM dbo.Vacancy v
LEFT JOIN dbo.School s ON v.SchoolID = s.SchoolID
LEFT JOIN dbo.Application a ON v.VacancyID = a.VacancyID
WHERE v.Status = 'Open'
GROUP BY v.VacancyID, s.SchoolName, v.Subject;
GO

-- Report 2: Candidate applications with current status
SELECT c.FirstName, c.LastName, v.Subject, a.Status
FROM dbo.Application a
JOIN dbo.Candidate c ON a.CandidateID = c.CandidateID
JOIN dbo.Vacancy v ON a.VacancyID = v.VacancyID;
GO

-- Report 3: Number of hired candidates per school
SELECT s.SchoolName, COUNT(*) AS HiredCount
FROM dbo.Application a
JOIN dbo.Vacancy v ON a.VacancyID = v.VacancyID
JOIN dbo.School s ON v.SchoolID = s.SchoolID
WHERE a.Status = 'Hired'
GROUP BY s.SchoolName;
GO

