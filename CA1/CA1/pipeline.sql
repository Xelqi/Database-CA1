-- Milosz Lewandowski C20355901

USE MusicCompDB;

-- Create Staging Tables
-- Make Staging table for Viewers
DROP TABLE IF EXISTS stage_viewer; 
CREATE TABLE stage_viewer AS SELECT * FROM VIEWERS;

-- Add columns we will use later to take data from
ALTER TABLE stage_viewer 
ADD COUNTYNAME VARCHAR(50),
ADD AGE_GROUP_DESC VARCHAR(50);

-- Update COUNTYNAME using ID
UPDATE stage_viewer
JOIN COUNTY ON stage_viewer.COUNTYID = COUNTY.COUNTYID
SET stage_viewer.COUNTYNAME = COUNTY.COUNTYNAME;

-- Update AGE_GROUP_DESC using ID
UPDATE stage_viewer
JOIN AGEGROUP ON stage_viewer.AGE_GROUP = AGEGROUP.AGE_GROUPID
SET stage_viewer.AGE_GROUP_DESC = AGEGROUP.AGE_GROUP_DESC;

-- Add SK
ALTER TABLE stage_viewer ADD viewer_sk INTEGER;

-- Create Sequence to generate surrogate keys
DROP SEQUENCE IF EXISTS viewer_seq;
CREATE SEQUENCE viewer_seq
START WITH 1
INCREMENT BY 1;

UPDATE stage_viewer SET viewer_sk = (NEXT VALUE FOR viewer_seq);

-- Check all data there
SELECT * FROM stage_viewer;


-- Participant Staging Table
DROP TABLE IF EXISTS stage_participant;

CREATE TABLE stage_participant AS SELECT * FROM PARTICIPANTS;

-- Add county_name Column we need for our dimension table
ALTER TABLE stage_participant
ADD COUNTYNAME VARCHAR(50);

-- Update COUNTYNAME using ID
UPDATE stage_participant
JOIN COUNTY ON stage_participant.COUNTYID = COUNTY.COUNTYID
SET stage_participant.COUNTYNAME = COUNTY.COUNTYNAME;

-- Add SK
ALTER TABLE stage_participant ADD participant_sk INTEGER;

-- Create Sequence to generate Surrogate Keys
DROP SEQUENCE IF EXISTS participant_seq;
CREATE SEQUENCE participant_seq
START WITH 1
INCREMENT BY 1;

UPDATE stage_participant SET participant_sk = (NEXT VALUE FOR participant_seq);

-- Check data
SELECT * FROM stage_participant;


-- VoteDate Staging Table
DROP TABLE IF EXISTS stage_vote_date;

CREATE TABLE stage_vote_date AS SELECT VOTEDATE, VOTEMODE, VOTE FROM VOTES;

-- Add SK
ALTER TABLE stage_vote_date ADD vote_date_sk INTEGER;

-- Create Sequence to generate Surrogate Keys
DROP SEQUENCE IF EXISTS vote_date_seq;
CREATE SEQUENCE vote_date_seq
START WITH 1
INCREMENT BY 1;

UPDATE stage_vote_date SET vote_date_sk = (NEXT VALUE FOR vote_date_seq);

-- Check data
SELECT * FROM stage_vote_date;


-- Edition Staging Table
DROP TABLE IF EXISTS stage_edition;

CREATE TABLE stage_edition AS SELECT * FROM Edition;

-- Add SK
ALTER TABLE stage_edition ADD edition_sk INTEGER;

-- Create Sequence to generate Surrogate Keys
DROP SEQUENCE IF EXISTS edition_seq;
CREATE SEQUENCE edition_seq
START WITH 1
INCREMENT BY 1;

UPDATE stage_edition SET edition_sk = (NEXT VALUE FOR edition_seq);

-- Check data
SELECT * FROM stage_edition;

-- Viewer Category Staging Table
DROP TABLE IF EXISTS stage_viewer_category;
CREATE TABLE stage_viewer_category AS SELECT * FROM VIEWERCATEGORY;

-- Add SK
ALTER TABLE stage_viewer_category ADD category_sk INTEGER;


-- Create Sequence to generate SK's
DROP SEQUENCE IF EXISTS category_seq;
CREATE SEQUENCE category_seq
START WITH 1
INCREMENT BY 1;

UPDATE stage_viewer_category SET category_sk = (NEXT VALUE FOR category_seq);

-- Check data
SELECT * FROM stage_viewer_category;


-- Create Votes staging table for Fact Table
DROP TABLE IF EXISTS stage_facts;

CREATE TABLE stage_facts 
AS SELECT VOTEDATE,VIEWERID,EDITION_YEAR,VOTE_CATEGORY,PARTNAME 
FROM VOTES;


SELECT * FROM stage_facts;

-- Add SK's
ALTER TABLE stage_facts ADD vote_date_sk INTEGER;
ALTER TABLE stage_facts ADD viewer_sk INTEGER;
ALTER TABLE stage_facts ADD participant_sk INTEGER;
ALTER TABLE stage_facts ADD edition_sk INTEGER;
ALTER TABLE stage_facts ADD category_sk INTEGER;

-- Assign values to SK's using stage tables as lookup

SELECT * FROM stage_vote_date;

UPDATE stage_facts
SET vote_date_sk = (SELECT stage_vote_date.vote_date_sk FROM stage_vote_date
					WHERE stage_vote_date.vote_date_sk  = stage_facts.viewer_sk);

UPDATE stage_facts
SET viewer_sk = (SELECT stage_viewer.viewer_sk FROM stage_viewer
					WHERE stage_viewer.VIEWERID = stage_facts.VIEWERID);
				
UPDATE stage_facts
SET participant_sk = (SELECT stage_participant.participant_sk FROM stage_participant
					WHERE stage_participant.PARTNAME = stage_facts.PARTNAME);				
				
UPDATE stage_facts
SET edition_sk = (SELECT stage_edition.edition_sk FROM stage_edition
					WHERE stage_edition.EDYEAR = stage_facts.EDITION_YEAR);
				
UPDATE stage_facts
SET category_sk = (SELECT stage_viewer_category.category_sk FROM stage_viewer_category
					WHERE stage_viewer_category.CATID  = stage_facts.VOTE_CATEGORY);				
				
SELECT * FROM stage_facts;

-- Loading Data into Star Schema

-- VoteDate Dimension
SELECT * FROM stage_vote_date;

INSERT INTO dimVoteDate (vote_date_sk, vote_date,vote_mode,vote)
SELECT vote_date_sk, VOTEDATE,VOTEMODE,VOTE FROM stage_vote_date;

SELECT * FROM dimVoteDate;

--  Viewer Dimension
SELECT * FROM stage_viewer;

INSERT INTO dimViewer (viewer_sk,viewer_id, age_group_desc, county_name)
SELECT viewer_sk, VIEWERID, AGE_GROUP_DESC, COUNTYNAME FROM stage_viewer;

SELECT * FROM dimViewer;

-- Participant Dimension

SELECT * FROM stage_participant;

INSERT INTO dimParticipant (participant_sk, part_name, county_name)
SELECT participant_sk, PARTNAME, COUNTYNAME FROM stage_participant;

SELECT * FROM dimParticipant;

-- Edition Dimension

SELECT * FROM stage_edition;

INSERT INTO dimEdition (edition_sk, ed_year, ed_presenter)
SELECT edition_sk, EDYEAR, EDPRESENTER FROM stage_edition;

SELECT * FROM dimEdition;

-- Viewer Category Dimension

SELECT * FROM stage_viewer_category;

INSERT INTO dimViewerCategory (category_sk, cat_id, cat_name)
SELECT category_sk, CATID, CATNAME FROM stage_viewer_category;

SELECT * FROM dimViewerCategory;

-- Votes Fact Table

SELECT * FROM stage_facts;

INSERT INTO voteFacts(vote_date_sk, viewer_sk, participant_sk, edition_sk, category_sk)
SELECT vote_date_sk , viewer_sk , participant_sk , edition_sk , category_sk FROM stage_facts; 

SELECT * FROM voteFacts;