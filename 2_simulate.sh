echo "Enter state abbreviation in caps (I.E. NSW, NT, TAS, QLD, VIC, WA, ACT, SA)"
read -p "> " state
python -m dg main.dg "$state-gvts.csv" "$state-first-prefs.csv"
