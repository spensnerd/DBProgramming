/*
||  Name:          apply_plsql_lab7.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 8 lab.
*/

SET ECHO OFF
SET FEEDBACK ON
SET PAGESIZE 49999
SET SERVEROUTPUT ON SIZE UNLIMITED


-- Open log file.
SPOOL apply_plsql_lab7.txt

-- Step cero
SELECT system_user_id
,      system_user_name
FROM   system_user
WHERE  system_user_name = 'DBA';

UPDATE system_user
SET    system_user_name = 'DBA'
WHERE  system_user_name LIKE 'DBA%';

DECLARE
/* Create a local counter variable. */
    lv_counter  NUMBER := 2;
/* Create a collection of two-character strings. */
    TYPE numbers IS TABLE OF NUMBER;
/* Create a variable of the roman_numbers collection. */
    lv_numbers  NUMBERS := numbers(1,2,3,4);
BEGIN
/* Update the system_user names to make them unique. */
    FOR i IN 1..lv_numbers.COUNT LOOP
/* Update the system_user table. */
    UPDATE system_user
    SET    system_user_name = system_user_name || ' ' || lv_numbers(i)
    WHERE  system_user_id = lv_counter;
/* Increment the counter. */
    lv_counter := lv_counter + 1;
    END LOOP;
END;
/

SELECT system_user_id
,      system_user_name
FROM   system_user
WHERE  system_user_name LIKE 'DBA%';

BEGIN
    FOR i IN (SELECT uo.object_type
        ,      uo.object_name
        FROM   user_objects uo
        WHERE  uo.object_name = 'INSERT_CONTACT') LOOP
        EXECUTE IMMEDIATE 'DROP ' || i.object_type || ' ' || i.object_name;
    END LOOP;
END;
/


-- Step uno!

CREATE OR REPLACE PROCEDURE insert_contact
( 
  pv_first_name         VARCHAR2 
, pv_middle_name        VARCHAR2 
, pv_last_name          VARCHAR2 
, pv_contact_type       VARCHAR2 
, pv_account_number     VARCHAR2 
, pv_member_type        VARCHAR2 
, pv_credit_card_number VARCHAR2 
, pv_credit_card_type   VARCHAR2
, pv_city               VARCHAR2 
, pv_state_province     VARCHAR2 
, pv_postal_code        VARCHAR2 
, pv_address_type       VARCHAR2 
, pv_country_code       VARCHAR2 
, pv_area_code          VARCHAR2
, pv_telephone_number   VARCHAR2
, pv_telephone_type     VARCHAR2
, pv_user_name          VARCHAR2) IS

-- Add local variables
lv_contact_type          VARCHAR2(50);
lv_member_type           VARCHAR2(50);
lv_credit_card_type      VARCHAR2(50);
lv_address_type          VARCHAR2(50);
lv_telephone_type        VARCHAR2(50);
lv_created_by            NUMBER; 
lv_creation_date         DATE := SYSDATE;


-- Look up common_lookup_id's from tables.
cursor c_lookup
(  cv_table_name        VARCHAR2
 , cv_column_name       VARCHAR2
 , cv_lookup_type       VARCHAR2) IS
SELECT c.common_lookup_id
FROM common_lookup c
    WHERE c.common_lookup_table = cv_table_name
    AND c.common_lookup_column = cv_column_name
    AND c.common_lookup_type = cv_lookup_type;
BEGIN

-- Get system_user_id from table and insert into created_by table.
SELECT  s.system_user_id
        INTO  lv_created_by
        FROM   system_user s
        WHERE s.system_user_name = pv_user_name;

-- Loops for the lookup ids.
FOR lookup IN c_lookup('MEMBER', 'MEMBER_TYPE', pv_member_type) LOOP
lv_member_type := lookup.common_lookup_id;
END LOOP;

FOR lookup IN c_lookup('CONTACT', 'CONTACT_TYPE', pv_contact_type) LOOP
lv_contact_type := lookup.common_lookup_id;
END LOOP;

FOR lookup IN c_lookup('MEMBER', 'CREDIT_CARD_TYPE', pv_credit_card_type) LOOP
lv_credit_card_type := lookup.common_lookup_id;
END LOOP;

FOR lookup IN c_lookup('ADDRESS', 'ADDRESS_TYPE', pv_address_type) LOOP
lv_address_type := lookup.common_lookup_id;
END LOOP;

FOR lookup IN c_lookup('TELEPHONE', 'TELEPHONE_TYPE', pv_telephone_type) LOOP
lv_telephone_type := lookup.common_lookup_id;
END LOOP

-- Set the savepoint
SAVEPOINT starting_point;

-- insert into member table
INSERT INTO member
( member_id
, member_type
, account_number
, credit_card_number
, credit_card_type
, created_by
, creation_date
, last_updated_by
, last_update_date )

VALUES
( member_s1.NEXTVAL
, lv_member_type
, pv_account_number
, pv_credit_card_number
, lv_credit_card_type
, lv_created_by
, lv_creation_date
, lv_created_by
, lv_creation_date );

-- insert into contact table
INSERT INTO contact
( contact_id
, member_id
, contact_type
, last_name
, first_name
, middle_name
, created_by
, creation_date
, last_updated_by
, last_update_date)

VALUES
( contact_s1.NEXTVAL
, member_s1.CURRVAL
, lv_contact_type
, pv_last_name
, pv_first_name
, pv_middle_name
, lv_created_by
, lv_creation_date
, lv_created_by
, lv_creation_date );

-- insert into address table
INSERT INTO address
( address_id
, contact_id
, address_type
, city
, state_province
, postal_code
, created_by
, creation_date
, last_updated_by
, last_update_date)

VALUES
( address_s1.NEXTVAL
, contact_s1.CURRVAL
, lv_address_type
, pv_city
, pv_state_province
, pv_postal_code
, lv_created_by
, lv_creation_date
, lv_created_by
, lv_creation_date );

--insert into telephone table
INSERT INTO telephone
( telephone_id
, contact_id 
, address_id
, telephone_type
, country_code
, area_code
, telephone_number
, created_by
, creation_date
, last_updated_by
, last_update_date )

VALUES
( telephone_s1.NEXTVAl
, contact_s1.CURRVAL
, address_s1.CURRVAL
, lv_telephone_type
, pv_country_code
, pv_area_code
, pv_telephone_number
, lv_created_by
, lv_creation_date
, lv_created_by
, lv_creation_date);

COMMIT;

EXCEPTION 
    WHEN OTHERS THEN
    ROLLBACK TO starting_point;
    RETURN;
END insert_contact;
/

-- write PL/SQL block to call insert_contact procedure
BEGIN
insert_contact(   
  'Charles'
, 'Francis'
, 'Xavier'
, 'CUSTOMER'
, 'SLC-000008'
, 'INDIVIDUAL'
, '7777-6666-5555-4444'
, 'DISCOVER_CARD'
, 'Milbridge'
, 'Maine'
, '04658'
, 'HOME'
, '001'
, '207'
, '111-1234'
, 'HOME'
, 'DBA 2');
END;
/

-- verify first insert
COL full_name      FORMAT A24
COL account_number FORMAT A10 HEADING "ACCOUNT|NUMBER"
COL address        FORMAT A22
COL telephone      FORMAT A14

SELECT c.first_name
||     CASE
 WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name||' ' ELSE ' '
 END
||     c.last_name AS full_name
,      m.account_number
,      a.city || ', ' || a.state_province AS address
,      '(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM   member m INNER JOIN contact c
ON     m.member_id = c.member_id INNER JOIN address a
ON     c.contact_id = a.contact_id INNER JOIN telephone t
ON     c.contact_id = t.contact_id
AND    a.address_id = t.address_id
WHERE  c.last_name = 'Xavier';


-- Step dos
CREATE OR REPLACE PROCEDURE insert_contact
( pv_first_name         VARCHAR2 
, pv_middle_name        VARCHAR2 
, pv_last_name          VARCHAR2 
, pv_contact_type       VARCHAR2 
, pv_account_number     VARCHAR2 
, pv_member_type        VARCHAR2 
, pv_credit_card_number VARCHAR2 
, pv_credit_card_type   VARCHAR2
, pv_city               VARCHAR2 
, pv_state_province     VARCHAR2 
, pv_postal_code        VARCHAR2 
, pv_address_type       VARCHAR2 
, pv_country_code       VARCHAR2 
, pv_area_code          VARCHAR2
, pv_telephone_number   VARCHAR2
, pv_telephone_type     VARCHAR2
, pv_user_name          VARCHAR2) AS PRAGMA AUTONOMOUS_TRANSACTION;

-- Add local variables
lv_contact_type          VARCHAR2(50);
lv_member_type           VARCHAR2(50);
lv_credit_card_type      VARCHAR2(50);
lv_address_type          VARCHAR2(50);
lv_telephone_type        VARCHAR2(50);
lv_created_by            NUMBER; 
lv_creation_date         DATE := SYSDATE;


-- Look up common_lookup_id's from tables.
cursor c_lookup
(  cv_table_name        VARCHAR2
 , cv_column_name       VARCHAR2
 , cv_lookup_type       VARCHAR2) IS
SELECT c.common_lookup_id
FROM common_lookup c
    WHERE c.common_lookup_table = cv_table_name
    AND c.common_lookup_column = cv_column_name
    AND c.common_lookup_type = cv_lookup_type;
BEGIN

-- Get system_user_id from table and insert into created_by table
SELECT s.system_user_id
        INTO  lv_created_by
        FROM   system_user s
        WHERE s.system_user_name = pv_user_name;

-- Loops for the lookup ids.
FOR lookup IN c_lookup('MEMBER', 'MEMBER_TYPE', pv_member_type) LOOP
lv_member_type := lookup.common_lookup_id;
END LOOP;

FOR lookup IN c_lookup('CONTACT', 'CONTACT_TYPE', pv_contact_type) LOOP
lv_contact_type := lookup.common_lookup_id;
END LOOP;

FOR lookup IN c_lookup('MEMBER', 'CREDIT_CARD_TYPE', pv_credit_card_type) LOOP
lv_credit_card_type := lookup.common_lookup_id;
END LOOP;

FOR lookup IN c_lookup('ADDRESS', 'ADDRESS_TYPE', pv_address_type) LOOP
lv_address_type := lookup.common_lookup_id;
END LOOP;

FOR lookup IN c_lookup('TELEPHONE', 'TELEPHONE_TYPE', pv_telephone_type) LOOP
lv_telephone_type := lookup.common_lookup_id;
END LOOP;


 -- Set the savepoint
SAVEPOINT starting_point;

-- insert into member table
INSERT INTO member
( member_id
, member_type
, account_number
, credit_card_number
, credit_card_type
, created_by
, creation_date
, last_updated_by
, last_update_date )

VALUES
( member_s1.NEXTVAL
, lv_member_type
, pv_account_number
, pv_credit_card_number
, lv_credit_card_type
, lv_created_by
, lv_creation_date
, lv_created_by
, lv_creation_date );

-- insert into contact table
INSERT INTO contact
( contact_id
, member_id
, contact_type
, last_name
, first_name
, middle_name
, created_by
, creation_date
, last_updated_by
, last_update_date)

VALUES
( contact_s1.NEXTVAL
, member_s1.CURRVAL
, lv_contact_type
, pv_last_name
, pv_first_name
, pv_middle_name
, lv_created_by
, lv_creation_date
, lv_created_by
, lv_creation_date );

-- insert into address table
INSERT INTO address
( address_id
, contact_id
, address_type
, city
, state_province
, postal_code
, created_by
, creation_date
, last_updated_by
, last_update_date)

VALUES
( address_s1.NEXTVAL
, contact_s1.CURRVAL
, lv_address_type
, pv_city
, pv_state_province
, pv_postal_code
, lv_created_by
, lv_creation_date
, lv_created_by
, lv_creation_date );

-- insert into telephone table
INSERT INTO telephone
( telephone_id
, contact_id 
, address_id
, telephone_type
, country_code
, area_code
, telephone_number
, created_by
, creation_date
, last_updated_by
, last_update_date )

VALUES
( telephone_s1.NEXTVAl
, contact_s1.CURRVAL
, address_s1.CURRVAL
, lv_telephone_type
, pv_country_code
, pv_area_code
, pv_telephone_number
, lv_created_by
, lv_creation_date
, lv_created_by
, lv_creation_date);
COMMIT;


EXCEPTION 
    WHEN OTHERS THEN
    ROLLBACK TO starting_point;
    RETURN;
END insert_contact;
/

-- Maura's insert
BEGIN
insert_contact(  
 'Maura'
,'Jane'
,'Haggerty'
,'CUSTOMER'
,'SLC-000009'
,'INDIVIDUAL'
,'8888-7777-6666-5555'
,'MASTER_CARD'
,'Bangor'
,'Maine'
,'04401'
,'HOME'
,'001'
,'207'
,'111-1234'
,'HOME'
,'DBA 2');
END;
/


-- Verify Maura's insert
COL full_name      FORMAT A24
COL account_number FORMAT A10 HEADING "ACCOUNT|NUMBER"
COL address        FORMAT A22
COL telephone      FORMAT A14

SELECT c.first_name
||     CASE
 WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name||' ' ELSE ' '
			 END
||     c.last_name AS full_name
,      m.account_number
,      a.city || ', ' || a.state_province AS address
,      '(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM   member m INNER JOIN contact c
ON     m.member_id = c.member_id INNER JOIN address a
ON     c.contact_id = a.contact_id INNER JOIN telephone t
ON     c.contact_id = t.contact_id
AND    a.address_id = t.address_id
WHERE  c.last_name = 'Haggerty';


-- Step 3


-- Drop insert contact procedure

BEGIN   
        FOR i IN (SELECT uo.object_type
        ,      uo.object_name
        FROM   user_objects uo
        WHERE  uo.object_name = 'INSERT_CONTACT') LOOP
        EXECUTE IMMEDIATE 'DROP ' || i.object_type || ' ' || i.object_name;
    END LOOP;
END;
/

-- Insert contact function, the funky kind.
CREATE OR REPLACE FUNCTION insert_contact
( pv_first_name         VARCHAR2 
, pv_middle_name        VARCHAR2 
, pv_last_name          VARCHAR2 
, pv_contact_type       VARCHAR2 
, pv_account_number     VARCHAR2 
, pv_member_type        VARCHAR2 
, pv_credit_card_number VARCHAR2 
, pv_credit_card_type   VARCHAR2
, pv_city               VARCHAR2 
, pv_state_province     VARCHAR2 
, pv_postal_code        VARCHAR2 
, pv_address_type       VARCHAR2 
, pv_country_code       VARCHAR2 
, pv_area_code          VARCHAR2
, pv_telephone_number   VARCHAR2
, pv_telephone_type     VARCHAR2
, pv_user_name          VARCHAR2)

-- Insert contact return function
RETURN NUMBER IS
-- Add local variables
    lv_contact_type          VARCHAR2(50);
    lv_member_type           VARCHAR2(50);
    lv_credit_card_type      VARCHAR2(50);
    lv_address_type          VARCHAR2(50);
    lv_telephone_type        VARCHAR2(50);
    lv_created_by            NUMBER; 
    lv_creation_date         DATE := SYSDATE;
    lv_number                NUMBER := 0;


-- Look up common_lookup_id's from tables.
cursor c_lookup
(  cv_table_name        VARCHAR2
 , cv_column_name       VARCHAR2
 , cv_lookup_type       VARCHAR2) IS
SELECT c.common_lookup_id
FROM common_lookup c
    WHERE c.common_lookup_table = cv_table_name
    AND c.common_lookup_column = cv_column_name
    AND c.common_lookup_type = cv_lookup_type;
BEGIN

-- Get system_user_id from table and insert into created_by table
SELECT s.system_user_id
        INTO  lv_created_by
        FROM   system_user s
        WHERE s.system_user_name = pv_user_name;

-- Look up common_lookup_id's from tables.
FOR lookup IN c_lookup('MEMBER', 'MEMBER_TYPE', pv_member_type) LOOP
lv_member_type := lookup.common_lookup_id;
END LOOP;

FOR lookup IN c_lookup('CONTACT', 'CONTACT_TYPE', pv_contact_type) LOOP
lv_contact_type := lookup.common_lookup_id;
END LOOP;

FOR lookup IN c_lookup('MEMBER', 'CREDIT_CARD_TYPE', pv_credit_card_type) LOOP
lv_credit_card_type := lookup.common_lookup_id;
END LOOP;

FOR lookup IN c_lookup('ADDRESS', 'ADDRESS_TYPE', pv_address_type) LOOP
lv_address_type := lookup.common_lookup_id;
END LOOP;

FOR lookup IN c_lookup('TELEPHONE', 'TELEPHONE_TYPE', pv_telephone_type) LOOP
lv_telephone_type := lookup.common_lookup_id;
END LOOP;


-- Savepoint again!
SAVEPOINT starting_point;

INSERT INTO member
( member_id
, member_type
, account_number
, credit_card_number
, credit_card_type
, created_by
, creation_date
, last_updated_by
, last_update_date )

VALUES
( member_s1.NEXTVAL
, lv_member_type
, pv_account_number
, pv_credit_card_number
, lv_credit_card_type
, lv_created_by
, lv_creation_date
, lv_created_by
, lv_creation_date );

-- insert into contact table
INSERT INTO contact
( contact_id
, member_id
, contact_type
, last_name
, first_name
, middle_name
, created_by
, creation_date
, last_updated_by
, last_update_date)

VALUES
( contact_s1.NEXTVAL
, member_s1.CURRVAL
, lv_contact_type
, pv_last_name
, pv_first_name
, pv_middle_name
, lv_created_by
, lv_creation_date
, lv_created_by
, lv_creation_date );

-- insert into address table
INSERT INTO address
( address_id
, contact_id
, address_type
, city
, state_province
, postal_code
, created_by
, creation_date
, last_updated_by
, last_update_date)

VALUES
( address_s1.NEXTVAL
, contact_s1.CURRVAL
, lv_address_type
, pv_city
, pv_state_province
, pv_postal_code
, lv_created_by
, lv_creation_date
, lv_created_by
, lv_creation_date );

-- insert into telephone table
INSERT INTO telephone
( telephone_id
, contact_id 
, address_id
, telephone_type
, country_code
, area_code
, telephone_number
, created_by
, creation_date
, last_updated_by
, last_update_date )

VALUES
( telephone_s1.NEXTVAl
, contact_s1.CURRVAL
, address_s1.CURRVAL
, lv_telephone_type
, pv_country_code
, pv_area_code
, pv_telephone_number
, lv_created_by
, lv_creation_date
, lv_created_by
, lv_creation_date);

-- Putting a ring on it, in Database terms.
COMMIT;

-- Return statement.
RETURN lv_number;

-- Error handler, again.
EXCEPTION 
    WHEN OTHERS THEN
        ROLLBACK TO starting_point;
    RETURN 1;
END insert_contact;
/

BEGIN
IF insert_contact('Harriet'
, 'Mary'
, 'McDonnell'
, 'CUSTOMER'
, 'SLC-000010'
, 'INDIVIDUAL'
, '9999-8888-7777-6666'
, 'VISA_CARD'
, 'Orono'
, 'Maine'
, '04469'
, 'HOME'
, '001'
, '207'
, '111-1234'
, 'HOME'
, 'DBA 2') = 0 THEN 
DBMS_OUTPUT.PUT_LINE('Success!');
ELSE DBMS_OUTPUT.PUT_LINE('Failure!');
END IF;
END;
/

-- Verify Part tres
COL full_name      FORMAT A24
COL account_number FORMAT A10 HEADING "ACCOUNT|NUMBER"
COL address        FORMAT A22
COL telephone      FORMAT A14

SELECT c.first_name
||     CASE
 WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name||' ' ELSE ' '
			 END
||     c.last_name AS full_name
,      m.account_number
,      a.city || ', ' || a.state_province AS address
,      '(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM   member m INNER JOIN contact c
ON     m.member_id = c.member_id INNER JOIN address a
ON     c.contact_id = a.contact_id INNER JOIN telephone t
ON     c.contact_id = t.contact_id
AND    a.address_id = t.address_id
WHERE  c.last_name = 'McDonnell';

-- Step cuatro

-- SQL object type.
CREATE OR REPLACE TYPE contact_obj FORCE IS object
(  first_name     varchar2(30)
 , middle_name    varchar2(30)
 , last_name      varchar2(30)
);
/


-- instantiate a table of contacts
CREATE OR REPLACE TYPE contact_tab IS TABLE OF contact_obj;
/


-- Function get contact.
CREATE OR REPLACE FUNCTION get_contact
RETURN contact_tab IS
    lv_counter number := 1;
    lv_update_insert CONTACT_TAB := contact_tab();

-- Another cursor.
    SELECT c.first_name, c.middle_name, c.last_name
    FROM contact c;

-- loops and things.

BEGIN
    -- counter
    For i in C loop
        lv_update_insert.EXTEND;
        lv_update_insert(lv_counter) := 
            contact_obj(i.first_name, i.middle_name, i.last_name);
        lv_counter := lv_counter + 1;
    END LOOP;    
RETURN lv_update_insert;
END get_contact;
/

-- Step cuatro verify
SET PAGESIZE 999
COL full_name FORMAT A24
SELECT first_name || CASE
        WHEN middle_name IS NOT NULL
        THEN ' ' || middle_name || ' '
            ELSE ' '
        END || last_name AS full_name
FROM   TABLE(get_contact);


SPOOL OFF
