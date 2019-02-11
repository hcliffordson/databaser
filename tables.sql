
CREATE TABLE Branches 
(
	name 		char(2) 		NOT NULL,
	program 	char(5) 		NOT NULL,
	CONSTRAINT 	branches_pk 	PRIMARY KEY (name, program)
);


CREATE TABLE Students
(
	idnr		numeric(10)		PRIMARY KEY,
	name 		char(2)			NOT NULL,
	login		char(3)			NOT NULL,
	program 	char(5) 		NOT NULL
);



CREATE TABLE Courses
(
	code 		char(6)			PRIMARY KEY,
	name		char(2)			NOT NULL,
	credits		numeric(2)		NOT NULL,
	department	char(4)			NOT NULL
);




CREATE TABLE LimitedCourses 
(
	code 		char(6)			PRIMARY KEY,
	seats 		numeric(1)		NOT NULL,
	FOREIGN KEY (code)			REFERENCES		Courses(code),
	CHECK		(seats >= 0)
);



CREATE TABLE Classifications
(
	name		TEXT			PRIMARY KEY
	
);


CREATE TABLE StudentBranches
(
	student 	numeric(10)			REFERENCES 		Students(idnr),
	branch 		char(2)				NOT NULL,
	program		char(5)				NOT NULL,
	FOREIGN KEY	(branch, program)	REFERENCES		Branches(name, program),
	CONSTRAINT	student_branches_pk	PRIMARY KEY (student)
);



CREATE TABLE Classified
(
	course 			char(6)				REFERENCES		Courses(code),
	classification	TEXT				REFERENCES		Classifications(name),
	CONSTRAINT		classified_pk		PRIMARY KEY (course, classification)
);

CREATE TABLE MandatoryProgram
(
	course 			char(6)				REFERENCES		Courses(code),
	program 	char(5)					NOT NULL,
	CONSTRAINT 	mandatory_program_pk	PRIMARY KEY (course, program)

);


CREATE TABLE MandatoryBranch
(
	course 		char(6)				REFERENCES		Courses(code),
	branch 		char(2)				NOT NULL,
	program 	char(5)				NOT NULL,
	FOREIGN KEY (branch, program)	REFERENCES		Branches(name, program),
	CONSTRAINT	mandatory_branch_pk	PRIMARY KEY (course, branch, program)
);


CREATE TABLE RecommendedBranch
(
	course 		char(6)				REFERENCES		Courses(code),
	branch 		char(2)				NOT NULL,
	program 	char(5)				NOT NULL,
	FOREIGN KEY (branch, program)	REFERENCES		Branches(name, program),
	CONSTRAINT	recommended_branch_pk	PRIMARY KEY (course, branch, program)
);


CREATE TABLE Registered
(
	student 	numeric(10)			REFERENCES		Students(idnr),
	course 		char(6)				REFERENCES		Courses(code),
	CONSTRAINT	registered_pk		PRIMARY KEY (student, course)
);


CREATE TABLE Taken
(
	student 	numeric(10)		REFERENCES 		Students(idnr),
	course 		char(6)			REFERENCES		Courses(code),
	grade		char(1)			NOT NULL,
	CHECK		(grade IN ('5','4','3','U')),
	CONSTRAINT	taken_pk		PRIMARY KEY (student, course)

);

CREATE TABLE WaitingList
(
	student 	numeric(10)		REFERENCES 		Students(idnr),
	course 		char(6)			REFERENCES		Courses(code),
	position	SERIAL			NOT NULL,
	CONSTRAINT	waiting_list_pk	PRIMARY KEY (student, course)
);











