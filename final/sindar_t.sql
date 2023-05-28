-- Open your log file and make sure the extension is ".log".
SPOOL sindar_t.txt

-- Add an environment command to allow PL/SQL to print to console.
SET SERVEROUTPUT ON SIZE UNLIMITED
SET VERIFY OFF
SET DEFINE ON

-- Dropping object from previous lab
DROP TYPE sindar_t FORCE;

--===========================================
-- 		Create sindar_t object
--=========================================== 
CREATE OR REPLACE TYPE sindar_t UNDER elf_t
  ( elfkind  VARCHAR2(30)
  , CONSTRUCTOR FUNCTION sindar_t
    ( name       VARCHAR2
    , genus      VARCHAR2 DEFAULT 'Elves'
    , elfkind    VARCHAR2 DEFAULT 'sindar' ) RETURN SELF AS RESULT
  , MEMBER FUNCTION get_elfkind RETURN VARCHAR2
  , MEMBER PROCEDURE set_elfkind (elfkind VARCHAR2)
  , OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2 )
  INSTANTIABLE NOT FINAL;
/

--===========================================
-- 		Create sindar_t Body
--=========================================== 
CREATE OR REPLACE TYPE BODY sindar_t IS
  -- Implement a default constructor.
  CONSTRUCTOR FUNCTION sindar_t
    ( name       VARCHAR2
    , genus      VARCHAR2 DEFAULT 'Elves'
    , elfkind    VARCHAR2 DEFAULT 'sindar' ) RETURN SELF AS RESULT IS
  BEGIN
    self.oid := tolkien_s.CURRVAL-1000;
    self.name    := name;
    self.genus   := genus;
    self.oname   := 'Elf';
    self.elfkind := elfkind;
    RETURN;
  END sindar_t;
 
  -- Implement a get_elfkind function.
  MEMBER FUNCTION get_elfkind
  RETURN VARCHAR2 IS
  BEGIN
    RETURN self.elfkind;
  END get_elfkind;

  -- Implement a set_elfkind procedure.
  MEMBER PROCEDURE set_elfkind (elfkind VARCHAR2) IS
  BEGIN
    self.elfkind := elfkind;
  END set_elfkind;
  
  -- Implement an overriding to_string function with generalized invocation.
  OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2 IS
  BEGIN
    RETURN (self AS elf_t).to_string||'['||self.elfkind||']';
  END to_string;
END;
/

-- Close log file.
SPOOL OFF
 
QUIT;               