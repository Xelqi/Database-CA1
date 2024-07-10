USE MusicCompDB;

-- Run the 3 queries and note the ms
-- Add the given indexes and rerun and note ms

-- My results  Q1    Q2    Q3    
---------------------------------
--  Before    121ms| 72ms|  81ms|
--   After     90ms| 22ms|  46ms|
---------------------------------

-- Query 1
ANALYZE SELECT
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
   
-- Query 2 
ANALYZE SELECT 
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

-- Query 3
ANALYZE SELECT
    dimParticipant.county_name AS CountyName,
    dimEdition.ed_year AS Year,
    dimVoteDate.vote_mode AS VotingMode,
    SUM(voteFacts.cost) AS TotalIncome
FROM
    voteFacts
JOIN
    dimParticipant ON voteFacts.participant_sk = dimParticipant.participant_sk
JOIN
    dimEdition ON voteFacts.edition_sk = dimEdition.edition_sk
JOIN
    dimVoteDate  ON  voteFacts.vote_date_sk = dimVoteDate.vote_date_sk 
WHERE
    dimEdition.ed_year IN ('2013', '2019')
    AND dimVoteDate.vote_mode IN ('Facebook', 'Instagram', 'TV', 'Phone')
GROUP BY
    dimParticipant.county_name,
    dimEdition.ed_year,
    dimVoteDate.vote_mode
ORDER BY
    dimParticipant.county_name,
    dimEdition.ed_year,
    dimVoteDate.vote_mode;

-- Only index that matters as viewers is the largest table with 47k columns so indexing this improves speed by 30-50%
-- for all q's
CREATE INDEX idx_comp ON voteFacts (edition_sk,viewer_sk);

-- This specifically increases speed for where clauses on year by a SIGNIFICANT amount
CREATE INDEX idx_dimEdition_ed_year ON dimEdition (ed_year);
 


-- Just me testing not needed


-- DROP INDEX IF EXISTS idx_voteFacts_edition_sk ON dimEdition;
-- DROP INDEX IF EXISTS idx_voteFacts_viewer_sk ON dimViewer;
-- DROP INDEX IF EXISTS idx_dimEdition_ed_year ON voteFacts;
-- DROP INDEX IF EXISTS idx_dimViewer_age_group_desc ON dimViewer(age_group_desc);
-- DROP INDEX IF EXISTS idx_dimViewer_county_name ON dimViewer(county_name);
-- CREATE INDEX gatwaa ON dimViewer (viewer_sk,age_group_desc,county_name);
-- CREATE INDEX dupa2 ON dimEdition (edition_sk,ed_year);
-- CREATE INDEX idx_voteFacts_edition_sk ON voteFacts (edition_sk);
-- CREATE INDEX idx_voteFacts_viewer_sk ON voteFacts (viewer_sk);
-- CREATE INDEX idx_dimViewer_age_group_desc ON dimViewer (age_group_desc);
-- CREATE INDEX idx_dimViewer_county_name ON dimViewer (county_name);

   

	


-- No point in
-- CREATE INDEX idx_voteFacts_grouping ON voteFacts (participant_sk, edition_sk, vote_date_sk, cost);
   

