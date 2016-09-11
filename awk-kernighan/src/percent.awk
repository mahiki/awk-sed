# percent
# input:  a column of non-negative numbers
# output: each number and percetage of total

    { x[NR] = $1; sum += $1 }

END { if (sum != 0)
        for (i = 1; i <= NR; i++)
            printf("%10.2f %6.4f\n", x[i], 100 * x[i] / sum)
    }
