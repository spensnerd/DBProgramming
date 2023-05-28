-- ======================================================================
--  Name:    create_tolkien.sql
--  Author:  
--  Date:    
-- ------------------------------------------------------------------
--  Purpose: Prepare final project environment.
-- ======================================================================

/* Set environment variables. */
SET SERVEROUTPUT ON SIZE UNLIMITED
SET VERIFY OFF
SET DEFINE ON
SET PAGESIZE 999

/* Write to log file. */
SPOOL create_tolkien.txt

/* Drop the tolkien table. */
DROP TABLE tolkien FORCE;

/* Create the tolkien table. */
CREATE TABLE tolkien
( tolkien_id NUMBER
, tolkien_character base_t);

/* Drop and create a tolkien_s sequence. */
DROP SEQUENCE tolkien_s;
CREATE SEQUENCE tolkien_s START WITH 1001;

/* Close log file. */
SPOOL OFF

/* Exit the connection. */
QUIT
