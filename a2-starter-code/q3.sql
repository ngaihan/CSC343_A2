-- Solo superior.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3 (
	assignment_id integer NOT NULL,
	description varchar(100) NOT NULL,
	num_solo integer NOT NULL,
	average_solo real NOT NULL,
	num_collaborators integer NOT NULL,
	average_collaborators real NOT NULL,
	average_students_per_group real NOT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS rubricWeight CASCADE;
DROP VIEW IF EXISTS percentMark CASCADE;
DROP VIEW IF EXISTS soloGroup CASCADE;
DROP VIEW IF EXISTS collabGroup CASCADE;
DROP VIEW IF EXISTS avgSoloMark CASCADE;
DROP VIEW IF EXISTS avgCollabMark CASCADE;
DROP VIEW IF EXISTS numSolo CASCADE;
DROP VIEW IF EXISTS numCollab CASCADE;
DROP VIEW IF EXISTS avgStudents CASCADE;

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

-- Solo groups and collab groups
CREATE VIEW soloGroup AS 
SELECT group_id
FROM membership
GROUP BY group_id
HAVING count(username) = 1
;

CREATE VIEW collabGroup AS 
(SELECT group_id FROM membership)
EXCEPT
(SELECT * FROM soloGroup)
;

-- Average mark of solo groups
CREATE VIEW avgSoloMark AS
SELECT assignment_id, avg(percent_mark) AS average_solo
FROM percentMark JOIN soloGroup USING (group_id)
GROUP BY assignment_id
;

-- Average mark of non-solo groups
CREATE VIEW avgCollabMark AS
SELECT assignment_id, avg(percent_mark) AS average_collaborators
FROM percentMark JOIN collabGroup USING (group_id)
GROUP BY assignment_id
;

-- Count of solo and non-solo groups
CREATE VIEW numSolo AS
SELECT assignment_id, count(*) AS num_solo
FROM soloGroup JOIN assignmentgroup USING (group_id)
GROUP BY assignment_id
;

CREATE VIEW numCollab AS
SELECT assignment_id, count(*) AS num_collaborators
FROM collabGroup JOIN assignmentgroup USING (group_id)
GROUP BY assignment_id
;

CREATE VIEW avgStudents AS
SELECT assignment_id, avg(num_students) AS average_students_per_group
FROM (SELECT assignment_id, group_id, count(*) AS num_students
	  FROM membership JOIN assignmentgroup USING (group_id)
	  GROUP BY assignment_id, group_id) AS numStudents
GROUP BY assignment_id
;

CREATE VIEW final AS
SELECT assignment.assignment_id, description, num_solo, average_solo, num_collaborators, average_collaborators, average_students_per_group
FROM assignment JOIN numSolo USING (assignment_id)
				JOIN numCollab USING (assignment_id)
				JOIN avgSoloMark USING (assignment_id)
				JOIN avgCollabMark USING (assignment_id)
				JOIN avgStudents USING (assignment_id)
;

CREATE VIEW solution AS
SELECT assignment_id, description, num_solo, average_solo, num_collaborators, average_collaborators, average_students_per_group
FROM final
WHERE num_solo IS NOT NULL AND num_collaborators IS NOT NULL
;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q3 (assignment_id, description, num_solo, average_solo, num_collaborators, average_collaborators, average_students_per_group)
SELECT assignment_id, description, num_solo, average_solo, num_collaborators, average_collaborators, average_students_per_group FROM solution 
;
