/*
||  Name:          apply_plsql_lab12.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 13 lab.
*/

SET SERVEROUTPUT ON

-- Call seeding libraries.
@/home/student/data/cit325/lib/cleanup_oracle.sql
@/home/student/data/cit325/lib/oracle12cplsqlcode/introduction/create_video_store.sql

-- Open log file.
SPOOL apply_plsql_lab12.txt

/* PART 1:  Create the item_obj object type, a item_tab collection object type, and item_list function. */
BEGIN
    dbms_output.put_line('==============================');
    dbms_output.put_line('           Part 1             ');
    dbms_output.put_line('==============================');
END;
/


-- Drop tables, types, and sequence
--DROP TYPE item_tab;
-- DROP TYPE item_obj;

-- Create item_obj
CREATE OR REPLACE
  TYPE item_obj IS OBJECT
  ( title               VARCHAR2(60)
  , subtitle            VARCHAR2(60)
  , rating              VARCHAR2(8)
  , release_date        DATE );
/

-- Display item_obj
desc item_obj

-- Create item_tab
CREATE OR REPLACE
  TYPE item_tab IS TABLE of item_obj;
/

-- Display tem_tab
desc item_tab

-- Create item_list 
CREATE OR REPLACE
  FUNCTION item_list
  ( pv_start_date  DATE
  , pv_end_date    DATE DEFAULT TRUNC(SYSDATE) + 1) RETURN item_tab IS
 
    /* Declare a record type. */
    TYPE item_rec IS RECORD
    ( title             VARCHAR2(60)
    , subtitle          VARCHAR2(60)
    , rating            VARCHAR2(8)
    , release_date      DATE );
 
    /* Declare reference cursor for an NDS cursor. */
    item_cursor   SYS_REFCURSOR;
 
    /* Declare a item row for output from an NDS cursor. */
    item_row      ITEM_REC;
    item_set      ITEM_TAB := item_tab();
 
    /* Declare dynamic statement. */
    stmt  VARCHAR2(2000);
  BEGIN
    /* Create a dynamic statement. */
    stmt := 'SELECT     i.item_title AS title'||CHR(10)
         || ',          i.item_subtitle AS subtitle'||CHR(10)
         || ',          i.item_rating AS rating'||CHR(10)
         || ',          i.item_release_date AS release_date'||CHR(10)
         || 'FROM       item i'||CHR(10)
         || 'WHERE      i.item_rating_agency = ''MPAA'''||CHR(10)
         || 'AND        i.item_release_date BETWEEN :start_date AND :end_date';
 
  $IF $$DEBUG = 1 $THEN
    dbms_output.put_line(stmt);
  $END

    /* Open and read dynamic cursor. */
    OPEN item_cursor FOR stmt USING pv_start_date, pv_end_date;
    LOOP
      /* Fetch the cursror into a item row. */
      FETCH item_cursor INTO item_row;
      EXIT WHEN item_cursor%NOTFOUND;
 
      /* Extend space and assign a value collection. */      
      item_set.EXTEND;
      item_set(item_set.COUNT) :=
        item_obj( title         => item_row.title
                , subtitle      => item_row.subtitle
                , rating        => item_row.rating 
                , release_date  => item_row.release_date );
    END LOOP;
 
    /* Return item set. */
    RETURN item_set;
  END item_list;
/

-- Display item_list function:
desc item_list

-- ----------------------------------------------------------------------
-- Test Case #1
BEGIN
    dbms_output.put_line('==============================');
    dbms_output.put_line('        Test Case #1          ');
    dbms_output.put_line('==============================');
END;
/
-- ----------------------------------------------------------------------

SELECT il.title
,      il.rating
FROM   TABLE(item_list(TO_DATE('01-JAN-2000'))) il;

-- ----------------------------------------------------------------------

SPOOL OFF;

EXIT;