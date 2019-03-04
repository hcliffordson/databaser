CREATE TABLE Departments (
    code            CHAR(4)             UNIQUE NOT NULL,
    name            TEXT                PRIMARY KEY
);

CREATE TABLE Programs (
    name            TEXT                PRIMARY KEY,
    code            CHAR(4)             NOT NULL
);

CREATE TABLE DepartmentPrograms (
    department      TEXT                REFERENCES Departments(name) on delete cascade not null,
    program         TEXT                REFERENCES Programs(name) on delete cascade not null,
    PRIMARY KEY     (department, program)
);

CREATE TABLE Branches (
	name 		    CHAR(2) 		    NOT NULL,
	program 	    TEXT 		        REFERENCES Programs(name),
	PRIMARY KEY     (name, program)
);

CREATE TABLE Students (
	idnr		    NUMERIC(10)		    PRIMARY KEY,
	name 		    TEXT			    NOT NULL,
	login		    CHAR(3)			    NOT NULL,
	program 	    TEXT 		        REFERENCES Programs(name) on delete cascade not null,
    UNIQUE(idnr, program)
);

CREATE TABLE Courses(
	code 		    CHAR(6)			    PRIMARY KEY,
	name		    CHAR(2)			    NOT NULL,
	credits		    NUMERIC(2)		    NOT NULL,
	department	    TEXT		        REFERENCES Departments(name) on delete cascade
);

CREATE TABLE LimitedCourses (
	code 		    CHAR(6)			    PRIMARY KEY,
	seats 		    BIGINT			    NOT NULL,
	FOREIGN KEY     (code)			    REFERENCES		Courses(code) on delete cascade,
	CHECK		    (seats >= 0)
);

CREATE TABLE Classifications(
	name		    TEXT			    PRIMARY KEY
);

CREATE TABLE StudentBranches (
	student 	    NUMERIC(10)			REFERENCES 		Students(idnr),
	branch 		    CHAR(2)				NOT NULL,
	program		    TEXT				NOT NULL,
	FOREIGN KEY	    (branch, program)	REFERENCES		Branches(name, program),
    FOREIGN KEY     (student, program)  REFERENCES      Students(idnr, program),
	PRIMARY KEY     (student)
);

CREATE TABLE ClassifiedCourses (
	course 			CHAR(6)			    REFERENCES      Courses(code) on delete cascade not null,
	classification	TEXT			    REFERENCES		Classifications(name) on delete cascade not null,
	PRIMARY KEY     (course, classification)
);

CREATE TABLE MandatoryProgramCourses (
	course 			CHAR(6)				REFERENCES	Courses(code) on delete cascade not null,
	program 	    TEXT				REFERENCES  Programs(name) on delete cascade not null,
	PRIMARY KEY     (course, program)
);

CREATE TABLE MandatoryBranchCourses (
	course 		    CHAR(6)				REFERENCES		Courses(code) on delete cascade not null,
	branch 		    CHAR(2)				NOT NULL,
	program 	    TEXT				NOT NULL,
	FOREIGN KEY     (branch, program)	REFERENCES		Branches(name, program),
	PRIMARY KEY     (course, branch, program)
);

CREATE TABLE RecommendedBranchCourses (
	course 		    CHAR(6)				REFERENCES		Courses(code) on delete cascade not null,
	branch 		    CHAR(2)				NOT NULL,
	program 	    TEXT				NOT NULL,
	FOREIGN KEY     (branch, program)	REFERENCES	    Branches(name, program),
	PRIMARY KEY     (course, branch, program)
);

CREATE TABLE RegisteredCourses (
	student 	    NUMERIC(10)			REFERENCES		Students(idnr),
	course 		    CHAR(6)				REFERENCES		Courses(code),
	PRIMARY KEY     (student, course)
);

CREATE TABLE TakenCourses (
	student 	    NUMERIC(10)		    REFERENCES 		Students(idnr) on delete cascade not null,
	course 		    CHAR(6)			    REFERENCES		Courses(code) on delete cascade not null,
	grade		    CHAR(1)			    NOT NULL,
	CHECK		    (grade IN ('5','4','3','U')),
	PRIMARY KEY     (student, course)
);

CREATE TABLE WaitingList (
	student 	    NUMERIC(10)		    REFERENCES 		Students(idnr) on delete cascade not null,
	course 		    CHAR(6)			    REFERENCES		LimitedCourses on delete cascade not null,
	position	    SERIAL			    NOT NULL,
	PRIMARY KEY     (student, course),
    UNIQUE(course, position)
	
);

CREATE TABLE RestrictedCourses (
    course          CHAR(6)             REFERENCES      Courses(code) on delete cascade not null,
    required_course CHAR(6)             REFERENCES      Courses(code) on delete cascade not null,
    PRIMARY KEY     (course, required_course)  
); 

INSERT INTO Departments VALUES ('CSEP', 'Dep1');
INSERT INTO Departments VALUES ('CSDA', 'Dep2');
INSERT INTO Departments VALUES ('ENMA', 'Dep3');
INSERT INTO Departments VALUES ('PHYM', 'Dep4');

INSERT INTO Programs VALUES ('Prog1', 'TKIT');
INSERT INTO Programs VALUES ('Prog2', 'TKDA');
INSERT INTO Programs VALUES ('Prog3', 'TKSB');
INSERT INTO Programs VALUES ('Prog4', 'TKMA');

INSERT INTO Branches VALUES ('B1','Prog1');
INSERT INTO Branches VALUES ('B2','Prog1');
INSERT INTO Branches VALUES ('B1','Prog2');

INSERT INTO DepartmentPrograms VALUES ('Dep1', 'Prog1');
INSERT INTO DepartmentPrograms VALUES ('Dep2', 'Prog2');
INSERT INTO DepartmentPrograms VALUES ('Dep3', 'Prog3');
INSERT INTO DepartmentPrograms VALUES ('Dep4', 'Prog4');

INSERT INTO Students VALUES (1111111111,'S1','ls1','Prog1');
INSERT INTO Students VALUES (2222222222,'S2','ls2','Prog1');
INSERT INTO Students VALUES (3333333333,'S3','ls3','Prog1');
INSERT INTO Students VALUES (4444444444,'S4','ls4','Prog1');
INSERT INTO Students VALUES (5555555555,'S5','ls5','Prog2');
INSERT INTO Students VALUES (6666666666,'S6','ls6','Prog2');
INSERT INTO Students VALUES (7777777777,'S7','ls7','Prog2');
INSERT INTO Students VALUES (8888888888,'S8','ls8','Prog2');

INSERT INTO Courses VALUES ('CCC111','C1',15,'Dep1');
INSERT INTO Courses VALUES ('CCC222','C2',5, 'Dep1');
INSERT INTO Courses VALUES ('CCC333','C3',10,'Dep1');
INSERT INTO Courses VALUES ('CCC444','C4',30,'Dep2');
INSERT INTO Courses VALUES ('CCC555','C5',10,'Dep2');
INSERT INTO Courses VALUES ('CCC666','C6',10,'Dep2');

INSERT INTO LimitedCourses VALUES ('CCC222',1);
INSERT INTO LimitedCourses VALUES ('CCC333',2);

INSERT INTO Classifications VALUES ('math');
INSERT INTO Classifications VALUES ('research');
INSERT INTO Classifications VALUES ('seminar');

INSERT INTO ClassifiedCourses VALUES ('CCC111','math');
INSERT INTO ClassifiedCourses VALUES ('CCC222','research');
INSERT INTO ClassifiedCourses VALUES ('CCC333','seminar');
INSERT INTO ClassifiedCourses VALUES ('CCC444','math');
INSERT INTO ClassifiedCourses VALUES ('CCC555','research');

INSERT INTO MandatoryProgramCourses VALUES ('CCC111','Prog1');
INSERT INTO MandatoryProgramCourses VALUES ('CCC222','Prog1');
INSERT INTO MandatoryProgramCourses VALUES ('CCC333','Prog2');

INSERT INTO MandatoryBranchCourses VALUES ('CCC444', 'B1', 'Prog1');
INSERT INTO MandatoryBranchCourses VALUES ('CCC555', 'B2', 'Prog1');
INSERT INTO MandatoryBranchCourses VALUES ('CCC555', 'B1', 'Prog2');

INSERT INTO RecommendedBranchCourses VALUES ('CCC555', 'B1', 'Prog1');
INSERT INTO RecommendedBranchCourses VALUES ('CCC444', 'B2', 'Prog1');
INSERT INTO RecommendedBranchCourses VALUES ('CCC666', 'B1', 'Prog2');

INSERT INTO RegisteredCourses VALUES (2222222222,'CCC444');
INSERT INTO RegisteredCourses VALUES (5555555555,'CCC555');
INSERT INTO RegisteredCourses VALUES (6666666666,'CCC333');
--INSERT INTO RegisteredCourses VALUES (3333333333,'CCC222');

INSERT INTO WaitingList VALUES(3333333333,'CCC222',1);
INSERT INTO WaitingList VALUES(3333333333,'CCC333',1);
INSERT INTO WaitingList VALUES(2222222222,'CCC333',2);

INSERT INTO StudentBranches VALUES (2222222222,'B1','Prog1');
INSERT INTO StudentBranches VALUES (3333333333,'B2','Prog1');
INSERT INTO StudentBranches VALUES (4444444444,'B2','Prog1');
INSERT INTO StudentBranches VALUES (5555555555,'B1','Prog2');
INSERT INTO StudentBranches VALUES (6666666666,'B1','Prog2');
INSERT INTO StudentBranches VALUES (7777777777,'B1','Prog2');
INSERT INTO StudentBranches VALUES (8888888888,'B1','Prog2');


INSERT INTO TakenCourses VALUES(1111111111,'CCC111','5');
--INSERT INTO TakenCourses VALUES(1111111111,'CCC222','4');
INSERT INTO TakenCourses VALUES(1111111111,'CCC333','3');
INSERT INTO TakenCourses VALUES(1111111111,'CCC444','4');
INSERT INTO TakenCourses VALUES(1111111111,'CCC555','5');
INSERT INTO TakenCourses VALUES(1111111111,'CCC666','5');

INSERT INTO TakenCourses VALUES(2222222222,'CCC111','5');
-- INTO TakenCourses VALUES(2222222222,'CCC222','3');
INSERT INTO TakenCourses VALUES(2222222222,'CCC333','5');
INSERT INTO TakenCourses VALUES(2222222222,'CCC555','5');
INSERT INTO TakenCourses VALUES(2222222222,'CCC666','5');

INSERT INTO TakenCourses VALUES(3333333333,'CCC111','4');
INSERT INTO TakenCourses VALUES(3333333333,'CCC333','4');
INSERT INTO TakenCourses VALUES(3333333333,'CCC444','5');
INSERT INTO TakenCourses VALUES(3333333333,'CCC555','5');
INSERT INTO TakenCourses VALUES(3333333333,'CCC666','4');

INSERT INTO TakenCourses VALUES(4444444444,'CCC111','5');
-- INTO TakenCourses VALUES(4444444444,'CCC222','5');
INSERT INTO TakenCourses VALUES(4444444444,'CCC333','5');
INSERT INTO TakenCourses VALUES(4444444444,'CCC444','U');
INSERT INTO TakenCourses VALUES(4444444444,'CCC555','5');
INSERT INTO TakenCourses VALUES(4444444444,'CCC666','5');

INSERT INTO TakenCourses VALUES(5555555555,'CCC111','5');
--INSERT INTO TakenCourses VALUES(5555555555,'CCC222','5');
INSERT INTO TakenCourses VALUES(5555555555,'CCC333','3');
INSERT INTO TakenCourses VALUES(5555555555,'CCC444','3');
INSERT INTO TakenCourses VALUES(5555555555,'CCC666','4');

INSERT INTO TakenCourses VALUES(6666666666,'CCC111','5');
-- INSERT INTO TakenCourses VALUES(6666666666,'CCC222','5');
INSERT INTO TakenCourses VALUES(6666666666,'CCC333','U');
INSERT INTO TakenCourses VALUES(6666666666,'CCC444','3');
INSERT INTO TakenCourses VALUES(6666666666,'CCC555','5');
INSERT INTO TakenCourses VALUES(6666666666,'CCC666','3');

INSERT INTO TakenCourses VALUES(7777777777,'CCC111','4');
INSERT INTO TakenCourses VALUES(7777777777,'CCC222','4');
INSERT INTO TakenCourses VALUES(7777777777,'CCC333','4');
INSERT INTO TakenCourses VALUES(7777777777,'CCC444','4');
INSERT INTO TakenCourses VALUES(7777777777,'CCC555','5');

INSERT INTO TakenCourses VALUES(8888888888,'CCC111','5');
-- INSERT INTO TakenCourses VALUES(8888888888,'CCC222','5');
--INSERT INTO TakenCourses VALUES(8888888888,'CCC333','5');
INSERT INTO TakenCourses VALUES(8888888888,'CCC444','5');
INSERT INTO TakenCourses VALUES(8888888888,'CCC555','5');
INSERT INTO TakenCourses VALUES(8888888888,'CCC666','5');

INSERT INTO RestrictedCourses VALUES ('CCC333', 'CCC222');


CREATE VIEW BasicInformation AS
(
	SELECT DISTINCT s.idnr, s.name, s.login, s.program, sb.branch
	FROM Students AS s LEFT OUTER JOIN StudentBranches as sb ON (s.idnr = sb.student)
);

CREATE VIEW FinishedCourses AS
(
	SELECT t.student as Students, t.course as course, t.grade as grade, c.credits as credits
	FROM TakenCourses AS t INNER JOIN Courses AS c ON (t.course=c.code) 
);

CREATE VIEW PassedCourses AS
(
	SELECT t.student as Student, t.course as course, c.credits as credits
	FROM TakenCourses AS t INNER JOIN Courses AS c ON (t.course=c.code)
	WHERE (t.grade <> 'U')
);

CREATE OR REPLACE VIEW Registrations AS
(
	SELECT student, course, 'registered' AS status
	FROM RegisteredCourses
	UNION
	SELECT student, course, 'waiting' AS status
	FROM WaitingList
	ORDER BY status	
);

CREATE VIEW UnreadMandatory AS (
    (SELECT idnr as student, course
        FROM MandatoryProgramCourses
        INNER JOIN 
        Students
        ON Students.program = MandatoryProgramCourses.program
    UNION
    SELECT idnr, course
        FROM MandatoryBranchCourses
        NATURAL INNER JOIN
        Students
    )
    EXCEPT 
    (
        SELECT student, course
        FROM PassedCourses
    )
);

CREATE VIEW RecommndedTakenCoursesForStudent AS (
    (SELECT sb.student, sb.branch, RecommendedBranchCourses.course,pc.credits
        FROM StudentBranches as sb
        INNER JOIN
        RecommendedBranchCourses
        ON sb.branch=RecommendedBranchCourses.branch and sb.program=RecommendedBranchCourses.program
        INNER JOIN
        PassedCourses as pc
        ON (sb.student=pc.student and pc.course=RecommendedBranchCourses.course)
	)
);

CREATE VIEW studentRecommendedCredits AS (
SELECT student, sum(credits) FROM RecommndedTakenCoursesForStudent GROUP BY student);

CREATE VIEW PathToGraduation AS (
	WITH totalCredits as 
	((
		select Student,
			sum(credits) as totalCredits
			FROM
			PassedCourses
	GROUP BY Student)
	),
	mandatoryleft as
	((
		select student,
			count(course) as mandatoryleft
			from 
			UnreadMandatory
	GROUP BY student)
	),
	mathCredits as
	((
		select Student,
			sum(credits) as mathCredits
			from
			PassedCourses
			INNER JOIN
			ClassifiedCourses
			ON PassedCourses.course = ClassifiedCourses.course
			WHERE ClassifiedCourses.classification = 'math'
	GROUP BY Student)
	),
	researchCredits as
	((
		select Student,
			sum(credits) as researchCredits
			from
			PassedCourses
			INNER JOIN
			ClassifiedCourses
			ON PassedCourses.course = ClassifiedCourses.course
			WHERE ClassifiedCourses.classification = 'research'
	GROUP BY Student)
	),
	seminarCourses as
	((
		select Student,
			count(PassedCourses.course) as seminarCourses
			from
			PassedCourses
			INNER JOIN
			ClassifiedCourses
			ON PassedCourses.course = ClassifiedCourses.course
			WHERE ClassifiedCourses.classification = 'seminar'
	GROUP BY Student)
	)
	select Students.idnr as student, 
		COALESCE(totalcredits,0) as totalcredits,
		COALESCE(mandatoryleft,0) as mandatoryleft,
		COALESCE(mathCredits,0) as mathCredits,
		COALESCE(researchCredits,0) as researchCredits,
		COALESCE(seminarCourses,0) as seminarCourses,
		CASE WHEN 	mandatoryleft is null and
					mathCredits >= 20 and
					researchCredits >= 10 and
					seminarCourses >= 1 and
					src.sum >= 10
				THEN 'TRUE'
				ELSE 'FALSE'
		END as Qualified
		from 
		Students
		LEFT OUTER JOIN
		totalCredits on Students.idnr = totalCredits.Student
		LEFT OUTER JOIN 
		mandatoryleft on Students.idnr = mandatoryleft.student
		LEFT OUTER JOIN 
		mathCredits on Students.idnr = mathCredits.Student
		LEFT OUTER JOIN 
		researchCredits on Students.idnr = researchCredits.Student
		LEFT OUTER JOIN 
		seminarCourses on Students.idnr = seminarCourses.Student
		LEFT OUTER JOIN
		studentRecommendedCredits as src on Students.idnr = src.student
);

CREATE VIEW PrerequisiteCourses AS (
	SELECT * FROM RestrictedCourses
);


