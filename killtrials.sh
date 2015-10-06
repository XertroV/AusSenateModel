for pid in `ps ax | grep main.dg | sed 's/ \+/ /g' | sed 's/^ //g' | cut -d ' ' -f 1`; do kill $pid; echo $pid; done
