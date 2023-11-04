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
DROP VIEW IF EXISTS grade80to100 CASCADE;
DROP VIEW IF EXISTS grade60to79 CASCADE;
DROP VIEW IF EXISTS grade50to59 CASCADE;
DROP VIEW IF EXISTS grade0to49 CASCADE;
DROP VIEW IF EXISTS averageMark CASCADE;
DROP VIEW IF EXISTS percentMark CASCADE;
DROP VIEW IF EXISTS rubricWeight CASCADE;

-- Define views for your intermediate steps here:
-- Total weight of each assignment for calculation of the total percentage mark
CREATE VIEW rubricWeight AS
SELECT assignment_id, sum(weight) AS total_weight
FROM rubricitem
GROUP BY assignment_id
;

-- The calculated percentage mark for each group and that shows up in the results table
CREATE VIEW percentMark AS
SELECT assignment_id, group_id, (mark/total_weight)*100 AS percent_mark
FROM rubricWeight JOIN assignmentgroup USING (assignment_id)
				  JOIN result USING (group_id)
;

-- Find the count of each different grade bracket for each assignment
CREATE VIEW grade80to100 AS 
SELECT assignment_id, count(*) AS num_80_100
FROM percentMark
WHERE percent_mark >= 80
GROUP BY assignment_id
;

CREATE VIEW grade60to79 AS 
SELECT assignment_id, count(*) AS num_60_79
FROM percentMark
WHERE percent_mark >= 60 AND percent_mark < 80
GROUP BY assignment_id
;

CREATE VIEW grade50to59 AS 
SELECT assignment_id, count(*) AS num_50_59
FROM percentMark
WHERE percent_mark >= 50 AND percent_mark < 60
GROUP BY assignment_id
;

CREATE VIEW grade0to49 AS
SELECT assignment_id, count(*) AS num_0_49
FROM percentMark
WHERE percent_mark < 50
GROUP BY assignment_id
;

CREATE VIEW averageMark AS 
SELECT assignment_id, avg(percent_mark) AS average_mark_percent
FROM percentMark
GROUP BY assignment_id
;

CREATE VIEW solution AS
SELECT assignment_id, average_mark_percent, num_80_100, num_60_79, num_50_59, num_0_49
FROM averageMark LEFT JOIN grade0to49 USING (assignment_id)
			     LEFT JOIN grade50to59 USING (assignment_id)
				 LEFT JOIN grade60to79 USING (assignment_id)
				 LEFT JOIN grade80to100 USING (assignment_id)
;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q1(assignment_id, average_mark_percent, num_80_100, num_60_79, num_50_59, num_0_49)
SELECT assignment_id, COALESCE(average_mark_percent,0), COALESCE(num_80_100,0), COALESCE(num_60_79,0), COALESCE(num_50_59,0), COALESCE(num_0_49,0)
FROM solution
;