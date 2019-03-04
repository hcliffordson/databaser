DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
\i tables.sql
\i views.sql
\i inserts.sql

SELECT * FROM BasicInformation;

SELECT * FROM FinishedCourses;

SELECT * FROM PassedCourses;

SELECT * FROM Registrations;

SELECT * FROM UnreadMandatory;

SELECT * FROM PathToGraduation;