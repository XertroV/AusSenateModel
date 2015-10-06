# NVB Senate Model

The senate model will take data from the AEC and evaluate the election. It also allows experimenting with elections by:

* Using the Senate Preference Hack
 * including various simulation options such as an envelope or best and worst case.
* Changing the number of first preferences a party receives
 * protip: investigate min-max bounds for MEP in VIC 2013

Everything should be trial-able with `sim_lib.sh`

```
./sim_lib.sh "ENV_PESSIMISTIC" "1" "2013" '--summary --nvb --min-preference 6.1 --max-preference 20.1'
./sim_lib.sh "ENV_OPTIMISTIC" "1" "2013" '--summary --nvb --min-preference 6.1 --max-preference 20.1 --half-preference'
```


It runs using dg (http://pyos.github.com/dg) on python3.
