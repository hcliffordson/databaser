CREATE VIEW BasicInformation AS
(
	SELECT DISTINCT s.idnr, s.name, s.login, s.program, sb.branch
	FROM Students AS s LEFT OUTER JOIN StudentBranches as sb ON (s.idnr = sb.student)
);


CREATE VIEW FinishedCourses AS
(
	SELECT t.student as Students, t.course as course, t.grade as grade, c.credits as credits
	FROM Taken AS t INNER JOIN Courses AS c ON (t.course=c.code) 
);


CREATE VIEW PassedCourses AS
(
	SELECT t.student as Student, t.course as course, c.credits as credits
	FROM Taken AS t INNER JOIN Courses AS c ON (t.course=c.code)
	WHERE (t.grade <> 'U')
);



CREATE VIEW Registrations AS
(
	SELECT student, course, 'registered' AS status
	FROM Registered
	UNION
	SELECT student, course, 'wating' AS status
	FROM WaitingList
	ORDER BY status	
);


CREATE VIEW UnReadMandatory AS (
(SELECT idnr, course
	FROM MandatoryProgram
	INNER JOIN 
	Students
	ON Students.program = MandatoryProgram.program
UNION
SELECT idnr, course
	FROM MandatoryBranch
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
(SELECT sb.student, sb.branch, RecommendedBranch.course,pc.credits
	FROM StudentBranches as sb
	INNER JOIN
	RecommendedBranch
	ON sb.branch=RecommendedBranch.branch
	INNER JOIN
	PassedCourses as pc
	ON (sb.student=pc.student and pc.course=RecommendedBranch.course)
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
		select idnr,
			count(course) as mandatoryleft
			from 
			UnreadMandatory
	GROUP BY idnr)
	),
	mathCredits as
	((
		select Student,
			sum(credits) as mathCredits
			from
			PassedCourses
			INNER JOIN
			Classified
			ON PassedCourses.course = Classified.course
			WHERE Classified.classification = 'math'
	GROUP BY Student)
	),
	researchCredits as
	((
		select Student,
			sum(credits) as researchCredits
			from
			PassedCourses
			INNER JOIN
			Classified
			ON PassedCourses.course = Classified.course
			WHERE Classified.classification = 'research'
	GROUP BY Student)
	),
	seminarCourses as
	((
		select Student,
			count(PassedCourses.course) as seminarCourses
			from
			PassedCourses
			INNER JOIN
			Classified
			ON PassedCourses.course = Classified.course
			WHERE Classified.classification = 'seminar'
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
		mandatoryleft on Students.idnr = mandatoryleft.idnr
		LEFT OUTER JOIN 
		mathCredits on Students.idnr = mathCredits.Student
		LEFT OUTER JOIN 
		researchCredits on Students.idnr = researchCredits.Student
		LEFT OUTER JOIN 
		seminarCourses on Students.idnr = seminarCourses.Student
		LEFT OUTER JOIN
		studentRecommendedCredits as src on Students.idnr = src.student

);


