-- ======================================================================
--  Name:    base_t.sql
--  Author:  Spencer Griffin
--  Date:    
-- ------------------------------------------------------------------
--  Purpose: Prepare final project environment.
-- ======================================================================

-- Open log file.
SPOOL base_t.txt

-- Add an environment command to allow PL/SQL to print to console.

SET SERVEROUTPUT ON SIZE UNLIMITED

SET VERIFY OFF

SET DEFINE ON

SET PAGESIZE 999

-- Dropping object from previous lab

DROP TYPE base_t FORCE;
DROP TYPE elf_t FORCE;

CREATE OR REPLACE TYPE base_t IS OBJECT 
    ( oid     NUMBER
    , oname   VARCHAR2(30)
    , CONSTRUCTOR FUNCTION base_t 
        ( oid     NUMBER
        , oname   VARCHAR2 DEFAULT 'BASE_T') RETURN SELF AS RESULT
    , MEMBER FUNCTION get_oname RETURN VARCHAR2
    , MEMBER PROCEDURE set_oname (oname VARCHAR2),
    MEMBER FUNCTION get_name RETURN VARCHAR2
    , MEMBER FUNCTION to_string RETURN VARCHAR2 ) 
    INSTANTIABLE NOT FINAL;
/

-- base_t Body
CREATE OR REPLACE TYPE BODY base_t IS
  -- Implement a default constructor.
    CONSTRUCTOR FUNCTION base_t 
    ( oid     NUMBER
    , oname   VARCHAR2 DEFAULT 'BASE_T' ) RETURN SELF AS RESULT IS
    BEGIN
        self.oid := oid;
        self.oname := oname;
        return;
    END base_t;
 
  -- Implement a get_oname function.
    MEMBER FUNCTION get_oname 
    RETURN VARCHAR2 IS
    BEGIN
        RETURN self.oname;
    END get_oname;
 
  -- Implement a set_oname procedure.
    MEMBER PROCEDURE set_oname ( oname VARCHAR2) IS
    BEGIN
        self.oname := oname;
    END set_oname;
 
  -- Implement a get_name function.
    MEMBER FUNCTION get_name 
    RETURN VARCHAR2 IS
    BEGIN
        RETURN NULL;
    END get_name;

  -- Implement a to_string function.

    MEMBER FUNCTION to_string 
    RETURN VARCHAR2 IS
    BEGIN
        RETURN '['|| self.oid|| ']';
    END to_string;
END;
/
-- Close your log file.
SPOOL OFF

QUIT;