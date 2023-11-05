-- Uneven workloads.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q5 CASCADE;

CREATE TABLE q5 (
	assignment_id integer NOT NULL,
	username varchar(25) NOT NULL,
	num_assigned integer NOT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS numGradee CASCADE;
DROP VIEW IF EXISTS gradeeDiff CASCADE;
DROP VIEW IF EXISTS bigDiff CASCADE;
DROP VIEW IF EXISTS solution CASCADE;


-- Define views for your intermediate steps here:
-- Count number of groups that a grader is assigned grouped by the assignment
CREATE VIEW numGradee AS
SELECT assignment_id, grader.username, count(*) AS num_assigned
FROM Grader JOIN assignmentgroup USING (group_id)
GROUP BY assignment_id, grader.username
;

-- Difference in gradees between graders
CREATE VIEW gradeeDiff AS
SELECT T1.assignment_id, T1.username AS username1, T2.username AS username2, T1.num_assigned-T2.num_assigned AS num_diff
FROM numGradee AS T1 JOIN numGradee AS T2 USING (assignment_id)
WHERE T1.username != T2.username
;

-- Isolated only the pairs that had a positive diff of 1 or more
CREATE VIEW bigDiff AS 
SELECT assignment_id, username1 AS username
FROM gradeeDiff
WHERE num_diff > 10 OR num_diff < -10
GROUP BY assignment_id, username
;

CREATE VIEW solution AS
SELECT bigDiff.assignment_id, bigDiff.username, num_assigned
FROM bigDiff JOIN numGradee ON bigDiff.assignment_id=numGradee.assignment_id AND bigDiff.username=numGradee.username
;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q5
SELECT * FROM solution
;
