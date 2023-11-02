-- Distributions.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1 (
	assignment_id integer NOT NULL,
	average_mark_percent real DEFAULT NULL,
	num_80_100 integer NOT NULL,
	num_60_79 integer NOT NULL,
	num_50_59 integer NOT NULL,
	num_0_49 integer NOT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS 80to100 CASCADE;
DROP VIEW IF EXISTS 60to79 CASCADE;
DROP VIEW IF EXISTS 50to59 CASCADE;
DROP VIEW IF EXISTS 0to49 CASCADE;
DROP VIEW IF EXISTS averageMark CASCADE;

-- Define views for your intermediate steps here:
-- Find the grade by using rubric and grade
CREATE VIEW rubricGrades AS
SELECT assignment_id, group_id, grade, out_of, weight
FROM assignmentgroup JOIN grade USING (group_id)
					 JOIN rubricitem USING (rubric_id)
;

-- Update the table so that it has the individual weight of each of the assignment items
UPDATE rubricGrades
SET grade = grade / out_of * weight * 100
;

-- Aggregates each of the weighted rubric items and aggregates them by assignment, giving the total grade
CREATE VIEW groupGrade AS
SELECT assignment_id, group_id, sum(grade)
FROM rubricGrades
GROUP BY assignment_id, group_id
;

-- Find the count of each different grade bracket for each assignment
CREATE VIEW 80to100 AS 
SELECT assignment_id, count(*) AS num_80_100
FROM groupGrade
WHERE grade >= 80
GROUP BY assignment_id
;

CREATE VIEW 60to79 AS 
SELECT assignment_id, count(*) AS num_60_79
FROM groupGrade
WHERE grade >= 60 AND grade < 80
GROUP BY assignment_id
;

CREATE VIEW 50to59 AS 
SELECT assignment_id, count(*) AS num_50_59
FROM groupGrade
WHERE grade >= 50 AND grade < 60
GROUP BY assignment_id
;

CREATE VIEW 0to49 AS num_0_49
SELECT assignment_id, count(*)
FROM groupGrade
WHERE grade < 50
GROUP BY assignment_id
;

CREATE VIEW averageMark AS average_mark_percent
SELECT assignment_id, avg(grade) AS 
FROM groupGrade
GROUP BY assignment_id
;

CREATE VIEW solution AS
SELECT assignment_id, average_mark_percent, num_80_100, num_60_79, num_50_59, num_0_49
FROM averageMark JOIN 0to49 USING (assignment_id)
			     JOIN 50to59 USING (assignment_id)
				 JOIN 60to79 USING (assignment_id)
				 JOIN 80to100 USING (assignment_id)
;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q1
solution;