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
DROP VIEW IF EXISTS intermediate_step CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW intermediate_step AS ... ;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q9
