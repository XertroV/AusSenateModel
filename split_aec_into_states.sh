#!/bin/bash

echo 'Usage: sh split_aec_into_states.sh <senate-gvts.csv>'
echo 'working...'

function push_to_file {
  echo $1 >> $(echo $1 | cut -d ',' -f 1)-gvts.csv
}

cat $1 | tail -n +3 > just_prefs.csv

while read l; do
  push_to_file "$l"
done < just_prefs.csv

echo 'Done!'
