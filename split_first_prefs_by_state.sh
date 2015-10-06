#!/bin/bash

echo 'Useage: sh split_first_prefs_by_state.sh <aec-senate-first-prefs.csv>'
echo 'Working...' 

function push_to_file {
  echo $1 >> $(echo $1 | cut -d ',' -f 1)-first-prefs.csv
}

cat $1 | tail -n +3 | grep 'Ticket Votes' > just_tickets.csv

while read l; do
  push_to_file "$l"
done < just_tickets.csv

echo 'Done!'
