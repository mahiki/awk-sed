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
program                                              -|- MBP awk-|- MBP gawk-|- ubuntu -|- RHEL VM* -|- m4.2xlarge        
------------------------------------------------------|----------|-----------|----------|------------|--------------
END { print NR }                                      |   0.017  |     0.019 |   0.011  |  0.426 *   |  0.017
{ n++ } END { print n }                               |   0.022  |     0.022 |   0.014  |  0.431     |  0.020    
{ i=NF } END { print i }                              |   0.041  |     0.043 |   0.025  |  0.447     |  0.032  
{ a+=$4; b+=$5 } END { print a, b} # aggregate        |   0.073  |     0.087 |   0.039  |  0.052     |  0.073
{a[$2]+=$4} END {for (i in a) print a[i]} # to file   |   0.091  |     0.103 |   0.056  |  0.467     |  0.075
wc                                                    |   0.009  |     0.008 |   0.007  |  0.003     |  0.052
# note: using the 'real' timing, not sys or user
# m4.2xlarge is 8 CPU and 32G memory
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


### ubuntu machine
      less /proc/cpuinfo
      Intel(R) Core(TM) i5-4570 CPU @ 3.20GHz         # four cores
can't get the RHEL going, but a can get to ubuntu right now. first copy the file

      scp ~/repo/awk-sed/awk-kernighan/rsrc/performance-test-data.txt merlinr@uf8bc126ce5c9538634f8:~/Desktop

now I have the data file and can run those tests.

      time awk 'END { print NR }' performance-test-data.txt

OK its faster, from 1x to 2x

### RHEL machine
its working again, ssh/config update i guess

      # two cores, and 1/2 the RAM available on this VM

      scp ~/repo/awk-sed/awk-kernighan/rsrc/performance-test-data.txt merlinr@merlinr.desktop.amazon.com:/home/merlinr/Desktop/awk_workspace

run tests, see table above. multiple runs giving high variance, some even negative. the results don't look reliable.

