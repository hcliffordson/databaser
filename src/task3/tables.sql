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