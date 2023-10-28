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
DROP VIEW IF EXISTS intermediate_step CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW intermediate_step AS ... ;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q10
