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
DROP VIEW IF EXISTS intermediate_step CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW intermediate_step AS ... ;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q8
