-- This is a sample file, and you should display a multiple-line comment
-- identifying the file, author, and date. Here's the format:
/*
   Name:   rerunnable1.sql
   Author: Spencer Griffin
   Date:   03-Oct-2020
*/

-- Put code that you call from other scripts here because they may create
-- their own log files. For example, you call other program scripts by
-- putting an "@" symbol before the name of a relative file name or a
-- fully qualified file name.


-- Open your log file and make sure the extension is ".txt".
-- ------------------------------------------------------------
-- Remove any spool filename and spool off command when you call
-- the script from a shell script.
-- ------------------------------------------------------------
SPOOL rerunnable.txt

-- Add an environment command to allow PL/SQL to print to console.
SET SERVEROUTPUT ON SIZE UNLIMITED
SET VERIFY OFF

DECLARE

lv_raw_input VARCHAR2(100);
lv_input VARCHAR2(20);

-- Put your code here, like this "Hello Whom!" program.

BEGIN
    lv_raw_input := '&input';
    
    lv_input := SUBSTR(lv_raw_input,1,10);
    
    dbms_output.put_line('['||lv_raw_input||']');
    
    IF (LENGTH(Lv_raw_input) <= 10)
    THEN dbms_output.put_line('Hello ' ||lv_raw_input||'!');
    
    ELSIF (LENGTH(lv_raw_input) >10)
    THEN dbms_output.put_line('Hello '||lv_input||'!');
    
    ELSE dbms_output.put_line('Hello World!');
        END IF;
END;
/

-- Close your log file.
-- ------------------------------------------------------------
-- Remove any spool filename and spool off command when you call
-- the script from a shell script.
-- ------------------------------------------------------------
SPOOL OFF

-- Instruct the program to exit SQL*Plus, which you need when you call a
-- a program from the command line. Please make sure you comment the
-- following command when you want to remain inside the interactive
-- SQL*Plus connection.
QUIT;