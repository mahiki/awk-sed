## 01 awk performance
slowness can depend on machine specific implementations of:

- pattern matching
- field splitting
- concatenation
- substitution

The following table of timing tests will help you refactor code for each machine.  
I'm using a 100K (4.1MB, 4.3M char) row file with 5 fields separated by tabs.

file: `rsrc/performance-test-data.txt`

```
timing in seconds, user + system total
program                                              -|- MBP OSX awk   -|- MBP gawk      -|- RHEL VM on Intel PC
------------------------------------------------------|-----------------|-----------------|---------------------
END { print NR }                                      |     0.017		|  	0.019       | 
{ n++ } END { print n }                               |     0.022		|     0.022       |
{ i=NF } END { print i }                              |     0.041		|     0.043       |
{ a+=$4; b+=$5 } END { print a, b} # aggregate        |     0.073		| 	0.087		|
{a[$2]+=$4} END {for (i in a) print a[i]}             |     0.091		|     0.103		|
wc                                                    |     0.009		|	0.008		|
```


### nawk, mawk, gawk
mawk might be good, i read that its ~5x faster. but we are pretty fast

### other tests
*on MBP laptop*
a 1 billion row file, count the distinct field $1 which are customer ids.
```
time LC_ALL=C \
awk -F'\t' \
      'NR>1 { if ($9=="existing_customer")
                  exist[$1]++
              if($9=="new_customer")
                  new[$1]++
              total[$1]++
            }
      END   { print "existing biss ab customers: " length(exist) "\n"
              print "new biss ab customers: " length(new) "\n"
              print "total biss ab customers: " length(total) "\n"
            }' ../rsrc/ab_biss_customers_YTD.txt

(14.53 seconds)
```

nice!
the same test on a 3 billion row file:
`(45.848 seconds)`


