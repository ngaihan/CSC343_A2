-- High coverage.

SET search_path TO markus;
DROP TABLE IF EXISTS q7 CASCADE;

CREATE TABLE q7 (
	grader varchar(25) NOT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS atLeastOneGroup CASCADE;
DROP VIEW IF EXISTS graderStudent CASCADE;
DROP VIEW IF EXISTS allStudents CASCADE;

-- Define views for your intermediate steps here:
-- Grader that has been assigned at least one group per assignment
CREATE VIEW atLeastOneGroup AS
SELECT username
FROM grader JOIN assignmentgroup AS T1 USING (group_id)
WHERE EXISTS (
	SELECT *
	FROM assignment AS T2
	WHERE T1.assignment_id = T2.assignment_id
)
GROUP BY username
;

-- Relationship between grader and their gradee
CREATE VIEW graderStudent AS
SELECT grader.username AS grader, membership.username AS student
FROM grader JOIN membership USING (group_id)
;

-- Only graders that have occured as many times as there are students
CREATE VIEW allStudents AS
SELECT grader
FROM graderStudent
GROUP BY grader
HAVING count(DISTINCT student) >= (
	SELECT count(*) FROM markususer
	WHERE type = 'student'
)
;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q7
SELECT grader FROM allStudents;
