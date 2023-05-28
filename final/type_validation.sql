-- ======================================================================
--  Name:    type_validation.sql
--  Author:  Michael McLaughlin
--  Date:    02-Apr-2020
-- ------------------------------------------------------------------
--  Purpose: Prepare final project environment.
-- ======================================================================

/* Set environment variables. */
SET LINESIZE 72

SET PAGESIZE 999
 
/* Write to log file. */

SPOOL type_validation.txt

COL name FORMAT a16 HEADING "Base|Object Name"

COL referenced_name FORMAT a12 HEADING "Referenced|Object Name"

COL referenced_type FORMAT a12 HEADING "Referenced|Object Type"

COL TYPE FORMAT a10 HEADING "Object|Type"

COL status FORMAT a8 HEADING "Status"

SELECT
    ud.name,
    ud.type,
    CASE
        WHEN ud.referenced_name = 'STANDARD' THEN
            NULL
        ELSE
            ud.referenced_name
    END AS referenced_name,
    CASE
        WHEN ud.referenced_type = 'PACKAGE' THEN
            NULL
        ELSE
            ud.referenced_type
    END AS referenced_type,
    uo.status
FROM
    user_dependencies   ud
    INNER JOIN user_objects        uo ON ud.name = uo.object_name
                                  AND ud.type = uo.object_type
WHERE
    ( ud.name = 'BASE_T'
      AND ud.type = 'TYPE'
      AND ud.referenced_name = 'STANDARD'
      OR ud.name LIKE '%_T'
      AND ud.type = 'TYPE'
      AND NOT referenced_name = 'STANDARD' )
ORDER BY
    CASE
        WHEN name = 'BASE_T'   THEN
            1
        WHEN name = 'DWARF_T'  THEN
            2
        WHEN name = 'ELF_T'    THEN
            3
        WHEN name = 'GOBLIN_T' THEN
            4
        WHEN name = 'HOBBIT_T' THEN
            5
        WHEN name = 'MAIA_T'   THEN
            6
        WHEN name = 'MAN_T'    THEN
            7
        WHEN name = 'ORC_T'    THEN
            8
        WHEN name = 'NOLDOR_T' THEN
            9
        WHEN name = 'SILVAN_T' THEN
            10
        WHEN name = 'SINDAR_T' THEN
            11
        WHEN name = 'TELERI_T' THEN
            12
    END,
    type,
    referenced_name DESC;
 
/* Close log file. */

SPOOL OFF
 
/* Close connection. */

QUIT