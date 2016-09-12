## 03 data processing
AWK, Awo - Kernighan - Weinberg

### summing columns
<some stuff>

### computing percentages and quartiles, histograms
pretty straight forward, of course with 100K rows of numbers, no row has much of a % in this random data. always nice how fast, 0.5 seconds for the awk part, 1.1 seconds overall. 

```
# percent.awk
# input:  a column of non-negative numbers
# output: each number and percetage of total

	{ x[NR] = $1; sum += $1 }

END	{ if (sum != 0)
		for (i = 1; i <= NR; i++)
			printf("%10.2f %6.4f\n", x[i], 100 * x[i] / sum)
	}
```

	$> time tail -n +2 "rsrc/performance-test-data.txt" | cut -f 5 | awk -f src/percent.awk >  output.tst

it would be nice to see a histogram of data, how about student grades from 0-100. here is the code for a simple graphical histogram:

```
# histogram
# input:  numbers between 0 and 100
# output: histogram  of deciles

    {   x[int($1/10)]++ }

END {   for (i = 0; i < 10; i++)
            printf(" %2d - %2d: %3d %s\n", 10 * i, 10 * i + 9, x[i], rep(x[i], "*"))
        printf("100:       %3d %s\n", x[10], rep(x[10], "*"))
    }

function rep(n,s,   t) {        # return string of n s's
    while (n-- > 0)
        t = t s
    return t
}
```

notice the postfix operator in `n-- > 0` controls the while loop.  you would want to test for negative values in more generic usage. 

let's test `histogram.awk` on 200 random numbers from 0 to 100.

```
merlinr ❯ ➤ awk 'BEGIN {for(i=1; i<=200; i++) print int(101 * rand() )}' | awk -f src/histogram.awk

  0 -  9:  13 *************
 10 - 19:  21 *********************
 20 - 29:  22 **********************
 30 - 39:  15 ***************
 40 - 49:  27 ***************************
 50 - 59:  16 ****************
 60 - 69:  20 ********************
 70 - 79:  20 ********************
 80 - 89:  17 *****************
 90 - 99:  27 ***************************
100:         2 **
```

#### excercizes
- [ ]	**3.5**	scale the rows of stars so they don't overflow line length when there's a lot of data.  
- [ ] **3.6** 	make a version of the histogram that divides the input into a specifieed number of buckets, adjusting the ranges to the data seen.
- [ ] **3.7**	the lone 100 bucket isn't right, fix that too.

