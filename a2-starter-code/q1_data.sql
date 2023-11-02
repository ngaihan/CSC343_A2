SET SEARCH_PATH TO markus;

INSERT INTO 
	Assignment(assignment_id, description, due_date, group_min, group_max)
VALUES
	(1, 'A1', '2023-10-10 23:59', 1, 1),
	(2, 'A2', '2023-11-13 23:59', 1, 3),
	(3, 'A3', '2023-12-05 23:59', 1, 2);

INSERT INTO 
	AssignmentGroup(assignment_id, repo) 
VALUES
	-- A1
	(1, 'https://markus.teach.cs.toronto.edu/2023-01/courses/22/group_1'), -- group 1
	(1, 'https://markus.teach.cs.toronto.edu/2023-01/courses/22/group_2'), -- group 2
	(1, 'https://markus.teach.cs.toronto.edu/2023-01/courses/22/group_3'), -- group 3
	(1, 'https://markus.teach.cs.toronto.edu/2023-01/courses/22/group_4'), -- group 4
	(1, 'https://markus.teach.cs.toronto.edu/2023-01/courses/22/group_5'), -- group 5
	-- A2
	(2, 'https://markus.teach.cs.toronto.edu/2023-01/courses/22/group_6'), -- group 6
	(2, 'https://markus.teach.cs.toronto.edu/2023-01/courses/22/group_7'), -- group 7
	(2, 'https://markus.teach.cs.toronto.edu/2023-01/courses/22/group_8'); -- group 8



INSERT INTO 
	Grade(group_id, rubric_id, grade)
VALUES
	-- A1
	-- Group 1
	(1, 1, 8),
	(1, 2, 9),
	(1, 3, 12),
	-- Group 2
	(2, 1, 10),
	(2, 2, 10),
	(2, 3, 12),
	-- Group 3
	(3, 1, 8),
	(3, 2, 7),
	(3, 3, 12),
	-- Group 4
	(4, 1, 8),
	(4, 2, 9);


INSERT INTO
	Result(group_id, mark, released)
VALUES
	(1, 9.2, true),
	(2, 10.6, false),
	(3, 8.4, true);
	
INSERT INTO
	RubricItem(rubric_id, assignment_id, name, out_of, weight)
VALUES
	-- A1
	(1, 1, 'Method 1', 10, 5),
	(2, 1, 'Method 2', 10, 4),
	(3, 1, 'Style', 15, 2),
	-- A2
	(4, 2, 'Query 1', 12, 0.25),
	(5, 2, 'Query 2', 12, 0.25),
	(6, 2, 'Methods', 12, 0.5);


