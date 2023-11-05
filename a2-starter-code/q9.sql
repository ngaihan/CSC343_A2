-- Inseparable.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q9 CASCADE;

CREATE TABLE q9 (
	student1 varchar(25) NOT NULL,
	student2 varchar(25) NOT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS groupAssignments CASCADE;
DROP VIEW IF EXISTS groupMembers CASCADE;
DROP VIEW IF EXISTS numTimesTogether CASCADE;
DROP VIEW IF EXISTS alwaysTogether CASCADE;


-- Define views for your intermediate steps here:
-- Assignments that allow groups
CREATE VIEW groupAssignments AS
SELECT assignment_id
FROM assignment
WHERE group_max > 1
;

-- Find pairs that have not been together for every assignment
CREATE VIEW groupMembers AS
SELECT assignment_id, group_id, username
FROM membership JOIN assignmentgroup USING (group_id)
	JOIN groupAssignments USING (assignment_id)
;

CREATE VIEW numTimesTogether AS
SELECT T1.username AS username1, T2.username AS username2, count(*) AS num_together
FROM groupMembers AS T1 JOIN groupMembers AS T2 ON T1.assignment_id=T2.assignment_id AND T1.group_id=T2.group_id AND T1.username!=T2.username
GROUP BY username1, username2
;

CREATE VIEW alwaysTogether AS 
SELECT username1 AS student1, username2 AS student2
FROM numTimesTogether 
WHERE num_together = (
	SELECT count(*) FROM groupAssignments 
) AND username1 < username2
;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q9
SELECT * FROM alwaysTogether
;
