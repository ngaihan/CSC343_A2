-- Getting soft?

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2 (
	grader_username varchar(25) NOT NULL,
	grader_name varchar(100) NOT NULL,
	average_mark_all_assignments real NOT NULL,
	mark_change_first_last real NOT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS averageGradePerAssignment CASCADE;
DROP VIEW IF EXISTS consistentGradeIncrease CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW gradersWithExperience AS 
    SELECT
        g.username AS grader_username,
        COUNT(DISTINCT ag.assignment_id) AS assignment_count,
        SUM(CASE WHEN r.mark IS NOT NULL THEN 1 ELSE 0 END) AS graded_count
    FROM
        Grader g
    JOIN AssignmentGroup ag ON g.group_id = ag.group_id
    JOIN Assignment a ON ag.assignment_id = a.assignment_id
    LEFT JOIN Result r ON ag.group_id = r.group_id
    GROUP BY
        g.username
    HAVING
        assignment_count = (SELECT COUNT(*) FROM Assignment)
        AND MIN(graded_count) >= 10
;

CREATE VIEW averageGradePerAssignment AS 
    SELECT
        g.username AS grader_username,
        a.assignment_id,
        AVG(r.mark) AS average_grade -- Assuming each group has one student for simplification
    FROM
        GradersWithExperience gwe
    JOIN Grader g ON gwe.grader_username = g.username
    JOIN AssignmentGroup ag ON g.group_id = ag.group_id
    JOIN Assignment a ON ag.assignment_id = a.assignment_id
    JOIN Result r ON ag.group_id = r.group_id
    GROUP BY
        g.username,
        a.assignment_id
;

CREATE VIEW consistentGradeIncrease AS 
    SELECT
        grader_username,
        assignment_id,
        average_grade,
        LAG(average_grade) OVER (PARTITION BY grader_username ORDER BY a.due_date) AS previous_average_grade
    FROM
        AverageGradePerAssignment agpa
    JOIN Assignment a ON agpa.assignment_id = a.assignment_id
;

CREATE VIEW solution as 
SELECT
    mu.username AS grader_username,
    CONCAT(mu.firstname, ' ', mu.surname) AS grader_name,
    AVG(cgi.average_grade) OVER (PARTITION BY cgi.grader_username) AS average_mark_all_assignments,
    FIRST_VALUE(cgi.average_grade) OVER (PARTITION BY cgi.grader_username ORDER BY a.due_date ASC) AS first_assignment_grade,
    LAST_VALUE(cgi.average_grade) OVER (PARTITION BY cgi.grader_username ORDER BY a.due_date ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_assignment_grade,
    (last_assignment_grade - first_assignment_grade) AS mark_change_first_last
FROM
    ConsistentGradeIncrease cgi
JOIN MarkusUser mu ON cgi.grader_username = mu.username
WHERE
    cgi.average_grade > cgi.previous_average_grade OR cgi.previous_average_grade IS NULL
GROUP BY
    cgi.grader_username,
    grader_name
HAVING
    COUNT(*) = (SELECT COUNT(*) FROM Assignment) -- Ensure that grader graded all assignments
;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2(grader_username, grader_name, average_mark_all_assignments, mark_change_first_last)
SELECT grader_username, COALESCE(grader_name,0), COALESCE(average_mark_all_assignments,0), COALESCE(mark_change_first_last,0)
FROM solution
;
