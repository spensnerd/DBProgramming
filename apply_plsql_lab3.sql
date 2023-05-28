/*
||  Name:          apply_plsql_lab3.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 4 lab.
*/

-- Call seeding libraries.
@$LIB/cleanup_oracle.sql
@$LIB/Oracle12cPLSQLCode/Introduction/create_video_store.sql

-- Open log file.


DECLARE
 TYPE three_type IS RECORD
( xnum NUMBER
 ,xdate DATE
 ,xstring VARCHAR2(30));

info three_type;

Type LIST is table of VARCHAR(100);

lv_strings LIST := list ('','','');
BEGIN
lv_strings(1) := '&1';
lv_strings(2) := '&2';
lv_strings(3) := '&3';

  /* Loop through list of values to find only the numbers. */
  FOR i IN 1..lv_strings.COUNT LOOP
    IF REGEXP_LIKE(lv_strings(i),'^[[:digit:]]*$') 
               THEN info.xnum := lv_strings(i);
        ELSIF
       verify_date(lv_strings(i)) IS NOT NULL 
               THEN info.xdate := lv_strings(i);
        ELSIF
       REGEXP_LIKE(lv_strings(i),'^[[:alnum:]]*$') 
               THEN info.xstring := lv_strings(i);
    END IF;
  END LOOP;

dbms_output.put_line('['|| info.xnum || '] ' || '['|| info.xstring || '] ' || '['|| info.xdate || ']');
END; 
/


QUIT;

-- Close log file.
SPOOL OFF
