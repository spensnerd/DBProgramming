/*
||  Name:          apply_plsql_lab11.sql
||  Date:          3 July 2020
||  Purpose:       Complete 325 Chapter 12 lab.
||  Dependencies:  Run the Oracle Database 12c PL/SQL Programming setup programs.
*/
@/ home / student / data / cit325 / lib / cleanup_oracle.sql

@/ home / student / data / cit325 / lib / oracle12cplsqlcode / introduction / create_video_store.sql

SPOOL apply_plsql_lab11.txt

SET SERVEROUTPUT ON
-- Modified Item Table.

COLUMN table_name FORMAT a14

COLUMN column_id FORMAT 9999

COLUMN column_name FORMAT a22

COLUMN data_type FORMAT a12

SELECT
    table_name,
    column_id,
    column_name,
    CASE
        WHEN nullable = 'N' THEN
            'NOT NULL'
        ELSE
            ''
    END AS nullable,
    CASE
        WHEN data_type IN (
            'CHAR',
            'VARCHAR2',
            'NUMBER'
        ) THEN
            data_type
            || '('
            || data_length
            || ')'
        ELSE
            data_type
    END AS data_type
FROM
    user_tab_columns
WHERE
    table_name = 'ITEM'
ORDER BY
    2;

-- Creat avenger table.

CREATE TABLE avenger (
    avenger_id     NUMBER,
    avenger_name   VARCHAR2(30)
);

CREATE SEQUENCE avenger_s;

CREATE TABLE logging (
    logging_id         NUMBER,
    old_avenger_id     NUMBER,
    old_avenger_name   VARCHAR2(30),
    new_avenger_id     NUMBER,
    new_avenger_name   VARCHAR2(30),
    CONSTRAINT logging_pk PRIMARY KEY ( logging_id )
);

CREATE SEQUENCE logging_s;

--Verify avenger and logging table.

COLUMN table_name FORMAT a14

COLUMN column_id FORMAT 9999

COLUMN column_name FORMAT a22

COLUMN data_type FORMAT a12

SELECT
    table_name,
    column_id,
    column_name,
    CASE
        WHEN nullable = 'N' THEN
            'NOT NULL'
        ELSE
            ''
    END AS nullable,
    CASE
        WHEN data_type IN (
            'CHAR',
            'VARCHAR2',
            'NUMBER'
        ) THEN
            data_type
            || '('
            || data_length
            || ')'
        ELSE
            data_type
    END AS data_type
FROM
    user_tab_columns
WHERE
    table_name = 'LOGGING'
ORDER BY
    2;

SELECT
    table_name,
    column_id,
    column_name,
    CASE
        WHEN nullable = 'N' THEN
            'NOT NULL'
        ELSE
            ''
    END AS nullable,
    CASE
        WHEN data_type IN (
            'CHAR',
            'VARCHAR2',
            'NUMBER'
        ) THEN
            data_type
            || '('
            || data_length
            || ')'
        ELSE
            data_type
    END AS data_type
FROM
    user_tab_columns
WHERE
    table_name = 'AVENGER'
ORDER BY
    2;

-- Write the log_avanger package.

CREATE OR REPLACE PACKAGE log_avenger IS
    PROCEDURE avenger_insert (
        pv_new_avenger_id     NUMBER,
        pv_new_avenger_name   VARCHAR2
    );

    PROCEDURE avenger_insert (
        pv_new_avenger_id     NUMBER,
        pv_new_avenger_name   VARCHAR2,
        pv_old_avenger_id     NUMBER,
        pv_old_avenger_name   VARCHAR2
    );

    PROCEDURE avenger_insert (
        pv_old_avenger_id     NUMBER,
        pv_old_avenger_name   VARCHAR2
    );

END log_avenger;
/

CREATE OR REPLACE PACKAGE BODY log_avenger IS

-- Package body implementation.

    PROCEDURE avenger_insert (
        pv_new_avenger_id     NUMBER,
        pv_new_avenger_name   VARCHAR2
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        log_avenger.avenger_insert(pv_old_avenger_id => NULL, pv_old_avenger_name => NULL, pv_new_avenger_id => pv_new_avenger_id
        , pv_new_avenger_name => pv_new_avenger_name);
    EXCEPTION
        WHEN OTHERS THEN
            return;
    END avenger_insert;

    PROCEDURE avenger_insert (
        pv_new_avenger_id     NUMBER,
        pv_new_avenger_name   VARCHAR2,
        pv_old_avenger_id     NUMBER,
        pv_old_avenger_name   VARCHAR2
    ) IS
        lv_logging_id NUMBER;
        PRAGMA autonomous_transaction;
    BEGIN
        lv_logging_id := logging_s.nextval;
        SAVEPOINT starting;
        INSERT INTO logging (
            logging_id,
            new_avenger_id,
            new_avenger_name,
            old_avenger_id,
            old_avenger_name
        ) VALUES (
            lv_logging_id,
            pv_new_avenger_id,
            pv_new_avenger_name,
            pv_old_avenger_id,
            pv_old_avenger_name
        );

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO starting;
            return;
    END avenger_insert;

    PROCEDURE avenger_insert (
        pv_old_avenger_id     NUMBER,
        pv_old_avenger_name   VARCHAR2
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        log_avenger.avenger_insert(pv_old_avenger_id => pv_old_avenger_id, pv_old_avenger_name => pv_old_avenger_name, pv_new_avenger_id
        => NULL, pv_new_avenger_name => NULL);
    EXCEPTION
        WHEN OTHERS THEN
            return;
    END avenger_insert;

END log_avenger;
/

-- Write and test calls to log_avenger package.

DECLARE
    lv_new_avenger_id     NUMBER := 1;
    lv_new_avenger_name   VARCHAR2(30) := 'Thor';
BEGIN
    log_avenger.avenger_insert(pv_new_avenger_id => lv_new_avenger_id, pv_new_avenger_name => lv_new_avenger_name);
END;
/

DECLARE
    lv_new_avenger_id     NUMBER := 2;
    lv_new_avenger_name   VARCHAR2(30) := 'Hulk';
BEGIN
    log_avenger.avenger_insert(pv_new_avenger_id => lv_new_avenger_id, pv_new_avenger_name => lv_new_avenger_name);
END;
/

DECLARE
    lv_avenger_id         NUMBER := 3;
    lv_old_avenger_name   VARCHAR2(30) := 'Thor';
    lv_new_avenger_name   VARCHAR2(30) := 'King Thor';
BEGIN
    log_avenger.avenger_insert(pv_old_avenger_id => lv_avenger_id, pv_old_avenger_name => lv_old_avenger_name, pv_new_avenger_id =
    > lv_avenger_id, pv_new_avenger_name => lv_new_avenger_name);
END;
/

DECLARE
  /* Define input values. */
    lv_old_avenger_id     NUMBER := 4;
    lv_old_avenger_name   VARCHAR2(30) := 'King Thor';
BEGIN
    log_avenger.avenger_insert(pv_old_avenger_id => lv_old_avenger_id, pv_old_avenger_name => lv_old_avenger_name);
END;
/

-- Write avenger_trig trigger for insert and update statements.

CREATE OR REPLACE TRIGGER avenger_trig BEFORE
    INSERT OR UPDATE OF avenger_name ON avenger
    FOR EACH ROW
DECLARE
    e EXCEPTION;
    PRAGMA exception_init ( e, -20001 );
BEGIN
    IF inserting THEN
        log_avenger.avenger_insert(pv_new_avenger_id => :new.avenger_id, pv_new_avenger_name => :new.avenger_name);

        IF :new.avenger_id IS NULL THEN
            SELECT
                avenger_s.NEXTVAL
            INTO :new.avenger_id
            FROM
                dual;

        END IF;

    ELSIF updating THEN
        log_avenger.avenger_insert(pv_new_avenger_id => :new.avenger_id, pv_new_avenger_name => :new.avenger_name, pv_old_avenger_id
        => :old.avenger_id, pv_old_avenger_name => :old.avenger_name);
    END IF;
END avenger_trig;
/

-- Write avenger_delete_trig trigger.

CREATE OR REPLACE TRIGGER avenger_delete_trig BEFORE
    DELETE ON avenger
    FOR EACH ROW
DECLARE
    e EXCEPTION;
    PRAGMA exception_init ( e, -20001 );
BEGIN
    IF deleting THEN
        log_avenger.avenger_insert(pv_old_avenger_id => :old.avenger_id, pv_old_avenger_name => :old.avenger_name);

    END IF;
END avenger_trig;
/

-- Write insert, update, and delete statement.

INSERT INTO avenger (
    avenger_id,
    avenger_name
) VALUES (
    avenger_s.NEXTVAL,
    'Captain America'
);

UPDATE avenger
SET
    avenger_name = 'Captain America "Wanted"'
WHERE
    avenger_name = 'Captain America';

DELETE FROM avenger
WHERE
    avenger_name LIKE 'Captain America%';

-- query to see what was inserted into the logging table.

COL logger_id FORMAT 999999 HEADING "Logging|ID #"

COL old_avenger_id FORMAT 999999 HEADING "Old|Avenger|ID #"

COL old_avenger_name FORMAT a25 HEADING "Old Avenger Name"

COL new_avenger_id FORMAT 999999 HEADING "New|Avenger|ID #"

COL new_avenger_name FORMAT a25 HEADING "New Avenger Name"

SELECT
    *
FROM
    logging;

DROP SEQUENCE logger_s;

ALTER TABLE item ADD text_file_name VARCHAR2(40);

-- Create the logger table and logger_s sequence.

CREATE TABLE logger (
    logger_id                NUMBER,
    old_item_id              NUMBER,
    old_item_barcode         VARCHAR2(20),
    old_item_type            NUMBER,
    old_item_title           VARCHAR2(60),
    old_item_subtitle        VARCHAR2(60),
    old_item_rating          VARCHAR2(8),
    old_item_rating_agency   VARCHAR2(4),
    old_item_release_date    DATE,
    old_created_by           NUMBER,
    old_creation_date        DATE,
    old_last_updated_by      NUMBER,
    old_last_update_date     DATE,
    old_text_file_name       VARCHAR2(40),
    new_item_id              NUMBER,
    new_item_barcode         VARCHAR2(20),
    new_item_type            NUMBER,
    new_item_title           VARCHAR2(60),
    new_item_subtitle        VARCHAR2(60),
    new_item_rating          VARCHAR2(8),
    new_item_rating_agency   VARCHAR2(4),
    new_item_release_date    DATE,
    new_created_by           NUMBER,
    new_creation_date        DATE,
    new_last_updated_by      NUMBER,
    new_last_update_date     DATE,
    new_text_file_name       VARCHAR2(40),
    CONSTRAINT logger_pk PRIMARY KEY ( logger_id )
);

CREATE SEQUENCE logger_s;

DESC item

DESC logger

DECLARE
    CURSOR get_row IS
    SELECT
        *
    FROM
        item
    WHERE
        item_title = 'Brave Heart';

BEGIN
    FOR i IN get_row LOOP
        INSERT INTO logger (
            logger_id,
            old_item_id,
            old_item_barcode,
            old_item_type,
            old_item_title,
            old_item_subtitle,
            old_item_rating,
            old_item_rating_agency,
            old_item_release_date,
            old_created_by,
            old_creation_date,
            old_last_updated_by,
            old_last_update_date,
            old_text_file_name,
            new_item_id,
            new_item_barcode,
            new_item_type,
            new_item_title,
            new_item_subtitle,
            new_item_rating,
            new_item_rating_agency,
            new_item_release_date,
            new_created_by,
            new_creation_date,
            new_last_updated_by,
            new_last_update_date,
            new_text_file_name
        ) VALUES (
            logger_s.NEXTVAL,
            i.item_id,
            i.item_barcode,
            i.item_type,
            i.item_title,
            i.item_subtitle,
            i.item_rating,
            i.item_rating_agency,
            i.item_release_date,
            i.created_by,
            i.creation_date,
            i.last_updated_by,
            i.last_update_date,
            i.text_file_name,
            i.item_id,
            i.item_barcode,
            i.item_type,
            i.item_title,
            i.item_subtitle,
            i.item_rating,
            i.item_rating_agency,
            i.item_release_date,
            i.created_by,
            i.creation_date,
            i.last_updated_by,
            i.last_update_date,
            i.text_file_name
        );

    END LOOP;
END;
/

CREATE OR REPLACE PACKAGE manage_item IS
    PROCEDURE item_insert (
        pv_new_item_id              NUMBER,
        pv_new_item_barcode         VARCHAR2,
        pv_new_item_type            NUMBER,
        pv_new_item_title           VARCHAR2,
        pv_new_item_subtitle        VARCHAR2,
        pv_new_item_rating          VARCHAR2,
        pv_new_item_rating_agency   VARCHAR2,
        pv_new_item_release_date    DATE,
        pv_new_created_by           NUMBER,
        pv_new_creation_date        DATE,
        pv_new_last_updated_by      NUMBER,
        pv_new_last_update_date     DATE,
        pv_new_text_file_name       VARCHAR2
    );

    PROCEDURE item_insert (
        pv_old_item_id              NUMBER,
        pv_old_item_barcode         VARCHAR2,
        pv_old_item_type            NUMBER,
        pv_old_item_title           VARCHAR2,
        pv_old_item_subtitle        VARCHAR2,
        pv_old_item_rating          VARCHAR2,
        pv_old_item_rating_agency   VARCHAR2,
        pv_old_item_release_date    DATE,
        pv_old_created_by           NUMBER,
        pv_old_creation_date        DATE,
        pv_old_last_updated_by      NUMBER,
        pv_old_last_update_date     DATE,
        pv_old_text_file_name       VARCHAR2,
        pv_new_item_id              NUMBER,
        pv_new_item_barcode         VARCHAR2,
        pv_new_item_type            NUMBER,
        pv_new_item_title           VARCHAR2,
        pv_new_item_subtitle        VARCHAR2,
        pv_new_item_rating          VARCHAR2,
        pv_new_item_rating_agency   VARCHAR2,
        pv_new_item_release_date    DATE,
        pv_new_created_by           NUMBER,
        pv_new_creation_date        DATE,
        pv_new_last_updated_by      NUMBER,
        pv_new_last_update_date     DATE,
        pv_new_text_file_name       VARCHAR2
    );

    PROCEDURE item_insert (
        pv_old_item_id              NUMBER,
        pv_old_item_barcode         VARCHAR2,
        pv_old_item_type            NUMBER,
        pv_old_item_title           VARCHAR2,
        pv_old_item_subtitle        VARCHAR2,
        pv_old_item_rating          VARCHAR2,
        pv_old_item_rating_agency   VARCHAR2,
        pv_old_item_release_date    DATE,
        pv_old_created_by           NUMBER,
        pv_old_creation_date        DATE,
        pv_old_last_updated_by      NUMBER,
        pv_old_last_update_date     DATE,
        pv_old_text_file_name       VARCHAR2
    );

END manage_item;
/

DESC manage_item

CREATE OR REPLACE PACKAGE BODY manage_item IS

    PROCEDURE item_insert            -- For New inserts

     (
        pv_new_item_id              NUMBER,
        pv_new_item_barcode         VARCHAR2,
        pv_new_item_type            NUMBER,
        pv_new_item_title           VARCHAR2,
        pv_new_item_subtitle        VARCHAR2,
        pv_new_item_rating          VARCHAR2,
        pv_new_item_rating_agency   VARCHAR2,
        pv_new_item_release_date    DATE,
        pv_new_created_by           NUMBER,
        pv_new_creation_date        DATE,
        pv_new_last_updated_by      NUMBER,
        pv_new_last_update_date     DATE,
        pv_new_text_file_name       VARCHAR2
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        manage_item.item_insert(pv_old_item_id => NULL, pv_old_item_barcode => NULL, pv_old_item_type => NULL, pv_old_item_title =
        > NULL, pv_old_item_subtitle => NULL,
                                pv_old_item_rating => NULL, pv_old_item_rating_agency => NULL, pv_old_item_release_date => NULL, pv_old_created_by
                                => NULL, pv_old_creation_date => NULL,
                                pv_old_last_updated_by => NULL, pv_old_last_update_date => NULL, pv_old_text_file_name => NULL, pv_new_item_id
                                => pv_new_item_id, pv_new_item_barcode => pv_new_item_barcode,
                                pv_new_item_type => pv_new_item_type, pv_new_item_title => pv_new_item_title, pv_new_item_subtitle
                                => pv_new_item_subtitle, pv_new_item_rating => pv_new_item_rating, pv_new_item_rating_agency => pv_new_item_rating_agency
                                ,
                                pv_new_item_release_date => pv_new_item_release_date, pv_new_created_by => pv_new_created_by, pv_new_creation_date
                                => pv_new_creation_date, pv_new_last_updated_by => pv_new_last_updated_by, pv_new_last_update_date
                                => pv_new_last_update_date,
                                pv_new_text_file_name => pv_new_text_file_name);

        COMMIT;
    END item_insert;

    PROCEDURE item_insert (
        pv_old_item_id              NUMBER,
        pv_old_item_barcode         VARCHAR2,
        pv_old_item_type            NUMBER,
        pv_old_item_title           VARCHAR2,
        pv_old_item_subtitle        VARCHAR2,
        pv_old_item_rating          VARCHAR2,
        pv_old_item_rating_agency   VARCHAR2,
        pv_old_item_release_date    DATE,
        pv_old_created_by           NUMBER,
        pv_old_creation_date        DATE,
        pv_old_last_updated_by      NUMBER,
        pv_old_last_update_date     DATE,
        pv_old_text_file_name       VARCHAR2,
        pv_new_item_id              NUMBER,
        pv_new_item_barcode         VARCHAR2,
        pv_new_item_type            NUMBER,
        pv_new_item_title           VARCHAR2,
        pv_new_item_subtitle        VARCHAR2,
        pv_new_item_rating          VARCHAR2,
        pv_new_item_rating_agency   VARCHAR2,
        pv_new_item_release_date    DATE,
        pv_new_created_by           NUMBER,
        pv_new_creation_date        DATE,
        pv_new_last_updated_by      NUMBER,
        pv_new_last_update_date     DATE,
        pv_new_text_file_name       VARCHAR2
    ) IS
        PRAGMA autonomous_transaction;
        lv_logger_id NUMBER;
    BEGIN
        lv_logger_id := logger_s.nextval;
        INSERT INTO logger (
            logger_id,
            old_item_id,
            old_item_barcode,
            old_item_type,
            old_item_title,
            old_item_subtitle,
            old_item_rating,
            old_item_rating_agency,
            old_item_release_date,
            old_created_by,
            old_creation_date,
            old_last_updated_by,
            old_last_update_date,
            old_text_file_name,
            new_item_id,
            new_item_barcode,
            new_item_type,
            new_item_title,
            new_item_subtitle,
            new_item_rating,
            new_item_rating_agency,
            new_item_release_date,
            new_created_by,
            new_creation_date,
            new_last_updated_by,
            new_last_update_date,
            new_text_file_name
        ) VALUES (
            lv_logger_id,
            pv_old_item_id,
            pv_old_item_barcode,
            pv_old_item_type,
            pv_old_item_title,
            pv_old_item_subtitle,
            pv_old_item_rating,
            pv_old_item_rating_agency,
            pv_old_item_release_date,
            pv_old_created_by,
            pv_old_creation_date,
            pv_old_last_updated_by,
            pv_old_last_update_date,
            pv_old_text_file_name,
            pv_new_item_id,
            pv_new_item_barcode,
            pv_new_item_type,
            pv_new_item_title,
            pv_new_item_subtitle,
            pv_new_item_rating,
            pv_new_item_rating_agency,
            pv_new_item_release_date,
            pv_new_created_by,
            pv_new_creation_date,
            pv_new_last_updated_by,
            pv_new_last_update_date,
            pv_new_text_file_name
        );

        COMMIT;
    END item_insert;

    PROCEDURE item_insert (
        pv_old_item_id              NUMBER,
        pv_old_item_barcode         VARCHAR2,
        pv_old_item_type            NUMBER,
        pv_old_item_title           VARCHAR2,
        pv_old_item_subtitle        VARCHAR2,
        pv_old_item_rating          VARCHAR2,
        pv_old_item_rating_agency   VARCHAR2,
        pv_old_item_release_date    DATE,
        pv_old_created_by           NUMBER,
        pv_old_creation_date        DATE,
        pv_old_last_updated_by      NUMBER,
        pv_old_last_update_date     DATE,
        pv_old_text_file_name       VARCHAR2
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        manage_item.item_insert(pv_old_item_id => pv_old_item_id, pv_old_item_barcode => pv_old_item_barcode, pv_old_item_type =>
        pv_old_item_type, pv_old_item_title => pv_old_item_title, pv_old_item_subtitle => pv_old_item_subtitle,
                                pv_old_item_rating => pv_old_item_rating, pv_old_item_rating_agency => pv_old_item_rating_agency,
                                pv_old_item_release_date => pv_old_item_release_date, pv_old_created_by => pv_old_created_by, pv_old_creation_date
                                => pv_old_creation_date,
                                pv_old_last_updated_by => pv_old_last_updated_by, pv_old_last_update_date => pv_old_last_update_date
                                , pv_old_text_file_name => pv_old_text_file_name, pv_new_item_id => NULL, pv_new_item_barcode => NULL
                                ,
                                pv_new_item_type => NULL, pv_new_item_title => NULL, pv_new_item_subtitle => NULL, pv_new_item_rating
                                => NULL, pv_new_item_rating_agency => NULL,
                                pv_new_item_release_date => NULL, pv_new_created_by => NULL, pv_new_creation_date => NULL, pv_new_last_updated_by
                                => NULL, pv_new_last_update_date => NULL,
                                pv_new_text_file_name => NULL);
    END item_insert;

END manage_item;
/

DECLARE
    CURSOR get_row IS
    SELECT
        *
    FROM
        item
    WHERE
        item_title = 'King Arthur';

BEGIN
    FOR i IN get_row LOOP
        manage_item.item_insert(pv_new_item_id => i.item_id, pv_new_item_barcode => i.item_barcode, pv_new_item_type => i.item_type
        , pv_new_item_title => i.item_title || '-Inserted', pv_new_item_subtitle => i.item_subtitle,
                                pv_new_item_rating => i.item_rating, pv_new_item_rating_agency => i.item_rating_agency, pv_new_item_release_date
                                => i.item_release_date, pv_new_created_by => i.created_by, pv_new_creation_date => i.creation_date
                                ,
                                pv_new_last_updated_by => i.last_updated_by, pv_new_last_update_date => i.last_update_date, pv_new_text_file_name
                                => i.text_file_name);

        manage_item.item_insert(pv_old_item_id => i.item_id, pv_old_item_barcode => i.item_barcode, pv_old_item_type => i.item_type
        , pv_old_item_title => i.item_title, pv_old_item_subtitle => i.item_subtitle,
                                pv_old_item_rating => i.item_rating, pv_old_item_rating_agency => i.item_rating_agency, pv_old_item_release_date
                                => i.item_release_date, pv_old_created_by => i.created_by, pv_old_creation_date => i.creation_date
                                ,
                                pv_old_last_updated_by => i.last_updated_by, pv_old_last_update_date => i.last_update_date, pv_old_text_file_name
                                => i.text_file_name, pv_new_item_id => i.item_id, pv_new_item_barcode => i.item_barcode,
                                pv_new_item_type => i.item_type, pv_new_item_title => i.item_title || '-Changed', pv_new_item_subtitle
                                => i.item_subtitle, pv_new_item_rating => i.item_rating, pv_new_item_rating_agency => i.item_rating_agency
                                ,
                                pv_new_item_release_date => i.item_release_date, pv_new_created_by => i.created_by, pv_new_creation_date
                                => i.creation_date, pv_new_last_updated_by => i.last_updated_by, pv_new_last_update_date => i.last_update_date
                                ,
                                pv_new_text_file_name => i.text_file_name);

        manage_item.item_insert(pv_old_item_id => i.item_id, pv_old_item_barcode => i.item_barcode, pv_old_item_type => i.item_type
        , pv_old_item_title => i.item_title || '-Deleted', pv_old_item_subtitle => i.item_subtitle,
                                pv_old_item_rating => i.item_rating, pv_old_item_rating_agency => i.item_rating_agency, pv_old_item_release_date
                                => i.item_release_date, pv_old_created_by => i.created_by, pv_old_creation_date => i.creation_date
                                ,
                                pv_old_last_updated_by => i.last_updated_by, pv_old_last_update_date => i.last_update_date, pv_old_text_file_name
                                => i.text_file_name);

    END LOOP;
END;
/

CREATE OR REPLACE TRIGGER item_trig BEFORE
    INSERT OR UPDATE OF item_title ON item
    FOR EACH ROW
DECLARE
    lv_input_title     VARCHAR2(40);
    lv_title           VARCHAR2(20);
    lv_subtitle        VARCHAR2(20);
    lv_update_needed   NUMBER;
    e EXCEPTION;
    PRAGMA exception_init ( e, -20001 );
BEGIN
    IF inserting THEN
        manage_item.item_insert(pv_new_item_id => :new.item_id, pv_new_item_barcode => :new.item_barcode, pv_new_item_type => :new
        .item_type, pv_new_item_title => :new.item_title, pv_new_item_subtitle => :new.item_subtitle,
                                pv_new_item_rating => :new.item_rating, pv_new_item_rating_agency => :new.item_rating_agency, pv_new_item_release_date
                                => :new.item_release_date, pv_new_created_by => :new.created_by, pv_new_creation_date => :new.creation_date
                                ,
                                pv_new_last_updated_by => :new.last_updated_by, pv_new_last_update_date => :new.last_update_date,
                                pv_new_text_file_name => :new.text_file_name);

      /* Assign the title */

        lv_input_title := :new.item_title;
        lv_update_needed := 0;
        IF regexp_instr(lv_input_title, ':') > 0 AND regexp_instr(lv_input_title, ':') = length(lv_input_title) THEN
        /* Shave off the colon. */
            lv_title := substr(lv_input_title, 1, regexp_instr(lv_input_title, ':') - 1);

            lv_subtitle := '';
            lv_update_needed := 1;
        ELSIF regexp_instr(lv_input_title, ':') > 0 THEN
        /* Split the string into two parts. */
            lv_title := substr(lv_input_title, 1, regexp_instr(lv_input_title, ':') - 1);

            lv_subtitle := ltrim(substr(lv_input_title, regexp_instr(lv_input_title, ':') + 1, length(lv_input_title)));

            lv_update_needed := 1;
        END IF;

        IF lv_update_needed = 1 THEN
            manage_item.item_insert(pv_old_item_id => :new.item_id, pv_old_item_barcode => :new.item_barcode, pv_old_item_type =>
            :new.item_type, pv_old_item_title => :new.item_title, pv_old_item_subtitle => :new.item_subtitle,
                                    pv_old_item_rating => :new.item_rating, pv_old_item_rating_agency => :new.item_rating_agency,
                                    pv_old_item_release_date => :new.item_release_date, pv_old_created_by => :new.created_by, pv_old_creation_date
                                    => :new.creation_date,
                                    pv_old_last_updated_by => :new.last_updated_by, pv_old_last_update_date => :new.last_update_date
                                    , pv_old_text_file_name => :new.text_file_name, pv_new_item_id => :new.item_id, pv_new_item_barcode
                                    => :new.item_barcode,
                                    pv_new_item_type => :new.item_type, pv_new_item_title => lv_title, pv_new_item_subtitle => lv_subtitle
                                    , pv_new_item_rating => :new.item_rating, pv_new_item_rating_agency => :new.item_rating_agency
                                    ,
                                    pv_new_item_release_date => :new.item_release_date, pv_new_created_by => :new.created_by, pv_new_creation_date
                                    => :new.creation_date, pv_new_last_updated_by => :new.last_updated_by, pv_new_last_update_date
                                    => :new.last_update_date,
                                    pv_new_text_file_name => :new.text_file_name);

            :new.item_title := lv_title;
            :new.item_subtitle := lv_subtitle;
        END IF;

        IF :new.item_id IS NULL THEN
            SELECT
                item_s1.NEXTVAL
            INTO :new.item_id
            FROM
                dual;

        END IF;

    ELSIF updating THEN
        manage_item.item_insert(pv_old_item_id => :old.item_id, pv_old_item_barcode => :old.item_barcode, pv_old_item_type => :old
        .item_type, pv_old_item_title => :old.item_title, pv_old_item_subtitle => :old.item_subtitle,
                                pv_old_item_rating => :old.item_rating, pv_old_item_rating_agency => :old.item_rating_agency, pv_old_item_release_date
                                => :old.item_release_date, pv_old_created_by => :old.created_by, pv_old_creation_date => :old.creation_date
                                ,
                                pv_old_last_updated_by => :old.last_updated_by, pv_old_last_update_date => :old.last_update_date,
                                pv_old_text_file_name => :old.text_file_name, pv_new_item_id => :new.item_id, pv_new_item_barcode
                                => :new.item_barcode,
                                pv_new_item_type => :new.item_type, pv_new_item_title => :new.item_title, pv_new_item_subtitle =>
                                :new.item_subtitle, pv_new_item_rating => :new.item_rating, pv_new_item_rating_agency => :new.item_rating_agency
                                ,
                                pv_new_item_release_date => :new.item_release_date, pv_new_created_by => :new.created_by, pv_new_creation_date
                                => :new.creation_date, pv_new_last_updated_by => :new.last_updated_by, pv_new_last_update_date =>
                                :new.last_update_date,
                                pv_new_text_file_name => :new.text_file_name);

        lv_input_title := :new.item_title;
        lv_update_needed := 0;
        IF regexp_instr(lv_input_title, ':') > 0 AND regexp_instr(lv_input_title, ':') = length(lv_input_title) THEN
        /* Shave off the colon. */
            lv_title := substr(lv_input_title, 1, regexp_instr(lv_input_title, ':') - 1);

            lv_subtitle := '';
            lv_update_needed := 1;
        ELSIF regexp_instr(lv_input_title, ':') > 0 THEN
        /* Split the string into two parts. */
            lv_title := substr(lv_input_title, 1, regexp_instr(lv_input_title, ':') - 1);

            lv_subtitle := ltrim(substr(lv_input_title, regexp_instr(lv_input_title, ':') + 1, length(lv_input_title)));

            lv_update_needed := 1;
        END IF;

        IF lv_update_needed = 1 THEN
            manage_item.item_insert(pv_old_item_id => :new.item_id, pv_old_item_barcode => :new.item_barcode, pv_old_item_type =>
            :new.item_type, pv_old_item_title => :new.item_title, pv_old_item_subtitle => :new.item_subtitle,
                                    pv_old_item_rating => :new.item_rating, pv_old_item_rating_agency => :new.item_rating_agency,
                                    pv_old_item_release_date => :new.item_release_date, pv_old_created_by => :new.created_by, pv_old_creation_date
                                    => :new.creation_date,
                                    pv_old_last_updated_by => :new.last_updated_by, pv_old_last_update_date => :new.last_update_date
                                    , pv_old_text_file_name => :new.text_file_name, pv_new_item_id => :new.item_id, pv_new_item_barcode
                                    => :new.item_barcode,
                                    pv_new_item_type => :new.item_type, pv_new_item_title => lv_title, pv_new_item_subtitle => lv_subtitle
                                    , pv_new_item_rating => :new.item_rating, pv_new_item_rating_agency => :new.item_rating_agency
                                    ,
                                    pv_new_item_release_date => :new.item_release_date, pv_new_created_by => :new.created_by, pv_new_creation_date
                                    => :new.creation_date, pv_new_last_updated_by => :new.last_updated_by, pv_new_last_update_date
                                    => :new.last_update_date,
                                    pv_new_text_file_name => :new.text_file_name);

            :new.item_title := lv_title;
            :new.item_subtitle := lv_subtitle;
        END IF;

    END IF;
END item_trig;
/

CREATE OR REPLACE TRIGGER item_delete_trig BEFORE
    DELETE ON item
    FOR EACH ROW
DECLARE
    -- Declare exception
    e EXCEPTION;
    PRAGMA exception_init ( e, -20001 );
BEGIN
    IF deleting THEN
        manage_item.item_insert(pv_old_item_id => :old.item_id, pv_old_item_barcode => :old.item_barcode, pv_old_item_type => :old
        .item_type, pv_old_item_title => :old.item_title, pv_old_item_subtitle => :old.item_subtitle,
                                pv_old_item_rating => :old.item_rating, pv_old_item_rating_agency => :old.item_rating_agency, pv_old_item_release_date
                                => :old.item_release_date, pv_old_created_by => :old.created_by, pv_old_creation_date => :old.creation_date
                                ,
                                pv_old_last_updated_by => :old.last_updated_by, pv_old_last_update_date => :old.last_update_date,
                                pv_old_text_file_name => :old.text_file_name);

    END IF;
END item_delete_trig;
/

INSERT INTO common_lookup (
    common_lookup_id,
    common_lookup_table,
    common_lookup_column,
    common_lookup_type,
    common_lookup_code,
    common_lookup_meaning,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date
) VALUES (
    common_lookup_s1.NEXTVAL,
    'ITEM',
    'ITEM_TYPE',
    'BLU-RAY',
    '',
    'Blu-ray',
    3,
    sysdate,
    3,
    sysdate
);

ALTER TABLE item DROP CONSTRAINT nn_item_4;

INSERT INTO item (
    item_id,
    item_barcode,
    item_type,
    item_title,
    item_subtitle,
    item_rating,
    item_rating_agency,
    item_release_date,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date
) VALUES (
    item_s1.NEXTVAL,
    'B01IHVPA8',
    (
        SELECT
            common_lookup_id
        FROM
            common_lookup
        WHERE
            common_lookup_table = 'ITEM'
            AND common_lookup_column = 'ITEM_TYPE'
            AND common_lookup_type = 'BLU-RAY'
    ),
    'Bourne',
    '',
    'PG-13',
    'MPAA',
    to_date('6-Dec-16'),
    3,
    sysdate,
    3,
    sysdate
);

INSERT INTO item (
    item_id,
    item_barcode,
    item_type,
    item_title,
    item_subtitle,
    item_rating,
    item_rating_agency,
    item_release_date,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date
) VALUES (
    item_s1.NEXTVAL,
    'B01AT251XY',
    (
        SELECT
            common_lookup_id
        FROM
            common_lookup
        WHERE
            common_lookup_table = 'ITEM'
            AND common_lookup_column = 'ITEM_TYPE'
            AND common_lookup_type = 'BLU-RAY'
    ),
    'Bourne Legacy:',
    '',
    'PG-13',
    'MPAA',
    to_date('5-Apr-16'),
    3,
    sysdate,
    3,
    sysdate
);

INSERT INTO item (
    item_id,
    item_barcode,
    item_type,
    item_title,
    item_subtitle,
    item_rating,
    item_rating_agency,
    item_release_date,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date
) VALUES (
    item_s1.NEXTVAL,
    'B018FK66TU',
    (
        SELECT
            common_lookup_id
        FROM
            common_lookup
        WHERE
            common_lookup_table = 'ITEM'
            AND common_lookup_column = 'ITEM_TYPE'
            AND common_lookup_type = 'BLU-RAY'
    ),
    'Star Wars: The Force Awakens',
    '',
    'PG-13',
    'MPAA',
    to_date('5-Apr-16'),
    3,
    sysdate,
    3,
    sysdate
);

COLUMN table_name FORMAT a14

COLUMN column_id FORMAT 9999

COLUMN column_name FORMAT a22

COLUMN data_type FORMAT a12

SELECT
    table_name,
    column_id,
    column_name,
    CASE
        WHEN nullable = 'N' THEN
            'NOT NULL'
        ELSE
            ''
    END AS nullable,
    CASE
        WHEN data_type IN (
            'CHAR',
            'VARCHAR2',
            'NUMBER'
        ) THEN
            data_type
            || '('
            || data_length
            || ')'
        ELSE
            data_type
    END AS data_type
FROM
    user_tab_columns
WHERE
    table_name = 'ITEM'
ORDER BY
    2;

COL logger_id FORMAT 9999 HEADING "Logger|ID #"

COL old_item_id FORMAT 9999 HEADING "Old|Item|ID #"

COL old_item_title FORMAT a20 HEADING "Old Item Title"

COL new_item_id FORMAT 9999 HEADING "New|Item|ID #"

COL new_item_title FORMAT a30 HEADING "New Item Title"

SELECT
    l.logger_id,
    l.old_item_id,
    l.old_item_title,
    l.new_item_id,
    l.new_item_title
FROM
    logger l;

COL logger_id FORMAT 9999 HEADING "Logger|ID #"

COL old_item_id FORMAT 9999 HEADING "Old|Item|ID #"

COL old_item_title FORMAT a20 HEADING "Old Item Title"

COL new_item_id FORMAT 9999 HEADING "New|Item|ID #"

COL new_item_title FORMAT a30 HEADING "New Item Title"

SELECT
    l.logger_id,
    l.old_item_id,
    l.old_item_title,
    l.new_item_id,
    l.new_item_title
FROM
    logger l;

COL common_lookup_table FORMAT a14 HEADING "Common Lookup|Table"

COL common_lookup_column FORMAT a14 HEADING "Common Lookup|Column"

COL common_lookup_type FORMAT a14 HEADING "Common Lookup|Type"

SELECT
    common_lookup_table,
    common_lookup_column,
    common_lookup_type
FROM
    common_lookup
WHERE
    common_lookup_table = 'ITEM'
    AND common_lookup_column = 'ITEM_TYPE'
    AND common_lookup_type = 'BLU-RAY';

COL item_id FORMAT 9999 HEADING "Item|ID #"

COL item_title FORMAT a20 HEADING "Item Title"

COL item_subtitle FORMAT a20 HEADING "Item Subtitle"

COL item_rating FORMAT a6 HEADING "Item|Rating"

COL item_type FORMAT a18 HEADING "Item|Type"

SELECT
    i.item_id,
    i.item_title,
    i.item_subtitle,
    i.item_rating,
    cl.common_lookup_meaning AS item_type
FROM
    item            i
    INNER JOIN common_lookup   cl ON i.item_type = cl.common_lookup_id
WHERE
    cl.common_lookup_type = 'BLU-RAY';

COL logger_id FORMAT 9999 HEADING "Logger|ID #"

COL old_item_id FORMAT 9999 HEADING "Old|Item|ID #"

COL old_item_title FORMAT a20 HEADING "Old Item Title"

COL new_item_id FORMAT 9999 HEADING "New|Item|ID #"

COL new_item_title FORMAT a30 HEADING "New Item Title"

SELECT
    l.logger_id,
    l.old_item_id,
    l.old_item_title,
    l.new_item_id,
    l.new_item_title
FROM
    logger l;

UPDATE item
SET
    item_title = 'Star Wars: The Force Awakens'
WHERE
    item_barcode = 'B018FK66TU';

COL item_id FORMAT 9999 HEADING "Item|ID #"

COL item_title FORMAT a20 HEADING "Item Title"

COL item_subtitle FORMAT a20 HEADING "Item Subtitle"

COL item_rating FORMAT a6 HEADING "Item|Rating"

COL item_type FORMAT a18 HEADING "Item|Type"

SELECT
    i.item_id,
    i.item_title,
    i.item_subtitle,
    i.item_rating,
    cl.common_lookup_meaning AS item_type
FROM
    item            i
    INNER JOIN common_lookup   cl ON i.item_type = cl.common_lookup_id
WHERE
    cl.common_lookup_type = 'BLU-RAY';

COL logger_id FORMAT 9999 HEADING "Logger|ID #"

COL old_item_id FORMAT 9999 HEADING "Old|Item|ID #"

COL old_item_title FORMAT a20 HEADING "Old Item Title"

COL new_item_id FORMAT 9999 HEADING "New|Item|ID #"

COL new_item_title FORMAT a30 HEADING "New Item Title"

SELECT
    l.logger_id,
    l.old_item_id,
    l.old_item_title,
    l.new_item_id,
    l.new_item_title
FROM
    logger l;

DELETE FROM item
WHERE
    item_barcode = 'B018FK66TU';

COL item_id FORMAT 9999 HEADING "Item|ID #"

COL item_title FORMAT a20 HEADING "Item Title"

COL item_subtitle FORMAT a20 HEADING "Item Subtitle"

COL item_rating FORMAT a6 HEADING "Item|Rating"

COL item_type FORMAT a18 HEADING "Item|Type"

SELECT
    i.item_id,
    i.item_title,
    i.item_subtitle,
    i.item_rating,
    cl.common_lookup_meaning AS item_type
FROM
    item            i
    INNER JOIN common_lookup   cl ON i.item_type = cl.common_lookup_id
WHERE
    cl.common_lookup_type = 'BLU-RAY';

COL logger_id FORMAT 9999 HEADING "Logger|ID #"

COL old_item_id FORMAT 9999 HEADING "Old|Item|ID #"

COL old_item_title FORMAT a20 HEADING "Old Item Title"

COL new_item_id FORMAT 9999 HEADING "New|Item|ID #"

COL new_item_title FORMAT a30 HEADING "New Item Title"

SELECT
    l.logger_id,
    l.old_item_id,
    l.old_item_title,
    l.new_item_id,
    l.new_item_title
FROM
    logger l;

SPOOL OFF

EXIT;