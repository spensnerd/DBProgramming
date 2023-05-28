/*
||  Name:          apply_plsql_lab8.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 9 lab.
*/
@/home/student/Data/cit325/lib/cleanup_oracle.sql
@/home/student/Data/cit325/lib/Oracle12cPLSQLCode/Introduction/create_video_store.sql
@../lab7/apply_plsql_lab7.sql


-- create our log file
SPOOL apply_plsql_lab8.txt


-- STEP 1

CREATE OR REPLACE PACKAGE contact_package IS
PROCEDURE insert_contact
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
    , pv_user_name          VARCHAR2);

	PROCEDURE insert_contact
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
    , pv_user_id            NUMBER); 
END contact_package;
/

-- Describe package.
DESC contact_package;

-- Inserts for lab
INSERT INTO system_user
VALUES
    (
    6
    , 'BONDSB'
    , 1
    , (SELECT c.common_lookup_id   
    FROM common_lookup c
    WHERE c.common_lookup_type = 'DBA')
    , 'Bonds'
    , 'Barry'
    , 'Lamar'
    , (SELECT c.common_lookup_id
    FROM common_lookup c
    WHERE c.common_lookup_type = 'SYSTEM_ADMIN')
    , SYSDATE
    , (SELECT c.common_lookup_id
    FROM common_lookup c
    WHERE c.common_lookup_type = 'SYSTEM_ADMIN')
    , SYSDATE);

    INSERT INTO system_user
    VALUES
    (
    7
    , 'CURRYW'
    , 1
    , (SELECT c.common_lookup_id
    FROM common_lookup c
    WHERE c.common_lookup_type = 'DBA')
    , 'Curry'
    , 'Wardell'
    , 'Stephen'
    , (SELECT c.common_lookup_id
    FROM common_lookup c
    WHERE c.common_lookup_type = 'SYSTEM_ADMIN')
    , SYSDATE
    , (SELECT c.common_lookup_id
    FROM common_lookup c
    WHERE c.common_lookup_type = 'SYSTEM_ADMIN')
    , SYSDATE);

    INSERT INTO system_user
    VALUES
    (
    -1
    , 'ANONYMOUS'
    , 1
    , (SELECT c.common_lookup_id
    FROM common_lookup c
    WHERE c.common_lookup_type = 'DBA')
    , ''
    , ''
    , ''
    , (SELECT c.common_lookup_id
    FROM common_lookup c
    WHERE c.common_lookup_type = 'SYSTEM_ADMIN')
    , SYSDATE
    , (SELECT c.common_lookup_id
    FROM common_lookup c
    WHERE c.common_lookup_type = 'SYSTEM_ADMIN')
    , SYSDATE);

-- Verify Inserts

COL system_user_id  FORMAT 9999  HEADING "System|User ID"
COL system_user_name FORMAT A12  HEADING "System|User Name"
COL first_name       FORMAT A10  HEADING "First|Name"
COL middle_initial   FORMAT A2   HEADING "MI"
COL last_name        FORMAT A10  HeADING "Last|Name"
SELECT 
    system_user_id
    ,      system_user_name
    ,      first_name
    ,      middle_initial
    ,      last_name
    FROM   system_user
    WHERE  last_name IN ('Bonds','Curry')
    OR     system_user_name = 'ANONYMOUS';


-- Overloaded contact_package.

CREATE OR REPLACE PACKAGE BODY contact_package IS
PROCEDURE insert_contact
    ( pv_first_name         VARCHAR2 
    , pv_middle_name        VARCHAR2 := ''
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
    , pv_user_name          VARCHAR2) is

-- Add local variables
    lv_contact_type          VARCHAR2(50);
    lv_member_type           VARCHAR2(50);
    lv_credit_card_type      VARCHAR2(50);
    lv_address_type          VARCHAR2(50);
    lv_telephone_type        VARCHAR2(50);
    lv_created_by            NUMBER; 
    lv_creation_date         DATE := SYSDATE;
    lv_member_id             NUMBER;


CURSOR lookup
    (cv_table_name        VARCHAR2
    ,cv_column_name       VARCHAR2
    ,cv_lookup_type       VARCHAR2) is
SELECT c.common_lookup_id
FROM common_lookup c
WHERE c.common_lookup_table = cv_table_name
AND c.common_lookup_column = cv_column_name
AND c.common_lookup_type = cv_lookup_type;


-- Cursors
CURSOR m
(cv_account_number VARCHAR2) is
SELECT m.member_id
FROM member m
WHERE m.account_number = cv_account_number;

BEGIN

SELECT s.system_user_id
INTO  lv_created_by
FROM   system_user s
WHERE s.system_user_name = pv_user_name;


FOR value IN lookup('MEMBER', 'MEMBER_TYPE', pv_member_type) LOOP
lv_member_type := value.common_lookup_id;
END LOOP;

For value IN lookup('CONTACT', 'CONTACT_TYPE', pv_contact_type) LOOP
lv_contact_type := value.common_lookup_id;
END LOOP;

-- this is part of the member table
For value IN lookup('MEMBER', 'CREDIT_CARD_TYPE', pv_credit_card_type) LOOP
lv_credit_card_type := value.common_lookup_id;
END LOOP;

For value IN lookup('ADDRESS', 'ADDRESS_TYPE', pv_address_type) LOOP
lv_address_type := value.common_lookup_id;
END LOOP;

For value IN lookup('TELEPHONE', 'TELEPHONE_TYPE', pv_telephone_type) LOOP
lv_telephone_type := value.common_lookup_id;
END LOOP;

-- Set the savepoint
SAVEPOINT starting_point1;

-- ==================================================
-- Use our cursor to grab a memberID detail for use
-- More Cursor work
OPEN m(pv_account_number);
FETCH m INTO lv_member_id;


IF m%NOTFOUND THEN
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

END IF;

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
    --ROLLBACK TO starting_point1;
    ROLLBACK;
END insert_contact;

PROCEDURE insert_contact
    ( pv_first_name       VARCHAR2 
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
    , pv_user_id            NUMBER) is

    -- Add local variables
    lv_contact_type          VARCHAR2(50);
    lv_member_type           VARCHAR2(50);
    lv_credit_card_type      VARCHAR2(50);
    lv_address_type          VARCHAR2(50);
    lv_telephone_type        VARCHAR2(50);

-- As requested...ID gets us a -1
    lv_created_by            NUMBER:= nvl(pv_user_id, -1); 
    
    lv_creation_date         DATE := SYSDATE;
    lv_member_id             NUMBER;


CURSOR lookup
(cv_table_name        VARCHAR2
,cv_column_name       VARCHAR2
,cv_lookup_type       VARCHAR2) is
SELECT c.common_lookup_id
FROM common_lookup c
WHERE c.common_lookup_table = cv_table_name
AND c.common_lookup_column = cv_column_name
AND c.common_lookup_type = cv_lookup_type;

CURSOR m
(cv_account_number VARCHAR2) is
SELECT m.member_id
FROM member m
WHERE m.account_number = cv_account_number;

BEGIN

For value IN lookup('MEMBER', 'MEMBER_TYPE', pv_member_type) LOOP
lv_member_type := value.common_lookup_id;
END LOOP;

For value IN lookup('CONTACT', 'CONTACT_TYPE', pv_contact_type) LOOP
lv_contact_type := value.common_lookup_id;
END LOOP;

-- this is part of the member table
For value IN lookup('MEMBER', 'CREDIT_CARD_TYPE', pv_credit_card_type) LOOP
lv_credit_card_type := value.common_lookup_id;
END LOOP;

For value IN lookup('ADDRESS', 'ADDRESS_TYPE', pv_address_type) LOOP
lv_address_type := value.common_lookup_id;
END LOOP;

For value IN lookup('TELEPHONE', 'TELEPHONE_TYPE', pv_telephone_type) LOOP
lv_telephone_type := value.common_lookup_id;
END LOOP;

-- Set the savepoint
SAVEPOINT starting_point2;

OPEN m(pv_account_number);
FETCH m INTO lv_member_id;

IF m%NOTFOUND THEN
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

END IF;

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
ROLLBACK TO starting_point2;

END insert_contact;     
END contact_package;
/

-- Step 2 data

BEGIN
    contact_package.insert_contact
    ( pv_first_name => 'Charlie'
    , pv_middle_name => ''
    , pv_last_name => 'Brown'
    , pv_contact_type => 'CUSTOMER'
    , pv_account_number => 'SLC-000011'
    , pv_member_type => 'GROUP'
    , pv_credit_card_number => '8888-6666-8888-4444'
    , pv_credit_card_type => 'VISA_CARD'
    , pv_city => 'Lehi'
    , pv_state_province => 'Utah'
    , pv_postal_code => '84043'
    , pv_address_type => 'HOME'
    , pv_country_code => '001'
    , pv_area_code => '207'
    , pv_telephone_number => '877-4321'
    , pv_telephone_type => 'HOME'
    , pv_user_name => 'DBA 3');


    contact_package.insert_contact
    ( pv_first_name => 'Peppermint'
    , pv_middle_name => ''
    , pv_last_name => 'Patty'
    , pv_contact_type => 'CUSTOMER'
    , pv_account_number => 'SLC-000011'
    , pv_member_type => 'GROUP'
    , pv_credit_card_number => '8888-6666-8888-4444'
    , pv_credit_card_type => 'VISA_CARD'
    , pv_city => 'Lehi'
    , pv_state_province => 'Utah'
    , pv_postal_code => '84043'
    , pv_address_type => 'HOME'
    , pv_country_code => '001'
    , pv_area_code => '207'
    , pv_telephone_number => '877-4321'
    , pv_telephone_type => 'HOME'
    , pv_user_id => '');

    contact_package.insert_contact
    ( pv_first_name => 'Sally'
    , pv_middle_name => ''
    , pv_last_name => 'Brown'
    , pv_contact_type => 'CUSTOMER'
    , pv_account_number => 'SLC-000011'
    , pv_member_type => 'GROUP'
    , pv_credit_card_number => '8888-6666-8888-4444'
    , pv_credit_card_type => 'VISA_CARD'
    , pv_city => 'Lehi'
    , pv_state_province => 'Utah'
    , pv_postal_code => '84043'
    , pv_address_type => 'HOME'
    , pv_country_code => '001'
    , pv_area_code => '207'
    , pv_telephone_number => '877-4321'
    , pv_telephone_type => 'HOME'
    , pv_user_id => 6);
END;
/

-- Step 2 verify data.

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
WHERE  c.last_name IN ('Brown','Patty');


-- Step 3.

CREATE OR REPLACE PACKAGE contact_package IS
FUNCTION insert_contact
    ( pv_first_name         VARCHAR2 
    , pv_middle_name        VARCHAR2 :=''
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
    , pv_user_name          VARCHAR2) RETURN NUMBER;

FUNCTION insert_contact
    ( pv_first_name         VARCHAR2 
    , pv_middle_name        VARCHAR2 :=''
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
    , pv_user_id          NUMBER) RETURN NUMBER; 
END contact_package;
/

-- Step 3 function overload.

CREATE OR REPLACE PACKAGE BODY contact_package IS
FUNCTION insert_contact
    ( pv_first_name         VARCHAR2 
    , pv_middle_name        VARCHAR2 :=''
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
    , pv_user_name          VARCHAR2) RETURN NUMBER IS

-- Add local variables
    lv_contact_type          VARCHAR2(50);
    lv_member_type           VARCHAR2(50);
    lv_credit_card_type      VARCHAR2(50);
    lv_address_type          VARCHAR2(50);
    lv_telephone_type        VARCHAR2(50);
    lv_created_by            NUMBER; 
    lv_creation_date         DATE := SYSDATE;
    lv_member_id             NUMBER;
    lv_retval                NUMBER := 0;

CURSOR lookup
    (cv_table_name        VARCHAR2
    ,cv_column_name       VARCHAR2
    ,cv_lookup_type       VARCHAR2) IS
SELECT c.common_lookup_id
FROM common_lookup c
WHERE c.common_lookup_table = cv_table_name
AND c.common_lookup_column = cv_column_name
AND c.common_lookup_type = cv_lookup_type;


CURSOR m
(cv_account_number VARCHAR2) IS
SELECT m.member_id
FROM member m
WHERE m.account_number = cv_account_number;


BEGIN

SELECT s.system_user_id
INTO  lv_created_by
FROM   system_user s
WHERE s.system_user_name = pv_user_name;

FOR value IN lookup('MEMBER', 'MEMBER_TYPE', pv_member_type) LOOP
lv_member_type := value.common_lookup_id;
END LOOP;

FOR value IN lookup('CONTACT', 'CONTACT_TYPE', pv_contact_type) LOOP
lv_contact_type := value.common_lookup_id;
END LOOP;

-- this is part of the member table
FOR value IN lookup('MEMBER', 'CREDIT_CARD_TYPE', pv_credit_card_type) LOOP
lv_credit_card_type := value.common_lookup_id;
END LOOP;

FOR value IN lookup('ADDRESS', 'ADDRESS_TYPE', pv_address_type) LOOP
lv_address_type := value.common_lookup_id;
END LOOP;

FOR value IN lookup('TELEPHONE', 'TELEPHONE_TYPE', pv_telephone_type) LOOP
lv_telephone_type := value.common_lookup_id;
END LOOP;

SAVEPOINT starting_point1;


OPEN m(pv_account_number);
FETCH m INTO lv_member_id;


IF m%NOTFOUND THEN
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
END IF;

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

RETURN lv_retval;

EXCEPTION 
WHEN OTHERS THEN
ROLLBACK TO starting_point1;
Return 1;
END insert_contact;

FUNCTION insert_contact
    ( pv_first_name         VARCHAR2 
    , pv_middle_name        VARCHAR2 :=''
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
    , pv_user_id            NUMBER) RETURN NUMBER is

-- Add local variables
    lv_contact_type          VARCHAR2(50);
    lv_member_type           VARCHAR2(50);
    lv_credit_card_type      VARCHAR2(50);
    lv_address_type          VARCHAR2(50);
    lv_telephone_type        VARCHAR2(50);
    
    lv_created_by            NUMBER := nvl(pv_user_id, -1); 
    lv_creation_date         DATE := SYSDATE;
    lv_member_id             NUMBER;
    lv_retval                NUMBER := 0;


cursor lookup
    (cv_table_name        VARCHAR2
    ,cv_column_name       VARCHAR2
    ,cv_lookup_type       VARCHAR2) IS
SELECT c.common_lookup_id            
FROM common_lookup c            
WHERE c.common_lookup_table = cv_table_name
AND c.common_lookup_column = cv_column_name
AND c.common_lookup_type = cv_lookup_type;


CURSOR m
(cv_account_number VARCHAR2) is
SELECT m.member_id         
FROM member m
WHERE m.account_number = cv_account_number;

BEGIN


for value IN lookup('MEMBER', 'MEMBER_TYPE', pv_member_type) LOOP
lv_member_type := value.common_lookup_id;
END LOOP;


for value IN lookup('CONTACT', 'CONTACT_TYPE', pv_contact_type) LOOP
lv_contact_type := value.common_lookup_id;
END LOOP;

-- this is part of the member table
for value IN lookup('MEMBER', 'CREDIT_CARD_TYPE', pv_credit_card_type) LOOP
lv_credit_card_type := value.common_lookup_id;
END LOOP;


for value IN lookup('ADDRESS', 'ADDRESS_TYPE', pv_address_type) LOOP
lv_address_type := value.common_lookup_id;
END LOOP;


for value IN lookup('TELEPHONE', 'TELEPHONE_TYPE', pv_telephone_type) LOOP
lv_telephone_type := value.common_lookup_id;
END LOOP;


-- Set the savepoint
SAVEPOINT starting_point2;

OPEN m(pv_account_number);
FETCH m INTO lv_member_id;

IF m%NOTFOUND THEN
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

END IF;

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

RETURN lv_retval;

EXCEPTION 
WHEN OTHERS THEN
ROLLBACK TO starting_point2;
RETURN 1;
END insert_contact;     
END contact_package;
/

BEGIN
IF 
    contact_package.insert_contact(pv_first_name => 'Shirley'
    ,pv_middle_name => ''
    ,pv_last_name => 'Partridge'
    ,pv_contact_type => 'CUSTOMER'
    ,pv_account_number => 'SLC-000012'
    ,pv_member_type => 'GROUP'
    ,pv_credit_card_number => '8888-6666-8888-4444'
    ,pv_credit_card_type => 'VISA_CARD'
    ,pv_city => 'Lehi'
    ,pv_state_province => 'Utah'
    ,pv_postal_code => '84043'
    ,pv_address_type => 'HOME'
    ,pv_country_code => '001'
    ,pv_area_code => '207'
    ,pv_telephone_number => '877-4321'
    ,pv_telephone_type => 'HOME'
    ,pv_user_name => 'DBA 3') = 0 THEN
    dbms_output.put_line('Insert contact worked!.');
END IF;

IF contact_package.insert_contact(pv_first_name => 'Keith'
    ,pv_middle_name => ''
    ,pv_last_name => 'Partridge'
    ,pv_contact_type => 'CUSTOMER'
    ,pv_account_number => 'SLC-000012'
    ,pv_member_type => 'GROUP'
    ,pv_credit_card_number => '8888-6666-8888-4444'
    ,pv_credit_card_type => 'VISA_CARD'
    ,pv_city => 'Lehi'
    ,pv_state_province => 'Utah'
    ,pv_postal_code => '84043'
    ,pv_address_type => 'HOME'
    ,pv_country_code => '001'
    ,pv_area_code => '207'
    ,pv_telephone_number => '877-4321'
    ,pv_telephone_type => 'HOME'
    ,pv_user_id => 6) = 0 THEN
    dbms_output.put_line('Insert contact worked!.');

END IF;


IF 
    contact_package.insert_contact(pv_first_name => 'Laurie'
    ,pv_middle_name => ''
    ,pv_last_name => 'Partridge'
    ,pv_contact_type => 'CUSTOMER'
    ,pv_account_number => 'SLC-000012'
    ,pv_member_type => 'GROUP'
    ,pv_credit_card_number => '8888-6666-8888-4444'
    ,pv_credit_card_type => 'VISA_CARD'
    ,pv_city => 'Lehi'
    ,pv_state_province => 'Utah'
    ,pv_postal_code => '84043'
    ,pv_address_type => 'HOME'
    , pv_country_code => '001'
    , pv_area_code => '207'
    , pv_telephone_number => '877-4321'
    , pv_telephone_type => 'HOME'
    , pv_user_id => -1) = 0 
THEN
    dbms_output.put_line('Insert contact worked!.');
END IF;

END;
/


COL full_name      FORMAT A18   HEADING "Full Name"
COL created_by     FORMAT 9999  HEADING "System|User ID"
COL account_number FORMAT A12   HEADING "Account|Number"
COL address        FORMAT A16   HEADING "Address"
COL telephone      FORMAT A16   HEADING "Telephone"
SELECT c.first_name
||     CASE
WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name||' ' ELSE ' '
END
||     c.last_name AS full_name
,      c.created_by 
,      m.account_number
,      a.city || ', ' || a.state_province AS address
,      '(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM   member m INNER JOIN contact c
ON     m.member_id = c.member_id INNER JOIN address a
ON     c.contact_id = a.contact_id INNER JOIN telephone t
ON     c.contact_id = t.contact_id
AND    a.address_id = t.address_id
WHERE  c.last_name = 'Partridge';

SPOOL OFF
