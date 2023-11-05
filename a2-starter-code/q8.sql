-- Never solo by choice.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q8 CASCADE;

CREATE TABLE q8 (
	username varchar(25) NOT NULL,
	group_average real NOT NULL,
	solo_average real DEFAULT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS studentsSubmitAll CASCADE;
DROP VIEW IF EXISTS groupAssignments CASCADE;
DROP VIEW IF EXISTS soloAssignments CASCADE;
DROP VIEW IF EXISTS groupResults CASCADE;
DROP VIEW IF EXISTS soloResults CASCADE;
DROP VIEW IF EXISTS groupSub CASCADE;
DROP VIEW IF EXISTS groupSubmissions CASCADE;
DROP VIEW IF EXISTS neverSoloStudents CASCADE;
DROP VIEW IF EXISTS groupAvg CASCADE;
DROP VIEW IF EXISTS soloAvg CASCADE;
DROP VIEW IF EXISTS solution CASCADE;


-- Define views for your intermediate steps here:

-- Find students who have submitted every assignment
CREATE VIEW studentsSubmitAll AS
	SELECT s.username 
	FROM Submissions s 
	GROUP BY s.username
	HAVING COUNT(DISTINCT s.submission_id) = (SELECT COUNT(DISTINCT assignment_id) FROM Assignment)
;

-- Find group assignments
CREATE VIEW groupAssignments AS
	SELECT assignment_id 
	FROM Assignment 
	Where group_max > 1
;

-- Find solo assignments
CREATE VIEW soloAssignments AS
	SELECT assignment_id
	FROM Assignment
	WHERE group_max = 1
;

-- create results for each specific group and group assignments
CREATE VIEW groupResults AS
	SELECT DISTINCT sa.assignment_id, r.group_id, r.mark
	FROM soloAssignments sa
	JOIN AssignmentGroup ag ON sa.assignment_id= ag.assignment_id
	JOIN Result r ON ag.group_id = r.group_id 
;

-- create results for each specific group and solo assignments
CREATE VIEW soloResults AS
	SELECT DISTINCT ga.assignment_id, r.group_id, r.mark
	FROM groupAssignments ga
	JOIN AssignmentGroup ag ON ga.assignment_id = ag.assignment_id
	JOIN Result r ON ag.group_id = r.group_id 
;

CREATE VIEW groupSub AS 
	SELECT DISTINCT group_id, submission_id, username
	FROM Submissions
;

CREATE VIEW groupSubmissions AS
	SELECT DISTINCT ga.assignment_id, gs.group_id, gs.username
	FROM  groupAssignments ga
	JOIN groupSub gs ON ga.assignment_id = gs.submission_id
;

CREATE VIEW neverSoloStudents AS
	SELECT sa.username 
	FROM studentsSubmitAll sa
	JOIN groupSubmissions gs ON sa.username = gs.username
	GROUP BY sa.username
	HAVING 
		COUNT(DISTINCT gs.assignment_id) = (SELECT COUNT(*) FROM groupAssignments)
;

CREATE VIEW groupAvg AS
	SELECT m.username, AVG(r.mark) AS group_avg
	FROM Membership m
	JOIN groupSubmissions gs ON m.group_id = gs.group_id
	JOIN Result r ON gs.group_id = r.group_id
	GROUP BY m.username
;

CREATE VIEW soloAvg AS
	SELECT m.username, AVG(r.mark) AS solo_avg
	FROM Membership m
	JOIN soloResults sr ON m.group_id = sr.group_id
	JOIN Result r ON sr.group_id = r.group_id
	GROUP BY m.username
;

CREATE VIEW solution AS
	SELECT ns.username, gAv.group_avg, sAv.solo_avg
	FROM neverSoloStudents ns
	LEFT JOIN groupAvg gAv on ns.username = gAv.username
	LEFT JOIN soloAvg sAv on ns.username = sAv.username
;	


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q8(username, group_average, solo_average)
SELECT username, COALESCE(group_avg,0), COALESCE(solo_avg,0)
FROM solution
;

