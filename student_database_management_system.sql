-- ============================================================
-- STUDENT DATABASE MANAGEMENT SYSTEM
-- MySQL Academic Project
-- ============================================================
-- Author: <Your Name>
-- Description: A relational database to manage student records,
-- departments, courses, enrollments, attendance and fee payments.
-- ============================================================

-- ------------------------------------------------------------
-- 1. DATABASE CREATION
-- ------------------------------------------------------------
DROP DATABASE IF EXISTS student_db;
CREATE DATABASE student_db;
USE student_db;

-- ------------------------------------------------------------
-- 2. TABLE CREATION
-- ------------------------------------------------------------

-- Departments table
CREATE TABLE Departments (
    dept_id      INT AUTO_INCREMENT PRIMARY KEY,
    dept_name    VARCHAR(100) NOT NULL UNIQUE,
    hod_name     VARCHAR(100)
);

-- Students table
CREATE TABLE Students (
    student_id   INT AUTO_INCREMENT PRIMARY KEY,
    first_name   VARCHAR(50) NOT NULL,
    last_name    VARCHAR(50) NOT NULL,
    dob          DATE NOT NULL,
    gender       ENUM('Male', 'Female', 'Other') NOT NULL,
    email        VARCHAR(100) UNIQUE,
    phone        VARCHAR(15),
    address      VARCHAR(255),
    dept_id      INT,
    admission_year INT NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id)
        ON DELETE SET NULL
);

-- Courses table
CREATE TABLE Courses (
    course_id    INT AUTO_INCREMENT PRIMARY KEY,
    course_name  VARCHAR(100) NOT NULL,
    credits      INT NOT NULL CHECK (credits > 0),
    dept_id      INT,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id)
        ON DELETE SET NULL
);

-- Enrollments table (many-to-many: Students <-> Courses)
CREATE TABLE Enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id   INT NOT NULL,
    course_id    INT NOT NULL,
    semester     VARCHAR(20) NOT NULL,
    grade        CHAR(2),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
        ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
        ON DELETE CASCADE,
    UNIQUE (student_id, course_id, semester)
);

-- Attendance table
CREATE TABLE Attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id   INT NOT NULL,
    course_id    INT NOT NULL,
    class_date   DATE NOT NULL,
    status       ENUM('Present', 'Absent') NOT NULL,
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
        ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
        ON DELETE CASCADE
);

-- Fees table
CREATE TABLE Fees (
    fee_id       INT AUTO_INCREMENT PRIMARY KEY,
    student_id   INT NOT NULL,
    amount_due   DECIMAL(10,2) NOT NULL,
    amount_paid  DECIMAL(10,2) DEFAULT 0,
    payment_date DATE,
    status       ENUM('Paid', 'Pending', 'Partial') DEFAULT 'Pending',
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 3. SAMPLE DATA
-- ------------------------------------------------------------

INSERT INTO Departments (dept_name, hod_name) VALUES
('Computer Science', 'Dr. A. Sharma'),
('Electronics', 'Dr. R. Verma'),
('Mechanical', 'Dr. S. Patel');

INSERT INTO Students (first_name, last_name, dob, gender, email, phone, address, dept_id, admission_year) VALUES
('Rahul', 'Mehta', '2003-05-14', 'Male', 'rahul.mehta@example.com', '9876543210', 'Ahmedabad', 1, 2022),
('Priya', 'Shah', '2003-08-21', 'Female', 'priya.shah@example.com', '9876543211', 'Surat', 1, 2022),
('Aman', 'Joshi', '2002-11-02', 'Male', 'aman.joshi@example.com', '9876543212', 'Vadodara', 2, 2021),
('Sneha', 'Patel', '2003-02-17', 'Female', 'sneha.patel@example.com', '9876543213', 'Rajkot', 2, 2022),
('Karan', 'Desai', '2002-07-09', 'Male', 'karan.desai@example.com', '9876543214', 'Ahmedabad', 3, 2021);

INSERT INTO Courses (course_name, credits, dept_id) VALUES
('Database Management Systems', 4, 1),
('Data Structures', 4, 1),
('Digital Electronics', 3, 2),
('Thermodynamics', 3, 3),
('Operating Systems', 4, 1);

INSERT INTO Enrollments (student_id, course_id, semester, grade) VALUES
(1, 1, 'Sem5', 'A'),
(1, 2, 'Sem5', 'B+'),
(2, 1, 'Sem5', 'A+'),
(3, 3, 'Sem5', 'B'),
(4, 3, 'Sem5', 'A'),
(5, 4, 'Sem5', 'B+'),
(1, 5, 'Sem5', NULL);

INSERT INTO Attendance (student_id, course_id, class_date, status) VALUES
(1, 1, '2026-06-01', 'Present'),
(1, 1, '2026-06-02', 'Absent'),
(2, 1, '2026-06-01', 'Present'),
(3, 3, '2026-06-01', 'Present'),
(4, 3, '2026-06-01', 'Absent');

INSERT INTO Fees (student_id, amount_due, amount_paid, payment_date, status) VALUES
(1, 50000, 50000, '2026-01-10', 'Paid'),
(2, 50000, 25000, '2026-01-15', 'Partial'),
(3, 45000, 0, NULL, 'Pending'),
(4, 45000, 45000, '2026-01-12', 'Paid'),
(5, 48000, 0, NULL, 'Pending');

-- ------------------------------------------------------------
-- 4. USEFUL QUERIES (for viva / demonstration)
-- ------------------------------------------------------------

-- 4.1 List all students with their department name
SELECT s.student_id, CONCAT(s.first_name, ' ', s.last_name) AS full_name,
       d.dept_name, s.admission_year
FROM Students s
JOIN Departments d ON s.dept_id = d.dept_id;

-- 4.2 List courses along with number of students enrolled
SELECT c.course_name, COUNT(e.student_id) AS total_enrolled
FROM Courses c
LEFT JOIN Enrollments e ON c.course_id = e.course_id
GROUP BY c.course_name;

-- 4.3 Find students who have not paid fees fully
SELECT s.first_name, s.last_name, f.amount_due, f.amount_paid,
       (f.amount_due - f.amount_paid) AS balance
FROM Fees f
JOIN Students s ON f.student_id = s.student_id
WHERE f.status <> 'Paid';

-- 4.4 Calculate attendance percentage per student per course
SELECT s.first_name, s.last_name, c.course_name,
       ROUND(SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attendance_percent
FROM Attendance a
JOIN Students s ON a.student_id = s.student_id
JOIN Courses c ON a.course_id = c.course_id
GROUP BY s.student_id, c.course_id;

-- 4.5 List top scoring students (grade A or A+)
SELECT s.first_name, s.last_name, c.course_name, e.grade
FROM Enrollments e
JOIN Students s ON e.student_id = s.student_id
JOIN Courses c ON e.course_id = c.course_id
WHERE e.grade IN ('A', 'A+');

-- 4.6 Department-wise student count
SELECT d.dept_name, COUNT(s.student_id) AS total_students
FROM Departments d
LEFT JOIN Students s ON d.dept_id = s.dept_id
GROUP BY d.dept_name;

-- 4.7 Students who haven't enrolled in any course (subquery example)
SELECT first_name, last_name
FROM Students
WHERE student_id NOT IN (SELECT DISTINCT student_id FROM Enrollments);

-- ------------------------------------------------------------
-- 5. VIEW (simplifies repeated reporting query)
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW StudentFeeStatus AS
SELECT s.student_id, CONCAT(s.first_name, ' ', s.last_name) AS full_name,
       d.dept_name, f.amount_due, f.amount_paid, f.status
FROM Students s
JOIN Departments d ON s.dept_id = d.dept_id
JOIN Fees f ON s.student_id = f.student_id;

-- Usage: SELECT * FROM StudentFeeStatus;

-- ------------------------------------------------------------
-- 6. STORED PROCEDURE (adds a new student easily)
-- ------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE AddStudent (
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_dob DATE,
    IN p_gender ENUM('Male','Female','Other'),
    IN p_email VARCHAR(100),
    IN p_phone VARCHAR(15),
    IN p_address VARCHAR(255),
    IN p_dept_id INT,
    IN p_admission_year INT
)
BEGIN
    INSERT INTO Students (first_name, last_name, dob, gender, email, phone, address, dept_id, admission_year)
    VALUES (p_first_name, p_last_name, p_dob, p_gender, p_email, p_phone, p_address, p_dept_id, p_admission_year);
END //
DELIMITER ;

-- Usage example:
-- CALL AddStudent('Neha', 'Trivedi', '2003-03-03', 'Female', 'neha.t@example.com', '9998887777', 'Gandhinagar', 1, 2023);

-- ------------------------------------------------------------
-- 7. TRIGGER (auto-updates fee status when payment is made)
-- ------------------------------------------------------------
DELIMITER //
CREATE TRIGGER UpdateFeeStatus
BEFORE UPDATE ON Fees
FOR EACH ROW
BEGIN
    IF NEW.amount_paid >= NEW.amount_due THEN
        SET NEW.status = 'Paid';
    ELSEIF NEW.amount_paid > 0 THEN
        SET NEW.status = 'Partial';
    ELSE
        SET NEW.status = 'Pending';
    END IF;
END //
DELIMITER ;

-- Usage example (trigger fires automatically):
-- UPDATE Fees SET amount_paid = 45000, payment_date = CURDATE() WHERE student_id = 3;

-- ============================================================
-- END OF SCRIPT
-- ============================================================
