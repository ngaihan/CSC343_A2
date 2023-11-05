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

-- Grader that marked somemthing from every student
CREATE VIEW notAllStudent AS
SELECT grader.username
FROM membership JOIN grader USING (group_id)
WHERE EXISTS (
	SELECT *
	FROM MarkusUser
	WHERE usertype = 'student' AND membership.username=markususer.username
)
;

CREATE VIEW everyStudent AS 


-- Your query that answers the question goes below the "insert into" line:
-- INSERT INTO q7
