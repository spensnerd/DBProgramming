/*
||  Name:          apply_plsql_lab4.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 5 lab.
*/

-- Call seeding libraries.
@$LIB/cleanup_oracle.sql
@$LIB/Oracle12cPLSQLCode/Introduction/create_video_store.sql

-- Open log file.
SPOOL apply_plsql_lab4.txt


SET SERVEROUTPUT ON SIZE UNLIMITED 

CREATE OR REPLACE --Created the structure or object to store the day_name collection and the gift_name collection
    TYPE gift IS OBJECT
        ( day_name       VARCHAR2(8)
        , gift_name      VARCHAR2(24));
/
DECLARE
    TYPE song IS TABLE OF gift; 
    x   NUMBER := 0; --A counter variable for use in the nested FOR LOOP
    lv_song SONG := song( gift('first', 'Partridge in a pear tree' )
                        , gift('second', 'Two Turtle doves')
                        , gift('third', 'Three French hens')
                        , gift('fourth', 'Four Calling birds')
                        , gift('fifth', 'Five Golden rings')
                        , gift('sixth', 'Six Geese a laying')
                        , gift('seventh', 'Seven Swans a swimming')
                        , gift('eighth', 'Eight Maids a milking')
                        , gift('ninth', 'Nine Ladies dancing')
                        , gift('tenth', 'Ten Lords a leaping')
                        , gift('eleventh', 'Eleven Pipers piping')
                        , gift('twelfth', 'Twelve Drummers drumming'));
BEGIN
    FOR i IN 1..lv_song.COUNT LOOP 
        dbms_output.put_line('On the '||lv_song(i).day_name||' day of Christmas my true love sent to me:'); 
        IF i = 1 THEN --This checks to see if it is the first verse of the song 
            dbms_output.put_line('-A '||lv_song(i).gift_name); 
            dbms_output.put_line(CHR(13));
        ELSE
            x := i; --Set the value of x equal to the value of i
            FOR i IN REVERSE 1..x LOOP
                IF i = 1 THEN 
                    dbms_output.put_line('-and a '||lv_song(i).gift_name); 
                    dbms_output.put_line(CHR(13));
                ELSE            
                    dbms_output.put_line('-'||lv_song(i).gift_name); --The output for all but the last line of each verse.                    
                END IF;
            END LOOP;
        END IF;
    END LOOP;
END;
/

-- Close log file.
SPOOL OFF
