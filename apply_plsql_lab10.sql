/*
||  Name:          apply_plsql_lab10.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 11 lab.
*/

-- Open log file.
SPOOL apply_plsql_lab10.txt

DROP TABLE logger;
DROP SEQUENCE logger_s;
DROP TYPE item_t FORCE;
DROP TYPE contact_t FORCE;
DROP TYPE base_t FORCE;

-- Create a base_t object type that maps to the following definition. 
CREATE OR REPLACE TYPE base_t IS OBJECT
  ( oname VARCHAR2(30)
  , name  VARCHAR2(30)
  , CONSTRUCTOR FUNCTION base_t RETURN SELF AS RESULT
  , CONSTRUCTOR FUNCTION base_t
    ( oname  VARCHAR2
    , name   VARCHAR2 ) RETURN SELF AS RESULT
  , MEMBER FUNCTION get_name RETURN VARCHAR2
  , MEMBER FUNCTION get_oname RETURN VARCHAR2
  , MEMBER PROCEDURE set_oname (oname VARCHAR2)
  , MEMBER FUNCTION to_string RETURN VARCHAR2)
  INSTANTIABLE NOT FINAL;
/

-- Display the result by using the following
DESC base_t

-- Logger table creation
CREATE TABLE logger
(
      logger_id   NUMBER
    , log_text    BASE_T
);

-- making logger sqquence.
CREATE SEQUENCE logger_s;

-- verify logger creation.
DESC logger;

-- base_t object
CREATE OR REPLACE TYPE BODY base_t IS
    CONSTRUCTOR FUNCTION base_t RETURN SELF AS RESULT IS
    BEGIN
        self.oname := 'BASE_T';
    RETURN;
    END;
    
    CONSTRUCTOR FUNCTION base_t
    (
          oname   VARCHAR2
        , name    VARCHAR2
    ) RETURN SELF AS RESULT IS
    BEGIN
    -- ASSIGN A VALUE TO ONAME
    self.oname := oname;
    -- VALUE OR NULL?
    IF name IS NOT NULL AND name IN ('NEW' , 'OLD') THEN
        self.name := name;
    END IF;
    RETURN;
    END;
    
-- get name function
  MEMBER FUNCTION get_name RETURN VARCHAR2 IS
    BEGIN
        RETURN self.name;
    END get_name;
    
-- get oname function
 MEMBER FUNCTION get_oname RETURN VARCHAR2 IS
    BEGIN
        RETURN self.oname;
    END get_oname;
    
-- set oname function
MEMBER PROCEDURE set_oname
    (
        oname VARCHAR2
    ) IS
    BEGIN
        self.oname := oname;
    END set_oname;
    
-- convert string.
MEMBER FUNCTION to_string RETURN VARCHAR2 IS
    BEGIN
        RETURN '['||self.oname||']';
    END to_string;
END;
/

-- Test case 1.
DECLARE
  /* Create a default instance of the object type. */
  lv_instance  BASE_T := base_t();
BEGIN
  /* Print the default value of the oname attribute. */
  dbms_output.put_line('Default  : ['||lv_instance.get_oname()||']');

  /* Set the oname value to a new value. */
  lv_instance.set_oname('SUBSTITUTE');

  /* Print the default value of the oname attribute. */
  dbms_output.put_line('Override : ['||lv_instance.get_oname()||']');
END;
/

-- insert base_t object instance no parameter construction
INSERT INTO logger
VALUES (logger_s.NEXTVAL, base_t());

-- Insert a base_t object instance parameter-driven constructor
DECLARE
  /* Declare a variable of the UDT type. */
  lv_base  BASE_T;
BEGIN
  /* Assign an instance of the variable. */
  lv_base := base_t(
      oname => 'BASE_T'
    , name => 'NEW' );

    /* Insert instance of the base_t object type into table. */
    INSERT INTO logger
    VALUES (logger_s.NEXTVAL, lv_base);

    /* Commit the record. */
    COMMIT;
END;
/

-- Generic query.
COLUMN oname     FORMAT A20
COLUMN get_name  FORMAT A20
COLUMN to_string FORMAT A20
SELECT t.logger_id
,      t.log.oname AS oname
,      NVL(t.log.get_name(),'Unset') AS get_name
,      t.log.to_string() AS to_string
FROM  (SELECT l.logger_id
       ,      TREAT(l.log_text AS base_t) AS log
       FROM   logger l) t
WHERE  t.log.oname = 'BASE_T';

-- Part 2, the Empire strikes back.

-- item_t subtype.
CREATE OR REPLACE
  TYPE item_t UNDER base_t
  ( ITEM_ID NUMBER
  , ITEM_BARCODE    VARCHAR2(20)
  , ITEM_TYPE       NUMBER
  , ITEM_TITLE      VARCHAR2(60)
  , ITEM_SUBTITLE   VARCHAR2(60)
  , ITEM_RATING     VARCHAR2(8)
  , ITEM_RATING_AGENCY  VARCHAR2(4)
  , ITEM_RELEASE_DATE  DATE
  , CREATED_BY  NUMBER
  , CREATION_DATE DATE
  , LAST_UPDATED_BY NUMBER
  , LAST_UPDATE_DATE    DATE
  , CONSTRUCTOR FUNCTION item_t
  ( ITEM_ID NUMBER
  , ITEM_BARCODE    VARCHAR2
  , ITEM_TYPE       NUMBER
  , ITEM_TITLE      VARCHAR2
  , ITEM_SUBTITLE   VARCHAR2
  , ITEM_RATING     VARCHAR2
  , ITEM_RATING_AGENCY  VARCHAR2
  , ITEM_RELEASE_DATE  DATE
  , CREATED_BY  NUMBER
  , CREATION_DATE DATE
  , LAST_UPDATED_BY NUMBER
  , LAST_UPDATE_DATE    DATE) RETURN SELF AS RESULT
  , OVERRIDING MEMBER FUNCTION get_name RETURN VARCHAR2
  , OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2)
  INSTANTIABLE NOT FINAL;
/

DESC item_t;

--Object body
CREATE OR REPLACE
  TYPE BODY item_t IS
      CONSTRUCTOR FUNCTION item_t
  ( ITEM_ID NUMBER
  , ITEM_BARCODE    VARCHAR2
  , ITEM_TYPE       NUMBER
  , ITEM_TITLE      VARCHAR2
  , ITEM_SUBTITLE   VARCHAR2
  , ITEM_RATING     VARCHAR2
  , ITEM_RATING_AGENCY  VARCHAR2
  , ITEM_RELEASE_DATE  DATE
  , CREATED_BY  NUMBER
  , CREATION_DATE DATE
  , LAST_UPDATED_BY NUMBER
  , LAST_UPDATE_DATE    DATE) RETURN SELF AS RESULT IS
    BEGIN
/* Assign an oname value. */
      self.oname := oname;
/* Assign a designated value or assign a null value. */
      IF name IS NOT NULL AND name IN ('NEW','OLD') THEN
        self.name := name;
      END IF;
      RETURN;
    END;

    OVERRIDING MEMBER FUNCTION get_name RETURN VARCHAR2 IS
    BEGIN
      RETURN (self AS base_t).get_name();
    END get_name;

    OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2 IS
    BEGIN
      RETURN (self AS base_t).to_string()||'.['||self.name||']';
    END to_string;
  END;
/

-- Insert item_t
INSERT INTO logger
VALUES
( logger_s.NEXTVAL
, item_t(
    oname => 'ITEM_T'
  , name => 'NEW'
  , ITEM_ID  => '999'
  , ITEM_BARCODE =>   'BARCODE'
  , ITEM_TYPE    =>   '999'
  , ITEM_TITLE   =>   'My Title'
  , ITEM_SUBTITLE  =>  'My Subtitle'
  , ITEM_RATING    =>  'PG'
  , ITEM_RATING_AGENCY  =>  'MPAA'
  , ITEM_RELEASE_DATE =>  TRUNC(SYSDATE)
  , CREATED_BY => 1
  , CREATION_DATE => TRUNC(SYSDATE)
  , LAST_UPDATED_BY => 1
  , LAST_UPDATE_DATE =>   TRUNC(SYSDATE)
  ));
  
-- contact_t
CREATE OR REPLACE
  TYPE contact_t UNDER base_t
  ( CONTACT_ID  NUMBER
    , MEMBER_ID NUMBER
    , CONTACT_TYPE  NUMBER
    , FIRST_NAME    VARCHAR2(60)
    , MIDDLE_NAME   VARCHAR2(60)
    , LAST_NAME     VARCHAR2(8)
    , CREATED_BY     NUMBER
    , CREATION_DATE DATE
    , LAST_UPDATED_BY   NUMBER
    , LAST_UPDATE_DATE  DATE
  , CONSTRUCTOR FUNCTION contact_t
  ( CONTACT_ID  NUMBER
    , MEMBER_ID NUMBER
    , CONTACT_TYPE  NUMBER
    , FIRST_NAME    VARCHAR2
    , MIDDLE_NAME   VARCHAR2
    , LAST_NAME     VARCHAR2
    , CREATED_BY     NUMBER
    , CREATION_DATE DATE
    , LAST_UPDATED_BY   NUMBER
    , LAST_UPDATE_DATE  DATE) RETURN SELF AS RESULT
  , OVERRIDING MEMBER FUNCTION get_name RETURN VARCHAR2
  , OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2)
  INSTANTIABLE NOT FINAL;
/

DESC contact_t;


CREATE OR REPLACE
  TYPE BODY contact_t IS
      CONSTRUCTOR FUNCTION contact_t
  (   CONTACT_ID  NUMBER
    , MEMBER_ID NUMBER
    , CONTACT_TYPE  NUMBER
    , FIRST_NAME    VARCHAR2
    , MIDDLE_NAME   VARCHAR2
    , LAST_NAME     VARCHAR2
    , CREATED_BY     NUMBER
    , CREATION_DATE DATE
    , LAST_UPDATED_BY   NUMBER
    , LAST_UPDATE_DATE  DATE) RETURN SELF AS RESULT IS
    BEGIN
/* Assign an oname value. */
      self.oname := oname;
/* Assign a designated value or assign a null value. */
      IF name IS NOT NULL AND name IN ('NEW','OLD') THEN
        self.name := name;
      END IF;
      RETURN;
    END;

    OVERRIDING MEMBER FUNCTION get_name RETURN VARCHAR2 IS
    BEGIN
      RETURN (self AS base_t).get_name();
    END get_name;

    OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2 IS
    BEGIN
      RETURN (self AS base_t).to_string()||'.['||self.name||']';
    END to_string;
  END;
/

-- Insert contact_t
INSERT INTO logger
VALUES
( logger_s.NEXTVAL
, contact_t(
    oname => 'CONTACT_T'
  , name => 'NEW'
  , CONTACT_ID => '9999'
  , MEMBER_ID => '9999'
  , CONTACT_TYPE => 1
  , FIRST_NAME => 'MICHAEL'
  , MIDDLE_NAME => 'J'
  , LAST_NAME => 'FOX'
  , CREATED_BY => 1
  , CREATION_DATE => TRUNC(SYSDATE)
  , LAST_UPDATED_BY => 1
  , LAST_UPDATE_DATE =>   TRUNC(SYSDATE)
  ));
  
-- Verify inserts.
COLUMN oname     FORMAT A20
COLUMN get_name  FORMAT A20
COLUMN to_string FORMAT A20
SELECT t.logger_id
,      t.log.oname AS oname
,      t.log.get_name() AS get_name
,      t.log.to_string() AS to_string
FROM  (SELECT l.logger_id
       ,      TREAT(l.log_text AS base_t) AS log
       FROM   logger l) t
WHERE  t.log.oname IN ('CONTACT_T','ITEM_T');

-- Close log file.
SPOOL OFF
