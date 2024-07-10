-- Milosz Lewandowski C20355901
-- Altering Fact table to add cost for Queries in queries.sql

USE MusicCompDB;

-- Make sure there is no tables with the name you want to make
DROP TABLE IF EXISTS voteFacts;
DROP TABLE IF EXISTS dimVoteDate;
DROP TABLE IF EXISTS dimViewer;
DROP TABLE IF EXISTS dimParticipant;
DROP TABLE IF EXISTS dimEdition;
DROP TABLE IF EXISTS dimViewerCategory;

-- Create Dimension Tables and Fact Table for Star Schema
-- Making a surrogate key as votedate is not a viable pk since it has duplicates
-- and having votemode and amount of votes in that dimension
CREATE TABLE dimVoteDate(
vote_date_sk INT NOT NULL,
vote_date DATE NOT NULL,
vote_mode VARCHAR(10) DEFAULT NULL CHECK (vote_mode in ('Phone','Facebook','Instagram','TV')),
vote INT(11) DEFAULT NULL CHECK (vote > 0 and vote < 6),
PRIMARY KEY (vote_date_sk)
);

-- The dimViewer table contains age_group_desc which
-- was the agegroup table, this was removed as it was just
-- a primary key with one column making extra joins
-- and would make the schema snowflake schema if you wanted to keep it seperate
-- The same was done with the county table as it was just 1 column of information
CREATE TABLE dimViewer(
viewer_sk INT NOT NULL,
viewer_id INT(11) NOT NULL,
age_group_desc VARCHAR(50) DEFAULT NULL,
county_name VARCHAR(50) DEFAULT NULL,
PRIMARY KEY (viewer_sk)
);

-- Participant holds county_name now after denormalisation
-- Less joins means faster performance & schema format is matched
CREATE TABLE dimParticipant(
participant_sk INT NOT NULL,
part_name VARCHAR(255) NOT NULL,
county_name VARCHAR(50) DEFAULT NULL,
PRIMARY KEY (participant_sk)
);

CREATE TABLE dimEdition(
edition_sk INT NOT NULL,
ed_year YEAR(4) NOT NULL,
ed_presenter VARCHAR(255) NOT NULL,
PRIMARY KEY(edition_sk)
);


CREATE TABLE dimViewerCategory(
category_sk INT NOT NULL,
cat_id INT(11) NOT NULL,
cat_name VARCHAR(10) DEFAULT NULL CHECK (cat_name in ('Jury', 'Audience')),
PRIMARY KEY(category_sk)
);

-- Fact Table has only forekign keys that reference dimension models
CREATE TABLE voteFacts(
vote_date_sk INT NOT NULL,
viewer_sk INT NOT NULL,
participant_sk INT  NOT NULL,
edition_sk INT NOT NULL,
category_sk INT NOT NULL,
CONSTRAINT vote_ibfk_01 FOREIGN KEY (vote_date_sk) REFERENCES dimVoteDate(vote_date_sk),
CONSTRAINT vote_ibfk_02 FOREIGN KEY (viewer_sk) REFERENCES dimViewer(viewer_sk),
CONSTRAINT vote_ibfk_03 FOREIGN KEY (participant_sk) REFERENCES dimParticipant(participant_sk),
CONSTRAINT vote_ibfk_04 FOREIGN KEY (edition_sk) REFERENCES dimEdition(edition_sk),
CONSTRAINT vote_ibfk_05 FOREIGN KEY (category_sk) REFERENCES dimViewerCategory(category_sk)
);
