-- Milosz Lewandowski C20355901

-- First Part of the code is query 1 + 2 then altering table to include cost
-- for query 3

-- 1. 
-- For each edition of the programme, 
-- what is the total votes cast by each age group in each county?
-- Include the age group description and county name in the output.

SELECT
    dimEdition.ed_year AS EditionYear,
    dimViewer.age_group_desc AS AgeGroupDescription,
    dimViewer.county_name AS CountyName,
    COUNT(voteFacts.viewer_sk)  AS TotalVotes
FROM
    voteFacts
JOIN
    dimEdition ON voteFacts.edition_sk = dimEdition.edition_sk
JOIN
    dimViewer ON voteFacts.viewer_sk = dimViewer.viewer_sk
GROUP BY
    dimEdition.ed_year,
    dimViewer.age_group_desc,
    dimViewer.county_name
ORDER BY
    dimEdition.ed_year,
    dimViewer.age_group_desc,
    dimViewer.county_name;

-- 2. 
-- For each county, what is the total number of votes received by
-- each participant in the 2022 edition of the programme from audience viewers
-- in that county voting for participants from the same county?
-- Include the county name in the output.

SELECT 
	dimViewer.county_name as ViewerCounty,
	dimViewerCategory.cat_name as ViewerType,
	dimParticipant.county_name as CountyName,
	dimParticipant.part_name as Participant,
	COUNT(voteFacts.viewer_sk) as TotalVotes
FROM
	voteFacts
JOIN 
	dimParticipant ON voteFacts.participant_sk = dimParticipant.participant_sk
JOIN 
	dimViewer ON voteFacts.viewer_sk = dimViewer.viewer_sk
JOIN
	dimEdition ON voteFacts.edition_sk = dimEdition.edition_sk
JOIN
	dimViewerCategory ON voteFacts.category_sk = dimViewerCategory.category_sk
WHERE
	dimEdition.ed_year = '2022'
AND 
	dimViewerCategory.cat_name = 'Audience'
AND
	dimViewer.county_name = dimParticipant.county_name
GROUP BY
	dimParticipant.part_name,
	dimParticipant.county_name;

-- 3. The TV Company charges audience voters to cast their votes
-- Add cost decimal to voteFacts
ALTER TABLE voteFacts ADD COST DECIMAL(10, 2);


-- 3. From 2013 to 2015 the charges were:
-- 20c for votes cast by Facebook and Instagram
-- 50c for votes cast using the TV app and by Phone.

-- From 2016 to 2022 the charges were:
-- 50c for votes cast by Facebook and Instagram
-- 1€ for votes cast using the TV app and by Phone

-- Jury voters are not charged for casting their votes.

-- Update cost based on the year and voting category
-- Update cost for 2013 to 2015, Facebook and Instagram
UPDATE voteFacts 
JOIN dimEdition ON voteFacts.edition_sk = dimEdition.edition_sk
JOIN dimVoteDate  ON voteFacts.vote_date_sk = dimVoteDate.vote_date_sk
SET voteFacts.cost = 0.20
WHERE dimEdition.ed_year BETWEEN '2013' AND '2015'
    AND dimVoteDate.vote_mode  IN ('Facebook', 'Instagram');

-- Update cost for 2013 to 2015, TV and Phone
UPDATE voteFacts 
JOIN dimEdition ON voteFacts.edition_sk = dimEdition.edition_sk
JOIN dimVoteDate ON voteFacts.vote_date_sk  = dimVoteDate.vote_date_sk
SET voteFacts.cost = 0.50
WHERE dimEdition.ed_year BETWEEN '2013' AND '2015'
    AND dimVoteDate.vote_mode  IN ('TV', 'Phone');

-- Update cost for 2016 to 2022, Facebook and Instagram
UPDATE voteFacts
JOIN dimEdition ON voteFacts.edition_sk = dimEdition.edition_sk
JOIN dimVoteDate ON voteFacts.vote_date_sk  = dimVoteDate.vote_date_sk
SET voteFacts.cost = 0.50
WHERE dimEdition.ed_year BETWEEN '2016' AND '2022'
    AND dimVoteDate.vote_mode IN ('Facebook', 'Instagram');

-- Update cost for 2016 to 2022, TV and Phone
UPDATE voteFacts
JOIN dimEdition ON voteFacts.edition_sk = dimEdition.edition_sk
JOIN dimVoteDate ON voteFacts.vote_date_sk  = dimVoteDate.vote_date_sk
SET voteFacts.cost = 1.00
WHERE dimEdition.ed_year BETWEEN '2016' AND '2022'
    AND dimVoteDate.vote_mode IN ('TV', 'Phone');

-- Update cost for Jury voters
UPDATE voteFacts
JOIN dimViewerCategory ON voteFacts.category_sk = dimViewerCategory.category_sk
SET voteFacts.cost = 0.00
WHERE dimViewerCategory.cat_name = 'Jury';

SELECT * FROM voteFacts;


-- For the 2013 and 2019 edition of the programme respectively, 
-- for each county, what was the total income earned from audience viewers
--  in that county for each voting category?
-- Include the county names and the year in the output.


SELECT
    dimViewer.county_name AS CountyName,
    dimEdition.ed_year AS Year,
    dimVoteDate.vote_mode AS VotingMode,
    SUM(voteFacts.cost) AS TotalIncome
FROM
    voteFacts
JOIN
    dimViewer ON voteFacts.viewer_sk  = dimViewer.viewer_sk 
JOIN
    dimEdition ON voteFacts.edition_sk = dimEdition.edition_sk
JOIN
    dimVoteDate  ON  voteFacts.vote_date_sk = dimVoteDate.vote_date_sk 
WHERE
    dimEdition.ed_year IN ('2013', '2019')
AND dimVoteDate.vote_mode IN ('Facebook', 'Instagram', 'TV', 'Phone')
GROUP BY
    dimViewer.county_name,
    dimEdition.ed_year,
    dimVoteDate.vote_mode
ORDER BY
    dimViewer.county_name,
    dimEdition.ed_year,
    dimVoteDate.vote_mode;