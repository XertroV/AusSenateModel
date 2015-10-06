#!/usr/bin/env bash
set -e

# pass in all args
if [ $# -lt 2 ]
  then
    echo "Useage: run_simulation_parallel.sh TRIAL_NAME TRIALS_N YEAR MAIN.DG_PARAMS"
    echo "Note: PARAMS should not include the last two arguments: csv files - they will be added automatically, or any of:"
    echo "      --first-pref-ratio --pc-yes --loop"
    echo "Example params: --summary --nvb --half-participation --min-preference 6.1 --max-preference 20.1"
    echo 'With variables --summary $hp --nvb --min-preference $minpref --max-preference $maxpref'
    exit
fi

start_timestamp=`date +%s`

TRIAL=$1
N=$2
YEAR=$3
PARAMS=$4

echo "starting $TRIAL for $YEAR with $N samples" >> img_timestats
echo "and params: $PARAMS" >> img_timestats
echo "$start_timestamp" >> img_timestats

echo "Starting NVB Simulation, $N trials per data-point"
echo ""
echo "Using command 'dg main.dg $PARAMS'"

function resultsname {
  # generate name of results file
  year=$1
  fpr=$2
  echo "all.results-$TRIAL-$year-$fpr"
}

function runmain {
    # are these local? will the break outside stuff?
    file=$1
    pc=$2
    state=$3
    year=$4
    fpr=$5
    echo "Started: $state-$pc"
    python3 -m dg main.dg --loop $N $PARAMS --pc-yes $pc --first-pref-ratio $fpr --nvb "$year/$state-gvts.csv" "$year/$state-first-prefs.csv" >> $file
    echo `cat $file | grep NVB | wc -l` ",$N,$state,$pc%" >> "`resultsname $year $fpr`"
    echo "Finished: $state-$pc-$fpr"
}

echo "Cleaning..."

rm -f all.results* &>/dev/null

echo "Starting..."

fprlist=(0.005 0.01 0.02 0.03 0.05)


for fpr in ${fprlist[*]}; do
  for state in TAS SA NSW VIC WA QLD; do
    for pc in 05 15 25 35 45 55 65 75 85 95; do
      file="$YEAR/results-sim-$TRIAL-$state-$pc-$fpr.txt"
      echo $file
      rm -f $file &>/dev/null
      runmain $file $pc $state $YEAR $fpr 2>> exceptions.log &
      sleep 0.05
    done
    wait
  done
  rname=`resultsname $YEAR $fpr`
  iname="img_$rname.svg"
  tname="tmp_$rname"
  echo "$rname"
  echo "$iname"
  echo "$tname"
  cat "$rname" | python3 format_results.py --spaces > "$tname"
  echo "
  set key autotitle columnhead outside
  set terminal svg size 1000,600 fname 'open-sans, sans-serif' fsize '20' rounded dashed
  set output '$iname'

  set object 1 rectangle from screen 0,0 to screen 1,1 fillcolor rgb'white' behind

  # remove border on top and right and set color to gray
  set style line 11 lc rgb '#808080' lt 1
  set border 3 back ls 11
  set tics nomirror
  # define grid
  set style line 12 lc rgb '#808080' lt 0 lw 1
  set grid back ls 12

  # color definitions
  #set style line 1 lc rgb '#8b1a0e' pt 1 ps 1 lt 1 lw 5 # --- red
  #set style line 2 lc rgb '#5e9c36' pt 6 ps 1 lt 1 lw 5 # --- green
  set style line 1 lw 5

  set xlabel 'Participation %'
  set ylabel 'P(Win 1 Seat)'
  set title 'Partic. v P(Success), {/*0.4 params: FPR $fpr; y $YEAR; $TRIAL; N $N; main.dg $PARAMS;}'

  plot for [col=2:7] '$tname' using 1:col with linespoints ls 1 lc col pt col ps 1" | gnuplot
  echo "Plotted $iname"
  rm "$tname"
done

end_timestamp=`date +%s`

echo "COMPLETE"
echo "$end_timestamp" >> img_timestats
echo "Duration " "`expr $end_timestamp - $start_timestamp`" " seconds"
