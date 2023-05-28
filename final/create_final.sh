#!/usr/bin/bash

## ======================================================================
##  Name:    create_final.sh
##  Author:  Michael McLaughlin
##  Date:    02-Apr-2020
## ------------------------------------------------------------------
##  Purpose: Provide an example with proper error checking.
## ======================================================================

# Assign user and password
username="student"
password="student"
directory="/home/student/Data/cit325/final"

echo "User name:" ${username}
echo "Password: " ${password}
echo "Directory:" ${directory}

# Define arrays.
declare -a cmd
declare -a log

# Assign elements to a command array.
cmd[0]="tools/object_cleanup.sql"
cmd[1]="base_t.sql"
cmd[2]="dwarf_t.sql"
cmd[3]="elf_t.sql"
cmd[4]="goblin_t.sql"
cmd[5]="hobbit_t.sql"
cmd[6]="maia_t.sql"
cmd[7]="man_t.sql"
cmd[8]="orc_t.sql"
cmd[9]="noldor_t.sql"
cmd[10]="silvan_t.sql"
cmd[11]="sindar_t.sql"
cmd[12]="teleri_t.sql"
cmd[13]="create_tolkien.sql"
cmd[14]="type_validation.sql"
cmd[15]="insert_instances.sql"
cmd[16]="query_instances.sql"

# Assign elements to a log array.
log[0]="object_cleanup.txt"
log[1]="base_t.txt"
log[2]="create_tolkien.txt"
log[3]="type_validation.txt"
log[4]="insert_instances.txt"
log[5]="query_instances.txt"

# Call the command array elements.
for i in ${cmd[*]}; do
  # Print the file to show progress and identify fail point.
  if ! [[ -f ${i} ]]; then
    echo "File [${i}] is missing."
  else
    sqlplus -s ${username}/${password} @${directory}/${i} > /dev/null
  fi
done

# Display the log array elements to console.
for i in ${log[*]}; do
  if [[ -f ${i} ]]; then
    cat ${i}
  else
    echo "File [${i}]."
  fi
done
