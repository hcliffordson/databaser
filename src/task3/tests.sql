--------------- Registrations------------------

INSERT INTO Registrations VALUES (4444444444, 'CCC444');  -- should register
INSERT INTO Registrations VALUES (4444444444, 'CCC444');  -- already registered

INSERT INTO Registrations VALUES (2222222222, 'CCC555');  -- already passed
INSERT INTO Registrations VALUES (8888888888, 'CCC333');  -- lacks prerequisites

INSERT INTO RegisteredCourses VALUES (8888888888, 'CCC222');  -- course is full, put in waiting list
INSERT INTO Registrations VALUES (1111111111, 'CCC222');

--------------- Unregistrations------------------

DELETE FROM Registrations WHERE (student = 1111111111 AND course = 'CCC555');   -- Student not registered 
DELETE FROM Registrations WHERE (student = 2222222222 AND course = 'CCC444');   -- student removed from unlimited course

DELETE FROM Registrations WHERE (student = 3333333333 AND course = 'CCC222');   -- student removed from waitinglist, queue updated

DELETE FROM Registrations WHERE (student = 6666666666 AND course = 'CCC333');   -- student removed from limited course with waiting list

INSERT INTO RegisteredCourses VALUES (2222222222, 'CCC222');
DELETE FROM Registrations WHERE (student = 8888888888 AND course = 'CCC222');   -- student removed from overfull course

DELETE from Waitinglist where student=1111111111 and course = 'CCC222';
DELETE FROM Registrations WHERE (student = 2222222222 AND course = 'CCC222');   -- student removed from limited course with empty waiting list






