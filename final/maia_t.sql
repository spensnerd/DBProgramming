/*===============================================================
   Name:   maia_t.sql
   Author: Ricardo Ledesma
   Date:   03-30-18
===============================================================*/
-- Open your log file and make sure the extension is ".log".
SPOOL maia_t.txt

-- Add an environment command to allow PL/SQL to print to console.

SET SERVEROUTPUT ON SIZE UNLIMITED

SET VERIFY OFF

SET DEFINE ON

-- Dropping object from previous lab

DROP TYPE maia_t FORCE;

--===========================================
-- 		Create maia_t object
--=========================================== 

CREATE OR REPLACE TYPE maia_t UNDER base_t (
    name    VARCHAR2(30),
    genus   VARCHAR2(30),
    CONSTRUCTOR FUNCTION maia_t (
           name    VARCHAR2,
           genus   VARCHAR2 DEFAULT 'Maiar'
       ) RETURN SELF AS RESULT,
    OVERRIDING MEMBER FUNCTION get_name RETURN VARCHAR2,
    MEMBER FUNCTION get_genus RETURN VARCHAR2,
    MEMBER PROCEDURE set_genus (
           genus VARCHAR2
       ),
    OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2
) INSTANTIABLE NOT FINAL;
/

--===========================================
-- 		Create maia_t Body
--=========================================== 

CREATE OR REPLACE TYPE BODY maia_t IS
  -- Implement a default constructor.
    CONSTRUCTOR FUNCTION maia_t (
        name    VARCHAR2,
        genus   VARCHAR2 DEFAULT 'Maiar'
    ) RETURN SELF AS RESULT IS
    BEGIN
        self.oid := tolkien_s.currval - 1000;
        self.name := name;
        self.genus := genus;
        self.oname := 'Maia';
        return;
    END maia_t;
 
  -- Override the get_name function.

OVERRIDING
    MEMBER FUNCTION get_name RETURN VARCHAR2 IS
    BEGIN
        RETURN self.name;
    END get_name;

  -- Implement a get_genus function.

    MEMBER FUNCTION get_genus RETURN VARCHAR2 IS
    BEGIN
        RETURN self.genus;
    END get_genus;

  -- Implement a set_genus procedure.

    MEMBER PROCEDURE set_genus (
        genus VARCHAR2
    ) IS
    BEGIN
        self.genus := genus;
    END set_genus;
  
  -- Implement an overriding to_string function with generalized invocation.

OVERRIDING
    MEMBER FUNCTION to_string RETURN VARCHAR2 IS
    BEGIN
        RETURN ( self AS base_t ).to_string
               || '['
               || self.name
               || ']['
               || self.genus
               || ']';
    END to_string;

END;
/

-- Close log file.

SPOOL OFF

quit;