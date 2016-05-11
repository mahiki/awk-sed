## 01 awk performance
slowness can depend on machine specific implementations of:

- pattern matching
- field splitting
- concatenation
- substitution

The following table of timing tests will help you refactor code for each machine.  
I'm using a 100K (4.1MB, 4.3M char) row file with 5 fields separated by tabs.

```
timing in seconds, user + system total
program                                              -|- MBP           -|- RHEL VM on Intel PC
------------------------------------------------------|-----------------|----------------------------------------------
END { print NR }                                      |     0.017
{ n++ } END { print n }                               |     0.022
{ i=NF } END { print i }                              |     0.041
{ a+=$4, b+=$5 } END { print a, b} # aggregate        |     0.073
{a[$2]+=$4} END {for (i in a) print a[i]}             |     0.091
wc command                                            |     0.009
```


