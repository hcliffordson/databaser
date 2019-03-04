CREATE VIEW CourseQueuePosition AS (
	SELECT * FROM WaitingList
);


CREATE OR REPLACE FUNCTION hasPrerequisites(IN newStudent NUMERIC(10), IN newCourse CHAR(6))
RETURNS BOOLEAN AS 
    $$
    BEGIN
        RETURN  ((SELECT required_course FROM RestrictedCourses WHERE newCourse = RestrictedCourses.course)
                EXCEPT
                (SELECT required_course FROM RestrictedCourses, PassedCourses WHERE
                newCourse = RestrictedCourses.course AND 
                newStudent = PassedCourses.student AND
                RestrictedCourses.required_course = PassedCourses.course)) IS NOT NULL;               
        END
    $$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION isFullCourse(IN newCourse CHAR(6))
    RETURNS BOOLEAN AS
    $$
    BEGIN
        IF  isLimitedCourse(newCourse) 
            AND
            (SELECT seats FROM LimitedCourses WHERE LimitedCourses.code = newCourse) < (SELECT COUNT(*) FROM Registrations WHERE newCourse=Registrations.course) 
            THEN RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END
    $$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION isLimitedCourse(IN newCourse CHAR(6))
    RETURNS BOOLEAN AS
    $$
    BEGIN
        RETURN (SELECT code FROM LimitedCourses WHERE newCourse = LimitedCourses.code) IS NOT NULL;
    END
    $$ LANGUAGE plpgsql;


CREATE FUNCTION nextNumber(CHAR(6))
    RETURNS BIGINT AS
    $$ SELECT COUNT(*)+1 FROM WaitingList WHERE course =$1
    $$ LANGUAGE SQL;
    

CREATE OR REPLACE FUNCTION registration()
    RETURNS trigger AS 
    $func$
    BEGIN
        IF (SELECT student FROM Registrations WHERE (NEW.student = Registrations.student AND NEW.course = Registrations.course)) IS NOT NULL THEN 
            RAISE EXCEPTION 'student % is already registered to course %', NEW.student, NEW.course;
        
        ELSIF (SELECT student FROM PassedCourses WHERE NEW.student = PassedCourses.student AND NEW.course = PassedCourses.course) IS NOT NULL THEN
            RAISE EXCEPTION 'Student % already passed this course', NEW.student;

        ELSIF hasPrerequisites(NEW.student, NEW.course)
            THEN RAISE EXCEPTION 'Student % lacks prerequisites for this course', NEW.student;

        ELSIF isFullCourse(NEW.course)
            THEN INSERT INTO WaitingList VALUES (NEW.student, NEW.course, nextNumber(NEW.course));
                 RAISE NOTICE 'Course is full, student % put as % in queue', NEW.student, nextNumber(NEW.course)-1;
        
        ELSE
            INSERT INTO RegisteredCourses VALUES (NEW.student, NEW.course);
            RAISE NOTICE 'Student % registered to course %', NEW.student,NEW.course;
            
        END IF;
        RETURN NEW;
    END
    $func$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION unregistration()
    RETURNS trigger AS
    $func$
    DECLARE firstInQueue Students.idnr%TYPE;
    DECLARE oldPos WaitingList.position%TYPE;
    BEGIN
        -- Case when student is not registered to course
        IF (SELECT student FROM Registrations WHERE Registrations.student=OLD.student AND Registrations.Course=OLD.course) IS NULL THEN
            RAISE EXCEPTION 'Student is not registered to this course';
        END IF;

        -- Case when course in unlimited
        IF NOT isLimitedCourse(OLD.course)
            THEN DELETE FROM RegisteredCourses WHERE OLD.student = RegisteredCourses.student AND RegisteredCourses.course=OLD.course;
                RAISE NOTICE 'Student % removed from unlimited course %', OLD.student, OLD.course;

        -- Case when course is limited and student is in its waiting list
        ELSIF OLD.status='waiting' AND isLimitedCourse(OLD.course)
            THEN
            oldPos := (SELECT position FROM WaitingList WHERE student=OLD.student and course=old.course);
            DELETE FROM WaitingList WHERE OLD.student = WaitingList.student AND OLD.course = WaitingList.course;
            UPDATE WaitingList SET position = position-1 WHERE course=OLD.course AND position > oldPos;
            RAISE NOTICE 'Student % removed from waiting list for limited course %. waiting list updated', OLD.student, OLD.course;

        -- Case when student unregistered from limited course and is registered
        ELSIF OLD.status='registered' AND isLimitedCourse(OLD.course)
        THEN DELETE FROM RegisteredCourses WHERE RegisteredCourses.student=OLD.student AND RegisteredCourses.course=OLD.course;
            IF (SELECT COUNT(course) FROM WaitingList WHERE WaitingList.course=OLD.course) = 0 -- if its waiting list is empty
                THEN RAISE NOTICE 'Student % removed from limited course % with empty waiting list', OLD.student, OLD.course;
                RETURN OLD;

            -- IF course is overfull
            ELSIF ((SELECT seats FROM LimitedCourses WHERE LimitedCourses.code=OLD.course) < (SELECT COUNT(*) FROM RegisteredCourses WHERE RegisteredCourses.course=OLD.course)+1)
                THEN
                RAISE NOTICE 'Student % removed from limited, overfull course %', OLD.student, OLD.course;
                RETURN OLD;
            
            -- if is not overfull and waiting list not empty
            ELSE 
                UPDATE WaitingList SET position = position-1 WHERE WaitingList.course = OLD.course;
                SELECT student FROM WaitingList WHERE position=0 INTO firstInQueue;                                    
                INSERT INTO RegisteredCourses VALUES (firstInQueue, OLD.course);
                DELETE FROM WaitingList WHERE position=0;
                RAISE NOTICE 'Student % removed from limited course %. queue updated', OLD.student, OLD.course;
                RETURN NEW;
            END IF;
        END IF;
        RETURN OLD;
    END
    $func$ LANGUAGE plpgsql;


CREATE TRIGGER CourseRegistration
    INSTEAD OF INSERT OR UPDATE ON Registrations 
    FOR EACH ROW EXECUTE PROCEDURE registration();


CREATE TRIGGER CourseUnregistration
    INSTEAD OF DELETE ON Registrations
    FOR EACH ROW EXECUTE PROCEDURE unregistration();

