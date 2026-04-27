/* EXTRACTING THE DATA AND LOADING THE TABLES INTO THE DATABASE

Tables Created 
Beneficiary tables from the old and new systems for each year
Beneficiary_Summary_2008
Beneficiary_Summary_2009
Beneficiary_Summary_2010 
Beneficiary_Summary_2008_new
Beneficiary_Summary_2009_new
Beneficiary_Summary_2010_new
Carrier tables 1A and 1B to hold the data from the old and the new system

Carrier_Claims_Sample_1A
Carrier_Claims_Sample_1A
Carrier_Claims_Sample_1A_new
Carrier_Claims_Sample_1A_New

*/


-- Beneficiary table for 2009 from old system
CREATE TABLE Beneficiary_Summary_2008 AS 
SELECT * FROM read_csv_auto('/Users/srilatharanganathan/Downloads/DE1_0_2008_Beneficiary_Summary_File_Sample_1.csv');

-- Beneficiary table for 2009 from old system
CREATE TABLE Beneficiary_Summary_2009 AS 
SELECT * FROM read_csv_auto('/Users/srilatharanganathan/Downloads/DE1_0_2009_Beneficiary_Summary_File_Sample_1.csv');

-- Beneficiary table for 2010 from old system
CREATE TABLE Beneficiary_Summary_2010 AS 
SELECT * FROM read_csv_auto('/Users/srilatharanganathan/Downloads/DE1_0_2010_Beneficiary_Summary_File_Sample_1.csv');

-- Beneficiary table for 2008 from new system
CREATE TABLE Beneficiary_Summary_2008_new AS 
SELECT * FROM read_csv_auto('/Users/srilatharanganathan/Downloads/DE1_0_2009_Beneficiary_Summary_File_Sample_1_NEWSYSTEM.csv');

-- Beneficiary table for 2009 from new system
CREATE TABLE Beneficiary_Summary_2009_new AS 
SELECT * FROM read_csv_auto('/Users/srilatharanganathan/Downloads/DE1_0_2009_Beneficiary_Summary_File_Sample_1_NEWSYSTEM.csv');

-- Beneficiary table for 2010 from new system
CREATE TABLE Beneficiary_Summary_2010_new AS 
SELECT * FROM read_csv_auto('/Users/srilatharanganathan/Downloads/DE1_0_2010_Beneficiary_Summary_File_Sample_1_NEWSYSTEM.csv');

-- Loading Carries claims 1A for 2008-2010 from Old System
CREATE TABLE Carrier_Claims_Sample_1A AS 
SELECT * FROM read_csv_auto('/Users/srilatharanganathan/Downloads/DE1_0_2008_to_2010_Carrier_Claims_Sample_1A.csv’);

-- Loading Carries claims 1B for 2008-2010 from Old System
CREATE TABLE Carrier_Claims_Sample_1B AS 
SELECT * FROM read_csv_auto('/Users/srilatharanganathan/Downloads/DE1_0_2008_to_2010_Carrier_Claims_Sample_1B.csv');

-- Loading Carries claims 1A for 2008-2010 from New System
CREATE TABLE Carrier_Claims_Sample_1A_New AS 
SELECT * FROM read_csv_auto('/Users/srilatharanganathan/Downloads/DE1_0_2008_to_2010_Carrier_Claims_Sample_1A_NEWSYSTEM.csv');

-- Loading Carries claims 1B for 2008-2010 from New System
CREATE TABLE Carrier_Claims_Sample_1B_New AS 
SELECT * FROM read_csv_auto('/Users/srilatharanganathan/Downloads/DE1_0_2008_to_2010_Carrier_Claims_Sample_1B_NEWSYSTEM.csv');



-- Cursory Check to make sure the number of records in the old and the new system match 
Select count(*) from Beneficiary_Summary_2008;

Select count(*) from Beneficiary_Summary_2009;

Select count(*) from Beneficiary_Summary_2010;

Select count(*) from Beneficiary_Summary_2008_New;

Select count(*) from Beneficiary_Summary_2009_New;

Select count(*) from Beneficiary_Summary_2010_New;

Select count(*) from Carrier_Claims_Sample_1A;

Select count(*) from Carrier_Claims_Sample_1B;

Select count(*) from Carrier_Claims_Sample_1A_New;

Select count(*) from Carrier_Claims_Sample_1B_New;


/* 
Starting the Analysis here to find the discrepancies in the old system 
Q1- Comparing the Old and the new records. 
There was no discrepancy found at this level
*/

SELECT
    year,
    old_system_records,
    new_system_records,
    new_system_records - old_system_records AS record_difference,
    
FROM (
    SELECT 2008 AS year,
           (SELECT COUNT(*) FROM Beneficiary_Summary_2008)      AS old_system_records,
           (SELECT COUNT(*) FROM Beneficiary_Summary_2008_New)      AS new_system_records
    UNION ALL
     SELECT 2009 AS year,
           (SELECT COUNT(*) FROM Beneficiary_Summary_2009)      AS old_system_records,
           (SELECT COUNT(*) FROM Beneficiary_Summary_2009_New)      AS new_system_records
    UNION ALL
    SELECT 2010 AS year,
           (SELECT COUNT(*) FROM Beneficiary_Summary_2010)      AS old_system_records,
           (SELECT COUNT(*) FROM Beneficiary_Summary_2010_New)      AS new_system_records
)
ORDER BY year;

/* 
Results from the above query for easier inspection
Year		Old_System_Records      New_System_Records
2008		116352				116352
2009		114538				114538
2010		112754				112754

*/

/* 
Q2 - Query to see how many mismatches are their between 2008 old and new data on field by field basis
Though the number of records match between the old and the system there could be field level discrepancies which shows the data has not been transferred correctly 
The below query is executed for year 2008
*/

SELECT
    field_name,
    COUNT(*)                                        AS mismatched_records,
    ROUND(COUNT(*) * 100.0 / 116352, 3)            AS mismatch_pct,
    116352 - COUNT(*)                               AS matching_records,
    ROUND((116352 - COUNT(*)) * 100.0 / 116352, 3) AS match_pct
FROM (
    SELECT 'BENE_BIRTH_DT'            AS field_name FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_BIRTH_DT           AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_BIRTH_DT           AS VARCHAR)
    UNION ALL
    SELECT 'BENE_DEATH_DT'                          FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_DEATH_DT           AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_DEATH_DT           AS VARCHAR)
    UNION ALL
    SELECT 'BENE_SEX_IDENT_CD'                      FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_SEX_IDENT_CD       AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_SEX_IDENT_CD       AS VARCHAR)
    UNION ALL
    SELECT 'BENE_RACE_CD'                           FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_RACE_CD            AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_RACE_CD            AS VARCHAR)
    UNION ALL
    SELECT 'BENE_ESRD_IND'                          FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_ESRD_IND           AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_ESRD_IND           AS VARCHAR)
    UNION ALL
    SELECT 'SP_STATE_CODE'                          FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_STATE_CODE           AS VARCHAR) IS DISTINCT FROM CAST(n.SP_STATE_CODE           AS VARCHAR)
    UNION ALL
    SELECT 'BENE_COUNTY_CD'                         FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_COUNTY_CD          AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_COUNTY_CD          AS VARCHAR)
    UNION ALL
    SELECT 'BENE_HI_CVRAGE_TOT_MONS'               FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_HI_CVRAGE_TOT_MONS AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_HI_CVRAGE_TOT_MONS AS VARCHAR)
    UNION ALL
    SELECT 'BENE_SMI_CVRAGE_TOT_MONS'              FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_SMI_CVRAGE_TOT_MONS AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_SMI_CVRAGE_TOT_MONS AS VARCHAR)
    UNION ALL
    SELECT 'BENE_HMO_CVRAGE_TOT_MONS'              FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_HMO_CVRAGE_TOT_MONS AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_HMO_CVRAGE_TOT_MONS AS VARCHAR)
    UNION ALL
    SELECT 'PLAN_CVRG_MOS_NUM'                      FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.PLAN_CVRG_MOS_NUM       AS VARCHAR) IS DISTINCT FROM CAST(n.PLAN_CVRG_MOS_NUM       AS VARCHAR)
    UNION ALL
    SELECT 'SP_ALZHDMTA'                            FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_ALZHDMTA             AS VARCHAR) IS DISTINCT FROM CAST(n.SP_ALZHDMTA             AS VARCHAR)
    UNION ALL
    SELECT 'SP_CHF'                                 FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_CHF                  AS VARCHAR) IS DISTINCT FROM CAST(n.SP_CHF                  AS VARCHAR)
    UNION ALL
    SELECT 'SP_CHRNKIDN'                            FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_CHRNKIDN             AS VARCHAR) IS DISTINCT FROM CAST(n.SP_CHRNKIDN             AS VARCHAR)
    UNION ALL
    SELECT 'SP_CNCR'                                FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_CNCR                 AS VARCHAR) IS DISTINCT FROM CAST(n.SP_CNCR                 AS VARCHAR)
    UNION ALL
    SELECT 'SP_COPD'                                FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_COPD                 AS VARCHAR) IS DISTINCT FROM CAST(n.SP_COPD                 AS VARCHAR)
    UNION ALL
    SELECT 'SP_DEPRESSN'                            FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_DEPRESSN             AS VARCHAR) IS DISTINCT FROM CAST(n.SP_DEPRESSN             AS VARCHAR)
    UNION ALL
    SELECT 'SP_DIABETES'                            FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_DIABETES             AS VARCHAR) IS DISTINCT FROM CAST(n.SP_DIABETES             AS VARCHAR)
    UNION ALL
    SELECT 'SP_ISCHMCHT'                            FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_ISCHMCHT             AS VARCHAR) IS DISTINCT FROM CAST(n.SP_ISCHMCHT             AS VARCHAR)
    UNION ALL
    SELECT 'SP_OSTEOPRS'                            FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_OSTEOPRS             AS VARCHAR) IS DISTINCT FROM CAST(n.SP_OSTEOPRS             AS VARCHAR)
    UNION ALL
    SELECT 'SP_RA_OA'                               FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_RA_OA                AS VARCHAR) IS DISTINCT FROM CAST(n.SP_RA_OA                AS VARCHAR)
    UNION ALL
    SELECT 'SP_STRKETIA'                            FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_STRKETIA             AS VARCHAR) IS DISTINCT FROM CAST(n.SP_STRKETIA             AS VARCHAR)
    UNION ALL
    SELECT 'MEDREIMB_IP'                            FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.MEDREIMB_IP             AS VARCHAR) IS DISTINCT FROM CAST(n.MEDREIMB_IP             AS VARCHAR)
    UNION ALL
    SELECT 'BENRES_IP'                              FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENRES_IP               AS VARCHAR) IS DISTINCT FROM CAST(n.BENRES_IP               AS VARCHAR)
    UNION ALL
    SELECT 'PPPYMT_IP'                              FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.PPPYMT_IP               AS VARCHAR) IS DISTINCT FROM CAST(n.PPPYMT_IP               AS VARCHAR)
    UNION ALL
    SELECT 'MEDREIMB_OP'                            FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.MEDREIMB_OP             AS VARCHAR) IS DISTINCT FROM CAST(n.MEDREIMB_OP             AS VARCHAR)
    UNION ALL
    SELECT 'BENRES_OP'                              FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENRES_OP               AS VARCHAR) IS DISTINCT FROM CAST(n.BENRES_OP               AS VARCHAR)
    UNION ALL
    SELECT 'PPPYMT_OP'                              FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.PPPYMT_OP               AS VARCHAR) IS DISTINCT FROM CAST(n.PPPYMT_OP               AS VARCHAR)
    UNION ALL
    SELECT 'MEDREIMB_CAR'                           FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.MEDREIMB_CAR            AS VARCHAR) IS DISTINCT FROM CAST(n.MEDREIMB_CAR            AS VARCHAR)
    UNION ALL
    SELECT 'BENRES_CAR'                             FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENRES_CAR              AS VARCHAR) IS DISTINCT FROM CAST(n.BENRES_CAR              AS VARCHAR)
    UNION ALL
    SELECT 'PPPYMT_CAR'                             FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.PPPYMT_CAR              AS VARCHAR) IS DISTINCT FROM CAST(n.PPPYMT_CAR              AS VARCHAR)
)
GROUP BY field_name
ORDER BY mismatched_records DESC;

/*
Results from the above query which shows the number of mismatched records,  the % of mismatches, number of matching records and the match percent 
field_name						mismatched_records		mismatch_pct			matching_records		match_pct
BENE_BIRTH_DT						63				0.054				116289				99.946
BENRES_OP						15				0.013				116337				99.987
PPPYMT_OP						15				0.013				116337				99.987
BENRES_CAR						14				0.012				116338				99.988
BENE_HMO_CVRAGE_TOT_MONS				12				0.01				116340				99.99
MEDREIMB_OP						12				0.01				116340				99.99
BENRES_IP						11				0.009				116341				99.991
PLAN_CVRG_MOS_NUM					10				0.009				116342				99.991
PPPYMT_IP						9				0.008				116343				99.992
MEDREIMB_IP						9				0.008				116343				99.992
BENE_HI_CVRAGE_TOT_MONS					8				0.007				116344				99.993
MEDREIMB_CAR						8				0.007				116344				99.993
BENE_SMI_CVRAGE_TOT_MONS				7				0.006				116345				99.994
PPPYMT_CAR						6				0.005				116346				99.995
*/

/*
The above query repeated for 2009. 
*/

SELECT
    field_name,
    COUNT(*)                                        AS mismatched_records,
    ROUND(COUNT(*) * 100.0 / 116352, 3)            AS mismatch_pct,
    116352 - COUNT(*)                               AS matching_records,
    ROUND((116352 - COUNT(*)) * 100.0 / 116352, 3) AS match_pct
FROM (
    SELECT 'BENE_BIRTH_DT'            AS field_name FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_BIRTH_DT           AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_BIRTH_DT           AS VARCHAR)
    UNION ALL
    SELECT 'BENE_DEATH_DT'                          FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_DEATH_DT           AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_DEATH_DT           AS VARCHAR)
    UNION ALL
    SELECT 'BENE_SEX_IDENT_CD'                      FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_SEX_IDENT_CD       AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_SEX_IDENT_CD       AS VARCHAR)
    UNION ALL
    SELECT 'BENE_RACE_CD'                           FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_RACE_CD            AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_RACE_CD            AS VARCHAR)
    UNION ALL
    SELECT 'BENE_ESRD_IND'                          FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_ESRD_IND           AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_ESRD_IND           AS VARCHAR)
    UNION ALL
    SELECT 'SP_STATE_CODE'                          FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_STATE_CODE           AS VARCHAR) IS DISTINCT FROM CAST(n.SP_STATE_CODE           AS VARCHAR)
    UNION ALL
    SELECT 'BENE_COUNTY_CD'                         FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_COUNTY_CD          AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_COUNTY_CD          AS VARCHAR)
    UNION ALL
    SELECT 'BENE_HI_CVRAGE_TOT_MONS'               FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_HI_CVRAGE_TOT_MONS AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_HI_CVRAGE_TOT_MONS AS VARCHAR)
    UNION ALL
    SELECT 'BENE_SMI_CVRAGE_TOT_MONS'              FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_SMI_CVRAGE_TOT_MONS AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_SMI_CVRAGE_TOT_MONS AS VARCHAR)
    UNION ALL
    SELECT 'BENE_HMO_CVRAGE_TOT_MONS'              FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_HMO_CVRAGE_TOT_MONS AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_HMO_CVRAGE_TOT_MONS AS VARCHAR)
    UNION ALL
    SELECT 'PLAN_CVRG_MOS_NUM'                      FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.PLAN_CVRG_MOS_NUM       AS VARCHAR) IS DISTINCT FROM CAST(n.PLAN_CVRG_MOS_NUM       AS VARCHAR)
    UNION ALL
    SELECT 'SP_ALZHDMTA'                            FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_ALZHDMTA             AS VARCHAR) IS DISTINCT FROM CAST(n.SP_ALZHDMTA             AS VARCHAR)
    UNION ALL
    SELECT 'SP_CHF'                                 FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_CHF                  AS VARCHAR) IS DISTINCT FROM CAST(n.SP_CHF                  AS VARCHAR)
    UNION ALL
    SELECT 'SP_CHRNKIDN'                            FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_CHRNKIDN             AS VARCHAR) IS DISTINCT FROM CAST(n.SP_CHRNKIDN             AS VARCHAR)
    UNION ALL
    SELECT 'SP_CNCR'                                FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_CNCR                 AS VARCHAR) IS DISTINCT FROM CAST(n.SP_CNCR                 AS VARCHAR)
    UNION ALL
    SELECT 'SP_COPD'                                FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_COPD                 AS VARCHAR) IS DISTINCT FROM CAST(n.SP_COPD                 AS VARCHAR)
    UNION ALL
    SELECT 'SP_DEPRESSN'                            FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_DEPRESSN             AS VARCHAR) IS DISTINCT FROM CAST(n.SP_DEPRESSN             AS VARCHAR)
    UNION ALL
    SELECT 'SP_DIABETES'                            FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_DIABETES             AS VARCHAR) IS DISTINCT FROM CAST(n.SP_DIABETES             AS VARCHAR)
    UNION ALL
    SELECT 'SP_ISCHMCHT'                            FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_ISCHMCHT             AS VARCHAR) IS DISTINCT FROM CAST(n.SP_ISCHMCHT             AS VARCHAR)
    UNION ALL
    SELECT 'SP_OSTEOPRS'                            FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_OSTEOPRS             AS VARCHAR) IS DISTINCT FROM CAST(n.SP_OSTEOPRS             AS VARCHAR)
    UNION ALL
    SELECT 'SP_RA_OA'                               FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_RA_OA                AS VARCHAR) IS DISTINCT FROM CAST(n.SP_RA_OA                AS VARCHAR)
    UNION ALL
    SELECT 'SP_STRKETIA'                            FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_STRKETIA             AS VARCHAR) IS DISTINCT FROM CAST(n.SP_STRKETIA             AS VARCHAR)
    UNION ALL
    SELECT 'MEDREIMB_IP'                            FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.MEDREIMB_IP             AS VARCHAR) IS DISTINCT FROM CAST(n.MEDREIMB_IP             AS VARCHAR)
    UNION ALL
    SELECT 'BENRES_IP'                              FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENRES_IP               AS VARCHAR) IS DISTINCT FROM CAST(n.BENRES_IP               AS VARCHAR)
    UNION ALL
    SELECT 'PPPYMT_IP'                              FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.PPPYMT_IP               AS VARCHAR) IS DISTINCT FROM CAST(n.PPPYMT_IP               AS VARCHAR)
    UNION ALL
    SELECT 'MEDREIMB_OP'                            FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.MEDREIMB_OP             AS VARCHAR) IS DISTINCT FROM CAST(n.MEDREIMB_OP             AS VARCHAR)
    UNION ALL
    SELECT 'BENRES_OP'                              FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENRES_OP               AS VARCHAR) IS DISTINCT FROM CAST(n.BENRES_OP               AS VARCHAR)
    UNION ALL
    SELECT 'PPPYMT_OP'                              FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.PPPYMT_OP               AS VARCHAR) IS DISTINCT FROM CAST(n.PPPYMT_OP               AS VARCHAR)
    UNION ALL
    SELECT 'MEDREIMB_CAR'                           FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.MEDREIMB_CAR            AS VARCHAR) IS DISTINCT FROM CAST(n.MEDREIMB_CAR            AS VARCHAR)
    UNION ALL
    SELECT 'BENRES_CAR'                             FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENRES_CAR              AS VARCHAR) IS DISTINCT FROM CAST(n.BENRES_CAR              AS VARCHAR)
    UNION ALL
    SELECT 'PPPYMT_CAR'                             FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.PPPYMT_CAR              AS VARCHAR) IS DISTINCT FROM CAST(n.PPPYMT_CAR              AS VARCHAR)
)
GROUP BY field_name
ORDER BY mismatched_records DESC;

/*
Results from the above query which shows the number of mismatched records,  the % of mismatches, number of matching records and the match percent 
field_name						mismatched_records		mismatch_pct			matching_records		match_pct
BENE_BIRTH_DT						63						0.054				116289				99.946
BENRES_CAR						22						0.019				116330				99.981
MEDREIMB_OP						21						0.018				116331				99.982
PPPYMT_CAR						19						0.016				116333				99.984
BENE_HMO_CVRAGE_TOT_MONS				15						0.013				116337				99.987
BENRES_IP						15						0.013				116337				99.987
PPPYMT_IP						14						0.012				116338				99.988
MEDREIMB_IP						13						0.011				116339				99.989
BENE_HI_CVRAGE_TOT_MONS					12						0.01				116340				99.99
BENRES_OP						11						0.009				116341				99.991
BENE_SMI_CVRAGE_TOT_MONS				11						0.009				116341				99.991
PLAN_CVRG_MOS_NUM					8						0.007				116344				99.993
MEDREIMB_CAR						8						0.007				116344				99.993
PPPYMT_OP						7						0.006				116345				99.994
*/

/*
The above query repeated for 2010. 
*/
SELECT
    field_name,
    COUNT(*)                                        AS mismatched_records,
    ROUND(COUNT(*) * 100.0 / 116352, 3)            AS mismatch_pct,
    116352 - COUNT(*)                               AS matching_records,
    ROUND((116352 - COUNT(*)) * 100.0 / 116352, 3) AS match_pct
FROM (
    SELECT 'BENE_BIRTH_DT'            AS field_name FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_BIRTH_DT           AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_BIRTH_DT           AS VARCHAR)
    UNION ALL
    SELECT 'BENE_DEATH_DT'                          FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_DEATH_DT           AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_DEATH_DT           AS VARCHAR)
    UNION ALL
    SELECT 'BENE_SEX_IDENT_CD'                      FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_SEX_IDENT_CD       AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_SEX_IDENT_CD       AS VARCHAR)
    UNION ALL
    SELECT 'BENE_RACE_CD'                           FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_RACE_CD            AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_RACE_CD            AS VARCHAR)
    UNION ALL
    SELECT 'BENE_ESRD_IND'                          FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_ESRD_IND           AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_ESRD_IND           AS VARCHAR)
    UNION ALL
    SELECT 'SP_STATE_CODE'                          FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_STATE_CODE           AS VARCHAR) IS DISTINCT FROM CAST(n.SP_STATE_CODE           AS VARCHAR)
    UNION ALL
    SELECT 'BENE_COUNTY_CD'                         FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_COUNTY_CD          AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_COUNTY_CD          AS VARCHAR)
    UNION ALL
    SELECT 'BENE_HI_CVRAGE_TOT_MONS'               FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_HI_CVRAGE_TOT_MONS AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_HI_CVRAGE_TOT_MONS AS VARCHAR)
    UNION ALL
    SELECT 'BENE_SMI_CVRAGE_TOT_MONS'              FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_SMI_CVRAGE_TOT_MONS AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_SMI_CVRAGE_TOT_MONS AS VARCHAR)
    UNION ALL
    SELECT 'BENE_HMO_CVRAGE_TOT_MONS'              FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENE_HMO_CVRAGE_TOT_MONS AS VARCHAR) IS DISTINCT FROM CAST(n.BENE_HMO_CVRAGE_TOT_MONS AS VARCHAR)
    UNION ALL
    SELECT 'PLAN_CVRG_MOS_NUM'                      FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.PLAN_CVRG_MOS_NUM       AS VARCHAR) IS DISTINCT FROM CAST(n.PLAN_CVRG_MOS_NUM       AS VARCHAR)
    UNION ALL
    SELECT 'SP_ALZHDMTA'                            FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_ALZHDMTA             AS VARCHAR) IS DISTINCT FROM CAST(n.SP_ALZHDMTA             AS VARCHAR)
    UNION ALL
    SELECT 'SP_CHF'                                 FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_CHF                  AS VARCHAR) IS DISTINCT FROM CAST(n.SP_CHF                  AS VARCHAR)
    UNION ALL
    SELECT 'SP_CHRNKIDN'                            FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_CHRNKIDN             AS VARCHAR) IS DISTINCT FROM CAST(n.SP_CHRNKIDN             AS VARCHAR)
    UNION ALL
    SELECT 'SP_CNCR'                                FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_CNCR                 AS VARCHAR) IS DISTINCT FROM CAST(n.SP_CNCR                 AS VARCHAR)
    UNION ALL
    SELECT 'SP_COPD'                                FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_COPD                 AS VARCHAR) IS DISTINCT FROM CAST(n.SP_COPD                 AS VARCHAR)
    UNION ALL
    SELECT 'SP_DEPRESSN'                            FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_DEPRESSN             AS VARCHAR) IS DISTINCT FROM CAST(n.SP_DEPRESSN             AS VARCHAR)
    UNION ALL
    SELECT 'SP_DIABETES'                            FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_DIABETES             AS VARCHAR) IS DISTINCT FROM CAST(n.SP_DIABETES             AS VARCHAR)
    UNION ALL
    SELECT 'SP_ISCHMCHT'                            FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_ISCHMCHT             AS VARCHAR) IS DISTINCT FROM CAST(n.SP_ISCHMCHT             AS VARCHAR)
    UNION ALL
    SELECT 'SP_OSTEOPRS'                            FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_OSTEOPRS             AS VARCHAR) IS DISTINCT FROM CAST(n.SP_OSTEOPRS             AS VARCHAR)
    UNION ALL
    SELECT 'SP_RA_OA'                               FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_RA_OA                AS VARCHAR) IS DISTINCT FROM CAST(n.SP_RA_OA                AS VARCHAR)
    UNION ALL
    SELECT 'SP_STRKETIA'                            FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.SP_STRKETIA             AS VARCHAR) IS DISTINCT FROM CAST(n.SP_STRKETIA             AS VARCHAR)
    UNION ALL
    SELECT 'MEDREIMB_IP'                            FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.MEDREIMB_IP             AS VARCHAR) IS DISTINCT FROM CAST(n.MEDREIMB_IP             AS VARCHAR)
    UNION ALL
    SELECT 'BENRES_IP'                              FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENRES_IP               AS VARCHAR) IS DISTINCT FROM CAST(n.BENRES_IP               AS VARCHAR)
    UNION ALL
    SELECT 'PPPYMT_IP'                              FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.PPPYMT_IP               AS VARCHAR) IS DISTINCT FROM CAST(n.PPPYMT_IP               AS VARCHAR)
    UNION ALL
    SELECT 'MEDREIMB_OP'                            FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.MEDREIMB_OP             AS VARCHAR) IS DISTINCT FROM CAST(n.MEDREIMB_OP             AS VARCHAR)
    UNION ALL
    SELECT 'BENRES_OP'                              FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENRES_OP               AS VARCHAR) IS DISTINCT FROM CAST(n.BENRES_OP               AS VARCHAR)
    UNION ALL
    SELECT 'PPPYMT_OP'                              FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.PPPYMT_OP               AS VARCHAR) IS DISTINCT FROM CAST(n.PPPYMT_OP               AS VARCHAR)
    UNION ALL
    SELECT 'MEDREIMB_CAR'                           FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.MEDREIMB_CAR            AS VARCHAR) IS DISTINCT FROM CAST(n.MEDREIMB_CAR            AS VARCHAR)
    UNION ALL
    SELECT 'BENRES_CAR'                             FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.BENRES_CAR              AS VARCHAR) IS DISTINCT FROM CAST(n.BENRES_CAR              AS VARCHAR)
    UNION ALL
    SELECT 'PPPYMT_CAR'                             FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID WHERE CAST(o.PPPYMT_CAR              AS VARCHAR) IS DISTINCT FROM CAST(n.PPPYMT_CAR              AS VARCHAR)
)
GROUP BY field_name
ORDER BY mismatched_records DESC;

/*
Results from the above query which shows the number of mismatched records,  the % of mismatches, number of matching records and the match percent 
field_name						mismatched_records		mismatch_pct			matching_records		match_pct
BENE_BIRTH_DT					52						0.045				116300				99.955
PPPYMT_CAR					19						0.016				116333				99.984
MEDREIMB_IP					16						0.014				116336				99.986
BENRES_OP					15						0.013				116337				99.987
MEDREIMB_OP					14						0.012				116338				99.988
MEDREIMB_CAR					14						0.012				116338				99.988
PPPYMT_IP					11						0.009				116341				99.991
BENE_HMO_CVRAGE_TOT_MONS			11						0.009				116341				99.991
BENRES_CAR					10						0.009				116342				99.991
PPPYMT_OP					9						0.008				116343				99.992
BENE_HI_CVRAGE_TOT_MONS				9						0.008				116343				99.992
BENE_SMI_CVRAGE_TOT_MONS			8						0.007				116344				99.993
BENRES_IP					6						0.005				116346				99.995
PLAN_CVRG_MOS_NUM				5						0.004				116347				99.996
*/


/*
Q3- Comparing to see if there death dates were different between the old and the new systems for any of the beneficiaries
*/

SELECT
    CASE
        WHEN o.BENE_DEATH_DT IS NULL AND n.BENE_DEATH_DT IS NOT NULL
            THEN 'Death date ADDED in new system'
        WHEN o.BENE_DEATH_DT IS NOT NULL AND n.BENE_DEATH_DT IS NULL
            THEN 'Death date REMOVED in new system'
        WHEN o.BENE_DEATH_DT IS DISTINCT FROM n.BENE_DEATH_DT
            THEN 'Death date CHANGED'
    END                                           AS issue_type,
    COUNT(*)                                      AS affected_records
FROM Beneficiary_Summary_2010 o
JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID
WHERE o.BENE_DEATH_DT IS DISTINCT FROM n.BENE_DEATH_DT
GROUP BY issue_type;

SELECT
    CASE
        WHEN o.BENE_DEATH_DT IS NULL AND n.BENE_DEATH_DT IS NOT NULL
            THEN 'Death date ADDED in new system'
        WHEN o.BENE_DEATH_DT IS NOT NULL AND n.BENE_DEATH_DT IS NULL
            THEN 'Death date REMOVED in new system'
        WHEN o.BENE_DEATH_DT IS DISTINCT FROM n.BENE_DEATH_DT
            THEN 'Death date CHANGED'
    END                                           AS issue_type,
    COUNT(*)                                      AS affected_records
FROM Beneficiary_Summary_2009 o
JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID
WHERE o.BENE_DEATH_DT IS DISTINCT FROM n.BENE_DEATH_DT
GROUP BY issue_type;

SELECT
    CASE
        WHEN o.BENE_DEATH_DT IS NULL AND n.BENE_DEATH_DT IS NOT NULL
            THEN 'Death date ADDED in new system'
        WHEN o.BENE_DEATH_DT IS NOT NULL AND n.BENE_DEATH_DT IS NULL
            THEN 'Death date REMOVED in new system'
        WHEN o.BENE_DEATH_DT IS DISTINCT FROM n.BENE_DEATH_DT
            THEN 'Death date CHANGED'
    END                                           AS issue_type,
    COUNT(*)                                      AS affected_records
FROM Beneficiary_Summary_2008 o
JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID
WHERE o.BENE_DEATH_DT IS DISTINCT FROM n.BENE_DEATH_DT
GROUP BY issue_type;


-- No rows were found for any of the years which means that there was no discrepancy in the death dates


/*
 Q4- ID’s that haven’t been migrated from old system to new system and Id’s that have been introduced in the new system 
The query below is for year 2008
*/

SELECT
    COALESCE(o.DESYNPUF_ID, n.DESYNPUF_ID)   AS DESYNPUF_ID,
    CASE
        WHEN o.DESYNPUF_ID IS NULL THEN 'In NEW only — missing from OLD'
        WHEN n.DESYNPUF_ID IS NULL THEN 'In OLD only — missing from NEW'
    END                                        AS status
FROM Beneficiary_Summary_2008 o
FULL OUTER JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID
WHERE o.DESYNPUF_ID IS NULL
   OR n.DESYNPUF_ID IS NULL
ORDER BY status, DESYNPUF_ID;


/*
This basically shows that some beneficiaries potentially lost coverage as they are not in the new system
Also How were the beneficiaries introduced in the new system. There are some code issues which will need to be looked at
DESYNPUF_ID		status
ZZ01C29B72D68392	In NEW only — missing from OLD
ZZ0B5B81EC33DE81	In NEW only — missing from OLD
ZZ0CE1922052882B	In NEW only — missing from OLD
ZZ0EDC7AE166A9CE	In NEW only — missing from OLD
ZZ18AFD3B7DF2A88	In NEW only — missing from OLD
ZZ1FD27ADE3EDEE8	In NEW only — missing from OLD
ZZ24CB52C4DB3DA1	In NEW only — missing from OLD
ZZ273D2E2920E7FF	In NEW only — missing from OLD
ZZ31DE3089CFD5A1	In NEW only — missing from OLD
ZZ34A7D21BF1F4FF	In NEW only — missing from OLD
ZZ39E0E5CCA73CDE	In NEW only — missing from OLD
ZZ3AB7E3B5A58F9A	In NEW only — missing from OLD
ZZ3D0DB536693E89	In NEW only — missing from OLD
ZZ3F4F88954FDDC3	In NEW only — missing from OLD
ZZ42F95ADEE0F02C	In NEW only — missing from OLD
ZZ46C6DF18D9C8D4	In NEW only — missing from OLD
ZZ4904CF529AA230	In NEW only — missing from OLD
ZZ4EC3E78E09D200	In NEW only — missing from OLD
ZZ4F109EC7A3BCDF	In NEW only — missing from OLD
ZZ50D7AC90049FD8	In NEW only — missing from OLD
ZZ526142B3015799	In NEW only — missing from OLD
ZZ52B653BA2422FB	In NEW only — missing from OLD
ZZ5DCF2CA46F6BB9	In NEW only — missing from OLD
ZZ604C7EEFD4CA46	In NEW only — missing from OLD
ZZ63D891B8029257	In NEW only — missing from OLD
ZZ68C2BA66F98B3A	In NEW only — missing from OLD
ZZ703FDAB797AAD0	In NEW only — missing from OLD
ZZ70A56DEB14630F	In NEW only — missing from OLD
ZZ748399A7A0241D	In NEW only — missing from OLD
ZZ79480C2DCD769B	In NEW only — missing from OLD
ZZ7B877106F8A792	In NEW only — missing from OLD
ZZ87BFF53A7DE20F	In NEW only — missing from OLD
ZZ8ECB29D120B379	In NEW only — missing from OLD
ZZ98E67628B92BEC	In NEW only — missing from OLD
ZZ9E5DEC38236196	In NEW only — missing from OLD
ZZA20FFBBBB48150	In NEW only — missing from OLD
ZZABAE9D46020421	In NEW only — missing from OLD
ZZAC3C244855A66E	In NEW only — missing from OLD
ZZAD8648FA17D27A	In NEW only — missing from OLD
ZZB65374AF8FF54F	In NEW only — missing from OLD
ZZBB4EF80D469B9D	In NEW only — missing from OLD
ZZBE180E89C4650F	In NEW only — missing from OLD
ZZC363EEBA7EDFFA	In NEW only — missing from OLD
ZZCBCFD7D76EABBA	In NEW only — missing from OLD
ZZCBE9EE4C3EC858	In NEW only — missing from OLD
ZZD0647708AF1A59	In NEW only — missing from OLD
ZZD7F7A94C7DBF7E	In NEW only — missing from OLD
ZZDF4B4DC3D61700	In NEW only — missing from OLD
ZZE4DF962B157A98	In NEW only — missing from OLD
002F1C637DB118F8	In OLD only — missing from NEW
0278014838EF2070	In OLD only — missing from NEW
028D1BA49E66A773	In OLD only — missing from NEW
1FA9843031EE67A5	In OLD only — missing from NEW
231280963FA86BCA	In OLD only — missing from NEW
2607595F287596C8	In OLD only — missing from NEW
282E7B38F72D7F3F	In OLD only — missing from NEW
30679AAC6D1EDA96	In OLD only — missing from NEW
3081190C960BCD7A	In OLD only — missing from NEW
3636108C8D3B5102	In OLD only — missing from NEW
4058A04BE9B4A51E	In OLD only — missing from NEW
42840F2E2605C37E	In OLD only — missing from NEW
4739F58FF3F20AD6	In OLD only — missing from NEW
4F7F5061F9297C80	In OLD only — missing from NEW
526DFB073F04CF28	In OLD only — missing from NEW
5542AE47C643FF7F	In OLD only — missing from NEW
5A1AA17834CD5EB7	In OLD only — missing from NEW
5B72D7D9D2972507	In OLD only — missing from NEW
60592E6BF9A7D211	In OLD only — missing from NEW
6F68864ECB34A538	In OLD only — missing from NEW
70168DB8E048A8E1	In OLD only — missing from NEW
77D749E5B36EA9CC	In OLD only — missing from NEW
785FFF0112D17FE2	In OLD only — missing from NEW
78BBF1E754F91DA3	In OLD only — missing from NEW
857E223B98EC505E	In OLD only — missing from NEW
8906A25F608FC079	In OLD only — missing from NEW
89295DBE1898A87D	In OLD only — missing from NEW
8E09E83C6D7AA22F	In OLD only — missing from NEW
91C79801DB76E9E1	In OLD only — missing from NEW
96DB3DE145C8AE31	In OLD only — missing from NEW
9D054AA286BE592B	In OLD only — missing from NEW
A1A06E6660C0F0AD	In OLD only — missing from NEW
A239C4A7CA64FCA0	In OLD only — missing from NEW
AAEE9875DBFE7964	In OLD only — missing from NEW
AC09F804D7FFD177	In OLD only — missing from NE
B6CC2B608B054C28	In OLD only — missing from NEW
B885E571EC2B2226	In OLD only — missing from NEW
BA4274AA27EAE2A8	In OLD only — missing from NEW
BA931DE22DF5293E	In OLD only — missing from NEW
BB3B988B5E23AE1F	In OLD only — missing from NEW
C468692CCA39AD82	In OLD only — missing from NEW
CA707FF5951CF1BA	In OLD only — missing from NEW
CC4176A6DD80AAEB	In OLD only — missing from NEW
D5411B31478A036F	In OLD only — missing from NEW
DFDE6E401F1D2818	In OLD only — missing from NEW
E06F1066861623E4	In OLD only — missing from NEW
FB497593CA6C7604	In OLD only — missing from NEW
FE6D0A9E3FDDD994	In OLD only — missing from NEW
FEFE98DBE4A782B2	In OLD only — missing from NEW
*/

/*
 ID’s that haven’t been migrated from old system to new system and Id’s that have been introduced in the new system 
The query below is for year 2009
*/

SELECT
    COALESCE(o.DESYNPUF_ID, n.DESYNPUF_ID)   AS DESYNPUF_ID,
    CASE
        WHEN o.DESYNPUF_ID IS NULL THEN 'In NEW only — missing from OLD'
        WHEN n.DESYNPUF_ID IS NULL THEN 'In OLD only — missing from NEW'
    END                                        AS status
FROM Beneficiary_Summary_2009 o
FULL OUTER JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID
WHERE o.DESYNPUF_ID IS NULL
   OR n.DESYNPUF_ID IS NULL
ORDER BY status, DESYNPUF_ID;

/*
This basically shows that some beneficiaries potentially lost coverage as they are not in the new system
Also How were the beneficiaries introduced in the new system. There are some code issues which will need to be looked at

DESYNPUF_ID		status
ZZ0126FEDDEF1EB8	In NEW only — missing from OLD
ZZ0A8491ED439274	In NEW only — missing from OLD
ZZ0BEAE3F6BB4C74	In NEW only — missing from OLD
ZZ0ECA076B8FB731	In NEW only — missing from OLD
ZZ0F259703A83B8C	In NEW only — missing from OLD
ZZ1ADA44F2DF514E	In NEW only — missing from OLD
ZZ1EB309E444F1E7	In NEW only — missing from OLD
ZZ25612B6ABBB866	In NEW only — missing from OLD
ZZ25E7324B6B77D0	In NEW only — missing from OLD
ZZ262907217631DE	In NEW only — missing from OLD
ZZ27B2A62BE59219	In NEW only — missing from OLD
ZZ291B59B78A9F18	In NEW only — missing from OLD
ZZ298ED2C40D82CB	In NEW only — missing from OLD
ZZ2B1AE07807F335	In NEW only — missing from OLD
ZZ2CB33D9565787B	In NEW only — missing from OLD
ZZ37F1A33819249C	In NEW only — missing from OLD
ZZ4422025520EE6E	In NEW only — missing from OLD
ZZ4850B56D7DD99B	In NEW only — missing from OLD
ZZ56E56F915AAF52	In NEW only — missing from OLD
ZZ5702E6185A60DD	In NEW only — missing from OLD
ZZ577130137FA6C4	In NEW only — missing from OLD
ZZ5B18898D24FFD4	In NEW only — missing from OLD
ZZ60F04A80B8E373	In NEW only — missing from OLD
ZZ65ECE899D94852	In NEW only — missing from OLD
ZZ6D5B400247E02B	In NEW only — missing from OLD
ZZ70B055D53DC967	In NEW only — missing from OLD
ZZ71DE95C8985FA7	In NEW only — missing from OLD
ZZ7EC605B51A1ACE	In NEW only — missing from OLD
ZZ852B86308E985E	In NEW only — missing from OLD
ZZ88F462C365212B	In NEW only — missing from OLD
ZZ8B1682288972AA	In NEW only — missing from OLD
ZZ8B6D7391BD9174	In NEW only — missing from OLD
ZZ8C89A923869E85	In NEW only — missing from OLD
ZZ8D770903D0034A	In NEW only — missing from OLD
ZZ94845863BA0026	In NEW only — missing from OLD
ZZ9B6FDDAAE091F6	In NEW only — missing from OLD
ZZ9CAEC6357B5D4B	In NEW only — missing from OLD
ZZ9F3947584F4948	In NEW only — missing from OLD
ZZAA8FCB3951E78A	In NEW only — missing from OLD
ZZB7E81675399284	In NEW only — missing from OLD
ZZBC31C383AAB1EC	In NEW only — missing from OLD
ZZBFE3941AD9E654	In NEW only — missing from OLD
ZZC78DD073E5FACB	In NEW only — missing from OLD
ZZC910141EBAF224	In NEW only — missing from OLD
ZZD024FD7CC2597E	In NEW only — missing from OLD
ZZD067B0E070846D	In NEW only — missing from OLD
ZZD801541B5834E3	In NEW only — missing from OLD
ZZDB717ED4B1A151	In NEW only — missing from OLD
ZZDCA0388A4C9DC2	In NEW only — missing from OLD
ZZE0FC5E47B1391E	In NEW only — missing from OLD
ZZE1E3E86C27CA3E	In NEW only — missing from OLD
ZZE2BCB3CAC5F34B	In NEW only — missing from OLD
ZZE944A590F44EDE	In NEW only — missing from OLD
ZZEDDB3A4B0AEBA8	In NEW only — missing from OLD
ZZF6F3D91A8B88E3	In NEW only — missing from OLD
ZZFDDE44F26CE7EE	In NEW only — missing from OLD
ZZFE9426D913EFD8	In NEW only — missing from OLD
ZZFF74C75B4E7E3D	In NEW only — missing from OLD
09246217E345B3AA	In OLD only — missing from NEW
0CB7A46127EF1D89	In OLD only — missing from NEW
100B9B9B4EDF05B0	In OLD only — missing from NEW
1383933595F2CB0E	In OLD only — missing from NEW
1C9B027D91A9061F	In OLD only — missing from NEW
2356018FE43A9710	In OLD only — missing from NEW
2619239347681C8A	In OLD only — missing from NEW
288D8E7A3AD2620C	In OLD only — missing from NEW
2917F6E87A2B4B4D	In OLD only — missing from NEW
29DB865D674CE0A0	In OLD only — missing from NEW
2A466C4488D10F76	In OLD only — missing from NEW
2A77A017B036E87D	In OLD only — missing from NEW
364EAE75916232DC	In OLD only — missing from NEW
42872038C6263C63	In OLD only — missing from NEW
42DB045A39855637	In OLD only — missing from NEW
452F7600D07EA04A	In OLD only — missing from NEW
48504E1C7853912B	In OLD only — missing from NEW
48606A8F0442306D	In OLD only — missing from NEW
4D3C6C8F74910A16	In OLD only — missing from NEW
50BCE6B31F936483	In OLD only — missing from NEW
59518546657BDC75	In OLD only — missing from NEW
5B641C5DE741E995	In OLD only — missing from NEW
5CECBB8C4639BE0A	In OLD only — missing from NEW
5FAECA8851FDB895	In OLD only — missing from NEW
6159A7C8A69E9CB2	In OLD only — missing from NEW
63DAD42A541551A8	In OLD only — missing from NEW
7BD3AE754C843347	In OLD only — missing from NEW
7CF1A0408142F32F	In OLD only — missing from NEW
7DA192CC04FCDB56	In OLD only — missing from NEW
80E4F94F4159A111	In OLD only — missing from NEW
8E85BD14F7E07764	In OLD only — missing from NEW
915CEF41E16A1B5F	In OLD only — missing from NEW
92810C4C88E8E26A	In OLD only — missing from NEW
96CA5D56F1BD5861	In OLD only — missing from NEW
97FD292620276A7C	In OLD only — missing from NEW
9D3496C6E1B85506	In OLD only — missing from NEW
9D8A56EFC8C8A623	In OLD only — missing from NEW
A7437B3637CB9BAF	In OLD only — missing from NEW
A7EA55B9EC463DB9	In OLD only — missing from NEW
A8A630B3E01D565D	In OLD only — missing from NEW
A9C27C88D8E76459	In OLD only — missing from NEW
B35DB0AB60BC3246	In OLD only — missing from NEW
B3DE91DB98950702	In OLD only — missing from NEW
BAE338136A1269A6	In OLD only — missing from NEW
C20E0A85B49D4698	In OLD only — missing from NEW
C5FAD22D0A4C3D91	In OLD only — missing from NEW
C82EABD9CD484E37	In OLD only — missing from NEW
D0FA0D910AF54E52	In OLD only — missing from NEW
D5701BE1DD1D1ED9	In OLD only — missing from NEW
DDFCB81E3C683CE6	In OLD only — missing from NEW
E2E0ABE9E26D2CA8	In OLD only — missing from NEW
E9F9EC008E97B535	In OLD only — missing from NEW
EB3138CE9FA10214	In OLD only — missing from NEW
ECB89E8A71B1EBFD	In OLD only — missing from NEW
EEAD80730758F68F	In OLD only — missing from NEW
F13B6BAEDDBD7FDE	In OLD only — missing from NEW
F4C2249352E379FF	In OLD only — missing from NEW
FC010443CE04D70D	In OLD only — missing from NEW
*/

/*
 ID’s that haven’t been migrated from old system to new system and Id’s that have been introduced in the new system 
The query below is for year 2010
*/

SELECT
    COALESCE(o.DESYNPUF_ID, n.DESYNPUF_ID)   AS DESYNPUF_ID,
    CASE
        WHEN o.DESYNPUF_ID IS NULL THEN 'In NEW only — missing from OLD'
        WHEN n.DESYNPUF_ID IS NULL THEN 'In OLD only — missing from NEW'
    END                                        AS status
FROM Beneficiary_Summary_2010 o
FULL OUTER JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID
WHERE o.DESYNPUF_ID IS NULL
   OR n.DESYNPUF_ID IS NULL
ORDER BY status, DESYNPUF_ID;

/*
This basically shows that some beneficiaries potentially lost coverage as they are not in the new system
Also How were the beneficiaries introduced in the new system. There are some code issues which will need to be looked at

DESYNPUF_ID		status
ZZ03F61A1D91875E	In NEW only — missing from OLD
ZZ061BF2FA3D6816	In NEW only — missing from OLD
ZZ0DB124F4AC673B	In NEW only — missing from OLD
ZZ116515E94FEB7A	In NEW only — missing from OLD
ZZ12F6125BCB7E89	In NEW only — missing from OLD
ZZ1ABCF8756E13AC	In NEW only — missing from OLD
ZZ274586CAAC555B	In NEW only — missing from OLD
ZZ291D0E3CB30DF0	In NEW only — missing from OLD
ZZ2A49FE2D56126E	In NEW only — missing from OLD
ZZ2C1F925451E0AA	In NEW only — missing from OLD
ZZ329D1DB53EB230	In NEW only — missing from OLD
ZZ3769C2D1FAB169	In NEW only — missing from OLD
ZZ3955E127FC3E36	In NEW only — missing from OLD
ZZ3FD63DEC4893F4	In NEW only — missing from OLD
ZZ41157CE4856ABF	In NEW only — missing from OLD
ZZ42120CA22AF96E	In NEW only — missing from OLD
ZZ429A6A95746B37	In NEW only — missing from OLD
ZZ45BD5E2D60C538	In NEW only — missing from OLD
ZZ487DAD9BE32E43	In NEW only — missing from OLD
ZZ4D3CF6ED205818	In NEW only — missing from OLD
ZZ50687F0A4534DE	In NEW only — missing from OLD
ZZ52F6F453A0DD62	In NEW only — missing from OLD
ZZ5524629DF3A050	In NEW only — missing from OLD
ZZ552FD62C8EA460	In NEW only — missing from OLD
ZZ5D25EF2F1AE558	In NEW only — missing from OLD
ZZ64F14D3B2D07C9	In NEW only — missing from OLD
ZZ72BD4215D88051	In NEW only — missing from OLD
ZZ7DECFF997B3609	In NEW only — missing from OLD
ZZ81CF83BB8A8B3A	In NEW only — missing from OLD
ZZ8405429A965266	In NEW only — missing from OLD
ZZ8758C09360559E	In NEW only — missing from OLD
ZZ8F34C18CCCD565	In NEW only — missing from OLD
ZZ94B530FB1E9730	In NEW only — missing from OLD
ZZ97D876A0558B59	In NEW only — missing from OLD
ZZ9A15DBB3DBDA1E	In NEW only — missing from OLD
ZZ9C77C8DA900A38	In NEW only — missing from OLD
ZZ9F54A1EA16AAE0	In NEW only — missing from OLD
ZZA1ADE73335A504	In NEW only — missing from OLD
ZZA8368A40114D88	In NEW only — missing from OLD
ZZB75665655E2208	In NEW only — missing from OLD
ZZB80A350DAFBE15	In NEW only — missing from OLD
ZZBE8DACCA903C28	In NEW only — missing from OLD
ZZBF4A0733DD71E6	In NEW only — missing from OLD
ZZC2FFAD65028967	In NEW only — missing from OLD
ZZCCC365055E966B	In NEW only — missing from OLD
ZZDB84F5E9C240EE	In NEW only — missing from OLD
ZZDD584C30D66D13	In NEW only — missing from OLD
ZZDF884557B13B72	In NEW only — missing from OLD
ZZF6625A42FD330C	In NEW only — missing from OLD
ZZF91227DDA6C237	In NEW only — missing from OLD
ZZFC490DDF7E4B10	In NEW only — missing from OLD
ZZFCA190DE061E54	In NEW only — missing from OLD
0D2E99BEBB138015	In OLD only — missing from NEW
167A2BA64B965DB5	In OLD only — missing from NEW
181BAF2C78354F70	In OLD only — missing from NEW
1C3C08D4A1E07525	In OLD only — missing from NEW
1C916548C54356B4	In OLD only — missing from NEW
276FC608BA785095	In OLD only — missing from NEW
2D5D9512D76A752A	In OLD only — missing from NEW
2F224E1525A7AA8C	In OLD only — missing from NEW
356091EAF149BFEF	In OLD only — missing from NEW
4010D45ECC8C6F61	In OLD only — missing from NEW
4313D5AB7686FB7F	In OLD only — missing from NEW
43746A21379DF064	In OLD only — missing from NEW
4739DC66E8FEDC49	In OLD only — missing from NEW
4C9AB7D60D752074	In OLD only — missing from NEW
53BA1096578015CE	In OLD only — missing from NEW
54E7ACB9A35E29F3	In OLD only — missing from NEW
57B0D1916CE0E43D	In OLD only — missing from NEW
5B7AF11B3BD3FEFC	In OLD only — missing from NEW
5E43BDAE0A3AB97C	In OLD only — missing from NEW
68E1BC34ED5BAC8C	In OLD only — missing from NEW
693C49CDD90E7C28	In OLD only — missing from NEW
72448E6655C2519A	In OLD only — missing from NEW
7246C7C5382A46B7	In OLD only — missing from NEW
7BD830E37E20B499	In OLD only — missing from NEW
7FF48E06201D62BA	In OLD only — missing from NEW
85468DF9372FB594	In OLD only — missing from NEW
882EB0D0F8498E91	In OLD only — missing from NEW
88BDD059AFC07FF4	In OLD only — missing from NEW
89E3FBBEC3683C64	In OLD only — missing from NEW
8E586261EA82BE43	In OLD only — missing from NEW
96CE16855050F805	In OLD only — missing from NEW
997FF6E1C15C2BC3	In OLD only — missing from NEW
9DFF7DE2BEEF2ED5	In OLD only — missing from NEW
A02051EB2F6D15FF	In OLD only — missing from NEW
A4CA3F88674021D5	In OLD only — missing from NEW
A88F8E60E2955933	In OLD only — missing from NEW
A8A4F2A75B89F14A	In OLD only — missing from NEW
AA72E3EC52636D65	In OLD only — missing from NEW
BF65A6A51659DD72	In OLD only — missing from NEW
C6414ECEA05E058B	In OLD only — missing from NEW
D0FD5509699E9637	In OLD only — missing from NEW
DB2D99C7D41DCA2A	In OLD only — missing from NEW
DF9985D0CD4A225D	In OLD only — missing from NEW
DFCED33C7BAAB78C	In OLD only — missing from NEW
E3453985B796597F	In OLD only — missing from NEW
EBBD406373A3C2BB	In OLD only — missing from NEW
ED7262BAD00A88FF	In OLD only — missing from NEW
F1F649F3D5557646	In OLD only — missing from NEW
F7F4FE76862C97FF	In OLD only — missing from NEW
FC37336D2EDDBDF6	In OLD only — missing from NEW
FC74016B33AEF839	In OLD only — missing from NEW
FEDF8BC8D3FB7E2F	In OLD only — missing from NEW

*/

/*
 Q5 -Query to see if the state changed for any of the beneficiary between new and old systems which could affect their plans 

*/

SELECT
    o.SP_STATE_CODE                               AS old_state,
    n.SP_STATE_CODE                               AS new_state,
    COUNT(*)                                      AS affected_beneficiaries
FROM Beneficiary_Summary_2008 o
JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID
WHERE o.SP_STATE_CODE IS DISTINCT FROM n.SP_STATE_CODE
GROUP BY o.SP_STATE_CODE, n.SP_STATE_CODE
ORDER BY affected_beneficiaries DESC;

SELECT
    o.SP_STATE_CODE                               AS old_state,
    n.SP_STATE_CODE                               AS new_state,
    COUNT(*)                                      AS affected_beneficiaries
FROM Beneficiary_Summary_2009 o
JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID
WHERE o.SP_STATE_CODE IS DISTINCT FROM n.SP_STATE_CODE
GROUP BY o.SP_STATE_CODE, n.SP_STATE_CODE
ORDER BY affected_beneficiaries DESC;


SELECT
    o.SP_STATE_CODE                               AS old_state,
    n.SP_STATE_CODE                               AS new_state,
    COUNT(*)                                      AS affected_beneficiaries
FROM Beneficiary_Summary_2010 o
JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID
WHERE o.SP_STATE_CODE IS DISTINCT FROM n.SP_STATE_CODE
GROUP BY o.SP_STATE_CODE, n.SP_STATE_CODE
ORDER BY affected_beneficiaries DESC;

-- No records were found so the state has been mapped correctly for all beneficiaries 



/*
Q6 - 2008 - Query to see how many people had discrepancy in coverage between old and new systems
*/

Select  o.DESYNPUF_ID , cast(o.BENE_HI_CVRAGE_TOT_MONS as int) - cast( n.BENE_HI_CVRAGE_TOT_MONS as int) as "Coverage Diff "
FROM Beneficiary_Summary_2008 o JOIN Beneficiary_Summary_2008_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID
WHERE o.BENE_HI_CVRAGE_TOT_MONS IS DISTINCT FROM n.BENE_HI_CVRAGE_TOT_MONS

/*
Records were found which potentially indicated that some beneficiaries have lost coverage in the new system.
This could have a huge impact on the beneficiaries with chronic conditions

DESYNPUF_ID		Coverage Diff 
0A663E2959431944	1
207857173CB38E92	1
290C22DDD2B1AA51	1
3D90B3F036D37B45	3
4138267CE8E8FDE3	3
779BFC838663F2ED	1
E8452BD364913C3E	3
F5D4C42738D08E7E	3
*/

/*
Repeating the above query for 2009 
*
Select  o.DESYNPUF_ID , cast(o.BENE_HI_CVRAGE_TOT_MONS as int) - cast( n.BENE_HI_CVRAGE_TOT_MONS as int) as "Coverage Diff "
FROM Beneficiary_Summary_2009 o JOIN Beneficiary_Summary_2009_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID
WHERE o.BENE_HI_CVRAGE_TOT_MONS IS DISTINCT FROM n.BENE_HI_CVRAGE_TOT_MONS

/*
Records were found which potentially indicated that some beneficiaries have lost coverage in the new system.
This could have a huge impact on the beneficiaries with chronic conditions

DESYNPUF_ID		Coverage Diff 
0D21CE92E478B806	1
343795A9160A12D2	1
41CDF0F613BB81F8	3
628E1DCD6B702B00	3
8B0D58254B028CFC	2
BF3CB4A31E682460	1
C3FFD9AF3719D2CF	1
DB2819DE25B8F59A	1
E6F6893D38FFA3B2	3
EE228A74B8E40FEE	2
FAFB78273528874C	1
FFE4C8E6586D2865	3
*

/*
Repeating the above query for 2010
*/

Select  o.DESYNPUF_ID , cast(o.BENE_HI_CVRAGE_TOT_MONS as int) - cast( n.BENE_HI_CVRAGE_TOT_MONS as int) as "Coverage Diff "
FROM Beneficiary_Summary_2010 o JOIN Beneficiary_Summary_2010_New n ON o.DESYNPUF_ID = n.DESYNPUF_ID
WHERE o.BENE_HI_CVRAGE_TOT_MONS IS DISTINCT FROM n.BENE_HI_CVRAGE_TOT_MONS

/*
Records were found which potentially indicated that some beneficiaries have lost coverage in the new system.
This could have a huge impact on the beneficiaries with chronic conditions

DESYNPUF_ID		Coverage Diff 
0E27CE6CEA69BBD1	-1
1C52E198AA13E8AD	3
42B630B760699B3E	1
511BA3F7D1C1E6B3	1
88C62F685B8846E5	1
BB63D48879FD586E	3
BDB79AF5757542E2	1
BE0ADB121984AFC4	2
C9E6221894E1CE9B	2
*/ 

-- Looking at the discrepancies in Carrier files 1A and 1B between old and new systems 

/*
 Query to show how many claims were raised in a financial year and what was the amount paid for carries 1A old system
*/

SELECT
    Substr(Cast(clm_from_dt as Varchar),1,4) Claim_yr ,
	count(CLM_ID) Num_Claims,
	COUNT(DISTINCT DESYNPUF_ID) Benficiaries_CNT,
	SUM(COALESCE(LINE_NCH_PMT_AMT_1,0)+ COALESCE(LINE_NCH_PMT_AMT_2,0)+COALESCE(LINE_NCH_PMT_AMT_3,0)) pmt_amt
    from Carrier_Claims_Sample_1A 
 group by  Substr(Cast(clm_from_dt as Varchar),1,4) 

/*
The query gives us a concrete view of the system 

Claim_yr		Num_Claims. 		Benficiaries_CNT	pmt_amt			
2008			857411			42595			66032260
2009			929932			45772			73682590
2010			583324			42973			46384990
*/


/*
 Query to show how many claims were raised in a financial year and what was the amount paid for carries 1B old system
*/
SELECT
    Substr(Cast(clm_from_dt as Varchar),1,4) Claim_yr ,
	count(CLM_ID) Num_Claims,
	COUNT(DISTINCT DESYNPUF_ID) Benficiaries_CNT,
	SUM(COALESCE(LINE_NCH_PMT_AMT_1,0)+ COALESCE(LINE_NCH_PMT_AMT_2,0)+COALESCE(LINE_NCH_PMT_AMT_3,0)) pmt_amt
    from Carrier_Claims_Sample_1B 
 group by  Substr(Cast(clm_from_dt as Varchar),1,4) 

/*
The query gives us a concrete view of the system 
Claim_yr		Num_Claims. 		Benficiaries_CNT	pmt_amt	
2008			857991			42700			65992300
2010			579636			42880			45871420
2009			933041			45818			74336200
*/

/*
Query to show how many claims were raised in a financial year and what was the amount paid for carries 1A New system
*/
SELECT
    Substr(Cast(clm_from_dt as Varchar),1,4) Claim_yr ,
	count(CLM_ID) Num_Claims,
	COUNT(DISTINCT DESYNPUF_ID) Benficiaries_CNT,
	SUM(COALESCE(LINE_NCH_PMT_AMT_1,0)+ COALESCE(LINE_NCH_PMT_AMT_2,0)+COALESCE(LINE_NCH_PMT_AMT_3,0)) pmt_amt
    from Carrier_Claims_Sample_1A_New 
 group by  Substr(Cast(clm_from_dt as Varchar),1,4) 

/*
Claim_yr		Num_Claims. 		Benficiaries_CNT	pmt_amt	
2008			858122			43402			66317534.88
2023			236				235				20770.0
2009			930643			46553			73964836.55000001
2010			584065			43764			46688526.190000005
*/

/*
Query to show how many claims were raised in a financial year and what was the amount paid for carries 1B New system
*/
SELECT
    Substr(Cast(clm_from_dt as Varchar),1,4) Claim_yr ,
	count(CLM_ID) Num_Claims,
	COUNT(DISTINCT DESYNPUF_ID) Benficiaries_CNT,
	SUM(COALESCE(LINE_NCH_PMT_AMT_1,0)+ COALESCE(LINE_NCH_PMT_AMT_2,0)+COALESCE(LINE_NCH_PMT_AMT_3,0)) pmt_amt
    from Carrier_Claims_Sample_1B_New 
 group by  Substr(Cast(clm_from_dt as Varchar),1,4) 

/*
Claim_yr		Num_Claims. 		Benficiaries_CNT	pmt_amt	
2009			933742			46603			74611524.71
2010			580389			43680			46185346.48
2008			858686			43473			66268184.82
2023			229				229				17080.0
*/


/*
Q7 - Total Beneficiaries who didn’t have any claims for 2008 in both carrier files - old system 
*/

SELECT
    COUNT(DISTINCT b.DESYNPUF_ID) AS benes_with_no_claims_in_either_file
FROM Beneficiary_Summary_2008 b
LEFT JOIN Carrier_Claims_Sample_1A a ON b.DESYNPUF_ID = a.DESYNPUF_ID
LEFT JOIN Carrier_Claims_Sample_1B bfile ON b.DESYNPUF_ID = bfile.DESYNPUF_ID
WHERE a.DESYNPUF_ID IS NULL AND bfile.DESYNPUF_ID IS NULL;

/*
Total Beneficiaries who didn’t have any claims for 2008 in both carrier files - New system
*/
SELECT
    COUNT(DISTINCT b.DESYNPUF_ID) AS benes_with_no_claims_in_either_file
FROM Beneficiary_Summary_2008_New b
LEFT JOIN Carrier_Claims_Sample_1A_New a ON b.DESYNPUF_ID = a.DESYNPUF_ID
LEFT JOIN Carrier_Claims_Sample_1B_New bfile ON b.DESYNPUF_ID = bfile.DESYNPUF_ID
WHERE a.DESYNPUF_ID IS NULL AND bfile.DESYNPUF_ID IS NULL;

/*
Record count was same indicating that there was no discrepancy at the record level 
but however the ID's mismatch between the old and the new systems indicate that these 
could be potentially different beneficiaries
* /


--Repeating the above query for 2009 and 2010 years as well 

SELECT
    COUNT(DISTINCT b.DESYNPUF_ID) AS benes_with_no_claims_in_either_file
FROM Beneficiary_Summary_2009 b
LEFT JOIN Carrier_Claims_Sample_1A a ON b.DESYNPUF_ID = a.DESYNPUF_ID
LEFT JOIN Carrier_Claims_Sample_1B bfile ON b.DESYNPUF_ID = bfile.DESYNPUF_ID
WHERE a.DESYNPUF_ID IS NULL AND bfile.DESYNPUF_ID IS NULL;

/*
Total
16906
*/

SELECT
    COUNT(DISTINCT b.DESYNPUF_ID) AS benes_with_no_claims_in_either_file
FROM Beneficiary_Summary_2009_New b
LEFT JOIN Carrier_Claims_Sample_1A_New a ON b.DESYNPUF_ID = a.DESYNPUF_ID
LEFT JOIN Carrier_Claims_Sample_1B_New bfile ON b.DESYNPUF_ID = bfile.DESYNPUF_ID
WHERE a.DESYNPUF_ID IS NULL AND bfile.DESYNPUF_ID IS NULL;

/*
Total
16955

Record count is not the same indicating discrepancy that a few beneficiaries claim records are different
*/


SELECT
    COUNT(DISTINCT b.DESYNPUF_ID) AS benes_with_no_claims_in_either_file
FROM Beneficiary_Summary_2010 b
LEFT JOIN Carrier_Claims_Sample_1A a ON b.DESYNPUF_ID = a.DESYNPUF_ID
LEFT JOIN Carrier_Claims_Sample_1B bfile ON b.DESYNPUF_ID = bfile.DESYNPUF_ID
WHERE a.DESYNPUF_ID IS NULL AND bfile.DESYNPUF_ID IS NULL;

/*
TOTAL
 16507
*/


SELECT
    COUNT(DISTINCT b.DESYNPUF_ID) AS benes_with_no_claims_in_either_file
FROM Beneficiary_Summary_2010_New b
LEFT JOIN Carrier_Claims_Sample_1A_New a ON b.DESYNPUF_ID = a.DESYNPUF_ID
LEFT JOIN Carrier_Claims_Sample_1B_New bfile ON b.DESYNPUF_ID = bfile.DESYNPUF_ID
WHERE a.DESYNPUF_ID IS NULL AND bfile.DESYNPUF_ID IS NULL;

/*
TOTAL
16549
Record count is not the same indicating discrepancy that a few beneficiaries claim records are different
*/

/* 
Q8 - Showing the aggregated values for the entire carries table 1A from the old system 
*/

SELECT
    Substr(Cast(clm_from_dt as Varchar),1,4) Claim_yr ,
	count(CLM_ID) Num_Claims,
	COUNT(DISTINCT DESYNPUF_ID) Benficiaries_CNT,
	SUM(
	COALESCE(LINE_NCH_PMT_AMT_1,0)+ 
	COALESCE(LINE_NCH_PMT_AMT_2,0)+
	COALESCE(LINE_NCH_PMT_AMT_3,0)+
	COALESCE(LINE_NCH_PMT_AMT_4,0)+
	COALESCE(LINE_NCH_PMT_AMT_5,0)+
	COALESCE(LINE_NCH_PMT_AMT_6,0)+
	COALESCE(LINE_NCH_PMT_AMT_7,0)+
	COALESCE(LINE_NCH_PMT_AMT_8,0)+
	COALESCE(LINE_NCH_PMT_AMT_9,0)+
	COALESCE(LINE_NCH_PMT_AMT_10,0)+
	COALESCE(LINE_NCH_PMT_AMT_11,0)+
	COALESCE(LINE_NCH_PMT_AMT_12,0)+
	COALESCE(LINE_NCH_PMT_AMT_13,0)
	) ncH_pmt_amt,
	Sum(
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_1,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_2,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_3,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_4,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_5,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_6,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_7,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_8,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_9,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_10,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_11,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_12,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_13,0)
	)  Doc_bill_Amt,	
	Sum(
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_1,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_2,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_3,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_4,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_5,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_6,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_7,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_8,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_9,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_10,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_11,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_12,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_13,0)
	) Pri_pyr_paid,
	Sum(
	COALESCE(LINE_ALOWD_CHRG_AMT_1,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_2,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_3,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_4,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_5,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_6,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_7,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_8,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_9,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_10,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_11,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_12,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_13,0)
	) Allwd_Chrg_Amt
    from Carrier_Claims_Sample_1A 
 group by  Substr(Cast(clm_from_dt as Varchar),1,4) 

/*
Claim_yr		Num_Claims		Benficiaries_CNT		ncH_pmt_amt		Doc_bill_Amt			Pri_pyr_paid			Allwd_Chrg_Amt	
2008			857411			42595				73452850		3560890.0			1184320.0			94796630
2009			929932			45772				82274920		3820600.0			1321240.0			105979660
2010			583324			42973				51564290		2565830.0			814740.0			66561890

*/

--repeating for carrier file 1B
SELECT
    Substr(Cast(clm_from_dt as Varchar),1,4) Claim_yr ,
	count(CLM_ID) Num_Claims,
	COUNT(DISTINCT DESYNPUF_ID) Benficiaries_CNT,
	SUM(
	COALESCE(LINE_NCH_PMT_AMT_1,0)+ 
	COALESCE(LINE_NCH_PMT_AMT_2,0)+
	COALESCE(LINE_NCH_PMT_AMT_3,0)+
	COALESCE(LINE_NCH_PMT_AMT_4,0)+
	COALESCE(LINE_NCH_PMT_AMT_5,0)+
	COALESCE(LINE_NCH_PMT_AMT_6,0)+
	COALESCE(LINE_NCH_PMT_AMT_7,0)+
	COALESCE(LINE_NCH_PMT_AMT_8,0)+
	COALESCE(LINE_NCH_PMT_AMT_9,0)+
	COALESCE(LINE_NCH_PMT_AMT_10,0)+
	COALESCE(LINE_NCH_PMT_AMT_11,0)+
	COALESCE(LINE_NCH_PMT_AMT_12,0)+
	COALESCE(LINE_NCH_PMT_AMT_13,0)
	) ncH_pmt_amt,
	Sum(
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_1,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_2,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_3,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_4,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_5,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_6,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_7,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_8,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_9,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_10,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_11,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_12,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_13,0)
	)  Doc_bill_Amt,	
	Sum(
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_1,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_2,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_3,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_4,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_5,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_6,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_7,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_8,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_9,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_10,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_11,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_12,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_13,0)
	) Pri_pyr_paid,
	Sum(
	COALESCE(LINE_ALOWD_CHRG_AMT_1,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_2,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_3,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_4,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_5,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_6,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_7,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_8,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_9,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_10,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_11,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_12,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_13,0)
	) Allwd_Chrg_Amt
    from Carrier_Claims_Sample_1B 
 group by  Substr(Cast(clm_from_dt as Varchar),1,4) 

/*
Claim_yr		Num_Claims		Benficiaries_CNT		ncH_pmt_amt		Doc_bill_Amt			Pri_pyr_paid			Allwd_Chrg_Amt	
2008			857991			42700				73339070		3570290.0			1160850.0			94548570
2010			579636			42880				51038000		2559760.0			768560.0			65922690
2009			933041			45818				82934560		3792260.0			1325240.0			106776450
*/


--Repeating the query for New system Carries files claim 1A
SELECT
    Substr(Cast(clm_from_dt as Varchar),1,4) Claim_yr ,
	count(CLM_ID) Num_Claims,
	COUNT(DISTINCT DESYNPUF_ID) Benficiaries_CNT,
	SUM(
	COALESCE(LINE_NCH_PMT_AMT_1,0)+ 
	COALESCE(LINE_NCH_PMT_AMT_2,0)+
	COALESCE(LINE_NCH_PMT_AMT_3,0)+
	COALESCE(LINE_NCH_PMT_AMT_4,0)+
	COALESCE(LINE_NCH_PMT_AMT_5,0)+
	COALESCE(LINE_NCH_PMT_AMT_6,0)+
	COALESCE(LINE_NCH_PMT_AMT_7,0)+
	COALESCE(LINE_NCH_PMT_AMT_8,0)+
	COALESCE(LINE_NCH_PMT_AMT_9,0)+
	COALESCE(LINE_NCH_PMT_AMT_10,0)+
	COALESCE(LINE_NCH_PMT_AMT_11,0)+
	COALESCE(LINE_NCH_PMT_AMT_12,0)+
	COALESCE(LINE_NCH_PMT_AMT_13,0)
	) ncH_pmt_amt,
	Sum(
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_1,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_2,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_3,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_4,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_5,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_6,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_7,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_8,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_9,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_10,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_11,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_12,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_13,0)
	)  Doc_bill_Amt,	
	Sum(
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_1,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_2,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_3,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_4,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_5,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_6,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_7,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_8,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_9,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_10,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_11,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_12,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_13,0)
	) Pri_pyr_paid,
	Sum(
	COALESCE(LINE_ALOWD_CHRG_AMT_1,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_2,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_3,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_4,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_5,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_6,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_7,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_8,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_9,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_10,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_11,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_12,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_13,0)
	) Allwd_Chrg_Amt
    from Carrier_Claims_Sample_1B_New 
 group by  Substr(Cast(clm_from_dt as Varchar),1,4) 

/*
Following results show that there is a data type mismatch between the old and the new systems
Also a potential new year 2023 was introduced which basically indicates that the mapping or substringing the field was in correct

Claim_yr		Num_Claims		Benficiaries_CNT		ncH_pmt_amt	Doc_bill_Amt		Pri_pyr_paid		Allwd_Chrg_Amt	
2008			858686			43473				73677212.12	3977038.829999999	1563947.6099999999	94900571.73999998
2023			229				229					21720.0		1230.0			80.0				27690.0
2009			933742			46603				83250114.48	4187444.9799999995	1731739.86		107120682.50999999
2010			580389			43680				51418665.06	2986750.01		1203111.6099999999	66300738.029999994
*/

-- Repeating the above for carrier file 1B from the new system 
SELECT
    Substr(Cast(clm_from_dt as Varchar),1,4) Claim_yr ,
	count(CLM_ID) Num_Claims,
	COUNT(DISTINCT DESYNPUF_ID) Benficiaries_CNT,
	SUM(
	COALESCE(LINE_NCH_PMT_AMT_1,0)+ 
	COALESCE(LINE_NCH_PMT_AMT_2,0)+
	COALESCE(LINE_NCH_PMT_AMT_3,0)+
	COALESCE(LINE_NCH_PMT_AMT_4,0)+
	COALESCE(LINE_NCH_PMT_AMT_5,0)+
	COALESCE(LINE_NCH_PMT_AMT_6,0)+
	COALESCE(LINE_NCH_PMT_AMT_7,0)+
	COALESCE(LINE_NCH_PMT_AMT_8,0)+
	COALESCE(LINE_NCH_PMT_AMT_9,0)+
	COALESCE(LINE_NCH_PMT_AMT_10,0)+
	COALESCE(LINE_NCH_PMT_AMT_11,0)+
	COALESCE(LINE_NCH_PMT_AMT_12,0)+
	COALESCE(LINE_NCH_PMT_AMT_13,0)
	) ncH_pmt_amt,
	Sum(
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_1,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_2,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_3,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_4,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_5,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_6,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_7,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_8,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_9,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_10,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_11,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_12,0)+
	COALESCE(LINE_BENE_PTB_DDCTBL_AMT_13,0)
	)  Doc_bill_Amt,	
	Sum(
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_1,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_2,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_3,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_4,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_5,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_6,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_7,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_8,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_9,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_10,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_11,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_12,0)+
	COALESCE(LINE_BENE_PRMRY_PYR_PD_AMT_13,0)
	) Pri_pyr_paid,
	Sum(
	COALESCE(LINE_ALOWD_CHRG_AMT_1,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_2,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_3,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_4,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_5,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_6,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_7,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_8,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_9,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_10,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_11,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_12,0)+
	COALESCE(LINE_ALOWD_CHRG_AMT_13,0)
	) Allwd_Chrg_Amt
    from Carrier_Claims_Sample_1B_New 
 group by  Substr(Cast(clm_from_dt as Varchar),1,4) 

/*
Following results show that there is a data type mismatch between the old and the new systems
Also a potential new year 2023 was introduced which basically indicates that the mapping or substringing the field was in correct

Claim_yr		Num_Claims		Benficiaries_CNT		ncH_pmt_amt		Doc_bill_Amt		Pri_pyr_paid		Allwd_Chrg_Amt	
2008			858686			43473				73677212.11999999	3977038.829999999	1563947.61		94900571.74
2023			229			229				21720.0			1230.0			80.0			27690.0
2009			933742			46603				83250114.48000002	4187444.98		1731739.8599999999	107120682.50999998
2010			580389			43680				51418665.06000001	2986750.0100000002	1203111.6099999999	66300738.03000001

*/

