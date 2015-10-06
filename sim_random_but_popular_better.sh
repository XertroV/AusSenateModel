if [ $# -lt 2 ]
  then
    echo "Useage: run_simulation_parallel.sh TRIALS_N YEAR"
    exit
fi

start_timestamp=`date +%s`

trial="rand-pop"  # minpref is 3.1, test across FPR

N=$1
year=$2
hp="--half-participation"
#hp=""
minpref=3.1

echo "Starting NVB Simulation, $N trials per data-point"
echo ""
echo "Using as half participation flag: '$halfpartic'"

function resultsname {
  # generate name of results file
  year=$1
  fpr=$2
  echo "all.results-$trial-$year-$fpr"
}

function runmain {
    # are these local? will the break outside stuff?
    file=$1
    pc=$2
    state=$3
    year=$4
    fpr=$5
    echo "Started: $state-$pc"
    python3 -m dg main.dg --summary --loop $N --pc-yes $pc --first-pref-ratio $fpr --nvb $hp --min-preference $minpref "$year/$state-gvts.csv" "$year/$state-first-prefs.csv" >> $file
    echo `cat $file | grep NVB | wc -l` ",$N,$state,$pc%" >> `resultsname $year $fpr`
    echo "Finished: $state-$pc-$fpr"
}

echo "Cleaning..."

rm all.results* &>/dev/null

echo "Starting..."

fprlist=(0.005 0.01 0.02 0.03 0.05)

for fpr in ${fprlist[*]}; do
  for state in TAS SA NSW VIC WA QLD; do
    for pc in 05 15 25 35 45 55 65 75 85 95; do
      file="$year/results-sim-$trial-$state-$pc-$fpr.txt"
      echo $file
      rm $file &>/dev/null
      runmain $file $pc $state $year $fpr &
      sleep 0.05
    done
    wait
  done
  rname=`resultsname $year $fpr`
  iname="img_$rname.svg"
  tname="tmp_$rname"
  cat $rname | python format_results.py --spaces > $tname
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
  set title 'Partic. v P(Success), {/*0.5 params: fpr $fpr; year $year; trial $trial; N $N; minpref $minpref;}'
  
  plot for [col=2:7] '$tname' using 1:col with linespoints ls 1 lc col pt col ps 1" | gnuplot
  echo "Plotted $iname"
  rm $tname
done

end_timestamp=`date +%s`

echo "COMPLETE"
echo "Duration " "`eval $end_timestamp - $start_timestamp`" " seconds"
