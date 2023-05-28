/*
||  Name:          apply_plsql_lab5.sql
||  Date:          October 17, 2020
||  Purpose:       Complete 325 Chapter 5 lab.
*/

-- Call seeding libraries.
@/home/student/Data/cit325/lib/cleanup_oracle.sql
@/home/student/Data/cit325/lib/Oracle12cPLSQLCode/Introduction/create_video_store.sql

-- Open log file.
SPOOL apply_plsql_lab5.txt

ALTER TABLE item
    ADD rating_agency_id    NUMBER;

-- Drop sequence in case it exists already.   
DROP SEQUENCE rating_agency_s;

-- Create sequence anew, like a phoenix rising from the ashes.
CREATE SEQUENCE rating_agency_s START WITH 1001;

-- Create the rating agency table.
CREATE TABLE rating_agency AS
  SELECT rating_agency_s.NEXTVAL AS rating_agency_id
  ,      il.item_rating AS rating
  ,      il.item_rating_agency AS rating_agency
  FROM  (SELECT DISTINCT
                i.item_rating
         ,      i.item_rating_agency
         FROM   item i) il;
SET NULL ''
COLUMN table_name   FORMAT A18
COLUMN column_id    FORMAT 9999
COLUMN column_name  FORMAT A22
COLUMN data_type    FORMAT A12
SELECT   table_name
,        column_id
,        column_name
,        CASE
           WHEN nullable = 'N' THEN 'NOT NULL'
           ELSE ''
         END AS nullable
,        CASE
           WHEN data_type IN ('CHAR','VARCHAR2','NUMBER') THEN
             data_type||'('||data_length||')'
           ELSE
             data_type
         END AS data_type
FROM     user_tab_columns
WHERE    table_name = 'ITEM'
ORDER BY 2;

SELECT * FROM rating_agency;


CREATE OR REPLACE
    TYPE c_ratings IS OBJECT
    ( rating_agency_id     NUMBER
    , rating               VARCHAR2(8)
    , rating_agency        VARCHAR2(4));
/

CREATE OR REPLACE
    TYPE c_ratings_list IS TABLE OF c_ratings; 
/

DECLARE
    lv_rating_agency_id     NUMBER;
    lv_rating               VARCHAR2(8);    
    lv_rating_agency        VARCHAR2(4);

    CURSOR c IS
        SELECT  i.rating_agency_id 
        ,       i.rating
        ,       i.rating_agency 
        FROM    rating_agency i;

    lv_c_ratings_list C_RATINGS_LIST := c_ratings_list();

BEGIN

    FOR i IN c LOOP
        lv_c_ratings_list.EXTEND;
        lv_c_ratings_list(lv_c_ratings_list.COUNT) := c_ratings( lv_rating_agency_id
                                                               , lv_rating
                                                               , lv_rating_agency);

        UPDATE item
        SET rating_agency_id = i.rating_agency_id
        WHERE item_rating = i.rating AND item_rating_agency = i.rating_agency;
    END LOOP;
    COMMIT;
END;
/

SELECT   rating_agency_id
,        COUNT(*)
FROM     item
WHERE    rating_agency_id IS NOT NULL
GROUP BY rating_agency_id
ORDER BY 1;

-- Close log file.
SPOOL OFF
