SELECT   table_name
FROM     user_tables
WHERE    table_name NOT IN ('EMP','DEPT','ACCOUNT_LIST','CALENDAR','AIRPORT','TRANSACTION','PRICE')
AND NOT  table_name LIKE 'DEMO%'
AND NOT  table_name LIKE 'APEX%'
ORDER BY table_name; 
