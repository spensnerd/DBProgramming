-- ======================================================================
--  Name:    insert_instances.sql
--  Author:  Michael McLaughlin
--  Date:    02-Apr-2020
-- ------------------------------------------------------------------
--  Purpose: Prepare final project environment.
-- ======================================================================

-- Open the log file.
SPOOL insert_instances.txt

SET SERVEROUTPUT ON SIZE UNLIMITED
SET VERIFY OFF
SET DEFINE ON

 -- Insert instance of the object type into tolkien table.
INSERT INTO tolkien VALUES (
    tolkien_s.NEXTVAL,
    man_t(name => 'Boromir', genus => 'Men')
);

INSERT INTO tolkien VALUES (
    tolkien_s.NEXTVAL,
    man_t(name => 'Faramir')
);

INSERT INTO tolkien VALUES (
    tolkien_s.NEXTVAL,
    hobbit_t(name => 'Bilbo')
);

INSERT INTO tolkien VALUES (
    tolkien_s.NEXTVAL,
    hobbit_t(name => 'Frodo', genus => 'Hobbits')
);

INSERT INTO tolkien VALUES (
    tolkien_s.NEXTVAL,
    hobbit_t(name => 'Merry')
);

INSERT INTO tolkien VALUES (
    tolkien_s.NEXTVAL,
    hobbit_t(name => 'Pippin', genus => 'Hobbits')
);

INSERT INTO tolkien VALUES (
    tolkien_s.NEXTVAL,
    hobbit_t(name => 'Samwise')
);

INSERT INTO tolkien VALUES (
    tolkien_s.NEXTVAL,
    dwarf_t(name => 'Gimli', genus => 'Dwarves')
);

INSERT INTO tolkien VALUES (
    tolkien_s.NEXTVAL,
    noldor_t(name => 'Feanor')
);

INSERT INTO tolkien VALUES (
    tolkien_s.NEXTVAL,
    silvan_t(name => 'Tauriel', genus => 'Elves', elfkind => 'Silvan')
);

INSERT INTO tolkien VALUES (
    tolkien_s.NEXTVAL,
    teleri_t(name => 'Earwen')
);

INSERT INTO tolkien VALUES (
    tolkien_s.NEXTVAL,
    teleri_t(name => 'Celeborn', genus => 'Elves', elfkind => 'Teleri')
);

INSERT INTO tolkien VALUES (
    tolkien_s.NEXTVAL,
    sindar_t(name => 'Thranduil')
);

INSERT INTO tolkien VALUES (
    tolkien_s.NEXTVAL,
    sindar_t(name => 'Legolas', genus => 'Elves', elfkind => 'Sindar')
);

INSERT INTO tolkien VALUES (
    tolkien_s.NEXTVAL,
    orc_t(name => 'Azoth the Defiler')
);

INSERT INTO tolkien VALUES (
    tolkien_s.NEXTVAL,
    orc_t(name => 'Bolg', genus => 'Orcs')
);

INSERT INTO tolkien VALUES (
    tolkien_s.NEXTVAL,
    maia_t(name => 'Gandalf the Grey')
);

INSERT INTO tolkien VALUES (
    tolkien_s.NEXTVAL,
    maia_t(name => 'Radagast the Brown', genus => 'Maiar')
);

INSERT INTO tolkien VALUES (
    tolkien_s.NEXTVAL,
    maia_t(name => 'Saruman the White')
);

INSERT INTO tolkien VALUES (
    tolkien_s.NEXTVAL,
    goblin_t(name => 'The Great Goblin', genus => 'Goblins')
);

INSERT INTO tolkien VALUES (
    tolkien_s.NEXTVAL,
    man_t(name => 'Aragorn', genus => 'Men')
);
-- Close the log file.

SPOOL OFF

quit;