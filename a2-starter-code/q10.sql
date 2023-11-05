-- A1 report.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q10 CASCADE;

CREATE TABLE q10 (
	group_id bigint NOT NULL,
	mark real DEFAULT NULL,
	compared_to_average real DEFAULT NULL,
	status varchar(5) DEFAULT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS totalA1Weight CASCADE;
DROP VIEW IF EXISTS averageA1 CASCADE;
DROP VIEW IF EXISTS a1Marks CASCADE;
DROP VIEW IF EXISTS gradeDiff CASCADE;




-- Define views for your intermediate steps here:

-- Define views for your intermediate steps here:

-- Total weight of each assignment for calculation of the total percentage mark
CREATE VIEW totalA1Weight AS
	SELECT assignment_id, sum(weight) AS total_weight
	FROM rubricitem rb
	JOIN Assignment a ON rb.assignment_id = a.assignment_id
	GROUP BY assignment_id
	WHERE a.description = "A1"
;

CREATE VIEW averageA1 AS
	SELECT AVG((r.mark/tw.total_weight)*100) AS a1_avg
	FROM Result r
	JOIN totalA1Weight tw ON r.assignment_id = tw.assignment_id
	GROUP BY r.assignment_id
;
-- The calculated A1 percentage mark for each group 
CREATE VIEW a1Marks AS
	SELECT ag.assignment_id, r.group_id, (mark/total_weight)*100 AS percent_mark
	FROM totalA1Weight tw
	JOIN Assignment a ON tw.assignment_id = a.assignment_id
	JOIN AssignmentGroup ag ON ag.assignment_id
	JOIN Result r ON ag.group_id = r.group_id
	GROUP BY r.group_id
;

CREATE VIEW gradeDiff AS
	SELECT m.group_id, m.percent_mark, (m.mark - avg.a1_avg) as diff
	FROM a1Marks m, averageA1a avg
;

CREATE VIEW solution AS
	SELECT group_id, mark, diff,
		CASE
			WHEN diff > 0 THEN 'above'
			WHEN diff = 0 THEN 'at'
			WHEN diff < 0 THEN 'below'
			ELSE 'no grade'
		END AS status
	FROM gradeDiff
;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q10(group_id, mark, compared_to_average, status) 
SELECT group_id, COALESCE(mark,0), COALESCE(diff,0), COALESCE(status,0)
FROM solution
