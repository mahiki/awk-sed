## awk - aggregate to reduce groups
*i have a standard DW outputfile with many rows, trying to shrink it by aggregating one column value, so team can load fewer rows into excel*

----
### simple awk aggregates

    example table
    3M      1000    45.00
    Litt    1000    10.00
    Zebra   2000    5.00
    3M      2000    1.50
    Litt    2000    300.00
    Zebra   3000    0.13

*sum of column 3 total*

	awk '{x+=$3} END {print x}' filename.txt

*list unique values of column 1*

	awk '{a[$1];} {for (i in a)print i;}' filename.txt | sort -u

*sum of columns by one group*

	awk '{a[$1]+=$3;} END {for (i in a)print i, a[i];}' filename.txt

    3M      46.5
    Litt    310
    Zebra   5.13

*sum of column by two groups* - insert a column for cohort, then

    3M      a2014   1000    45.00
    Litt    a2014   1000    10.00
    Zebra   a2014   2000    5.00
    3M      a2015   2000    1.50
    Litt    a2014   2000    300.00
    Zebra   a2015   3000    0.13

	awk '{  a[$1,"\t",$2]+=$4;} END {for (i in a)print i, a[i];}' filename.txt

    Litt    a2014 310
    3M      a2014 45
    3M      a2015 1.5
    Zebra   a2014 5
    Zebra   a2015 0.13

obviously this can get cumbersome with a lot of columns to aggregate, or groups

----
### dealing with a big-ass file with many values

**columns headings, and column numbers** we have month, cohort, brand, category.
assume we want to aggregate across category; keep only `AWAS_RET, SHP_GMS_RET, SHP_UNITS_RET`, out of many.

    wc -l datafile
        1665122     ASIN_cohort_category_brand_GMS_AWAS_monthly.txt

there are four dimensions of groups, column 1-4. the rest are values.

    1   MONTH_YR *              10  SHP_GMS_MFN
    2   COHORT *                11  SHP_GMS_FBA
    3   BRAND *                 12  SHP_GMS_3P
    4   CATEGORY X              13  SHP_GMS_RET *
    5   AWAS_MFN                14  SHP_GMS_TOT
    6   AWAS_FBA                15  SHP_UNITS_MFN
    7   AWAS_3P                 16  SHP_UNITS_FBA
    8   AWAS_RET *              17  SHP_UNITS_3P
    9   AWAS_TOT                18  SHP_UNITS_RET *
                                19  SHP_UNITS_TOT

#### aggregate down the category group
we want aggregate down the `$4 category`. store the new headings we'll keep first, pre-pending to files is awkward.

`LC_ALL=C` fixes your unicode problem, these files be dutty. assume its always used in examples.

`head -n1 datafile.txt | awk 'BEGIN { FS=OFS="\t";} {print $1, $2, $3, $4, $8, $13, $18;}' > headings.txt`

the `FS`,`OFS` variables set the index delimiter, we like tabs, the datafile is **tdt.**
the array index just becomes a concatenated string, a distinct key for each group.
its a hassle to build these for each column, but it works.

you can also use `awk -F '\t'` instead.  it works.

to validate using excel (which is too slow on big files), use only the 2014 and 2015 rows, so you can check your results in excel. also use only `2014asins`, `2015asins`, and only `FEB,MAR,APR`. **this is a test to validate results vs excel**

    LC_ALL=C awk -F '[-\t]' '$3 ~ /14|15/ && ($4 == "2014asins" || $4 == "2015asins")  {print;}' datafile.txt | LC_ALL=C sort -t$'-' -k3nr -k2nr > data2014-15.txt

    awk -F '[-\t]' '$2 ~ /FEB|MAR|APR/  {print;}' data2014-15.txt > smalldata2014-15.txt
    wc -l smalldata2014-15.txt
        92537 smalldata2014-15.txt

now we aggregate the category column out of it.  for our test we only want columns

    awk 'BEGIN {FS=OFS="\t";} {print $1, $2, $3, $4, $8, $13, $18;}' smalldata2014-15.txt > smalldata.txt

let's aggregate. column `$4` gets left out, columns `$5 $6 $7` get summed up

    awk 'BEGIN {FS=OFS="\t";} {a[$1,"\t",$2,"\t",$3]+=$5; b[$1,"\t",$2,"\t",$3]+=$6; c[$1,"\t",$2,"\t",$3]+=$7} END {for (i in a) print i, a[i], b[i], c[i];}' smalldata.txt > smalldata-grouped.txt

    wc -l smalldata.txt smalldata-grouped.txt 
        92537 smalldata.txt
        67228 smalldata-grouped.txt

i expected more contraction by summing 23 categories down to one, but i suppose most brands are in few cats. testing this in excel... 

pivoting the full `data14-15.txt` file for top brands, and comparing to the `awk`-grouped data:

    Sum of SHP_GMS_RET  
    Row Labels  Total
    XYZprinting 5570174.31
    Printrbot   3006993.3
    3M Littmann 2895145.71
    Grand Total 117611381.5

    Sum of SHP_GMS_RET  
    Row Labels  Total
    XYZprinting 5570170.6
    Printrbot   3006992.66
    3M Littmann 2895146.85
    Grand Total 117611377.3
    total-brands 31079

not exact, but close.

selecting `MONTH_YR/COHORT/BRAND` of Apr-15/2014asins/Sandusky Lee

    Sandusky Lee   73666.36

    Sandusky Lee   73666.4

**Nice!** a few spot checks show good results after getting categories grouped in excel and `awk`.

**this is a successful way to group and aggregate data**

**some weird things** the  symbol i'm getting in processed data, `01-APR-15`, causes problems with column format in excel. this happens when you use `FS` in the index.  just use `"\t"` instead.


### sort the date row, truncate, append recent data to header
alternately, we can reverse sort the dates and truncate the file, keeping only the last 3 years. store the complete headings `head -n1 datafile.txt > filesname.txt`, we'll append results to it as prepending is a no-go.

first the sort test.  take a random 1/10000th sample of rows for dates:

    tail -n +2 datafile.txt | awk 'BEGIN {srand()} !/^$/ { if (rand() <= .000001) print $0}' > testfile.txt

dates are in a `01-JUN-13` format. awk flags must specify delimeter of date structure to access year first, then month. it has a regex delimiter

    sort -t$'[-/t]' -k3n -k2M

so to get only the latest months at top of file, with header, and then truncate at 1M rows for excel user:

    head -n1 datafile.txt > cohort-latest-months.txt
    LC_ALL=C tail -n +2 datafile.txt | sort -t$'[-\t]' -k3nr -k2Mr >> cohort-latest-months.txt
    head -n1000000 cohort-latest-months.txt

they can trim off the unneeded months in excel now.

**DONE**


### figure out how to pull only '2015asins' rows
*I'll play with the 2015 data only, use excel to check results*

`awk '/2015asins/{print $1,$2,$3,$4,$8,$13,$18}' > cohort-2015`   (this takes a long time)

`awk '$2 == "2015asins" {print $0}' datafile.txt > cohort-2015.txt` (fast)

*prepending the header row requires a rewrite, so just do it first instead*

    head -n1 datafile.txt cohort-2015-with-header.txt
    awk '$2 == "2015asins" {print $0}' datafile.txt >> cohort-2015-with-header.txt
    wc -l cohort-2015-with-header.txt
      121083 cohort-2015-with-header.txt

*now test the aggregates on `SHP_GMS_RET`*

total sum:

`tail -n +2 cohort-2015.txt | awk 'BEGIN { FS=OFS="\t";} {x+=$13;} END {printf "%8.2f\n",x}'`

gives `22311771.20` **EXACT MATCH**
*the delimiter choice is important, default put me in the wrong row*


**DANGER** the whitespace in a field will show up as a delimiter, so you can hit an earlier than expected column!

category:
pipe the file minus header row to awk, then sort categories

    tail -n +2 cohort-2015.txt | awk 'BEGIN { FS=OFS="\t";} {b[$4]+=$13;} END {for (i in b) print i, b[i];}' | sort > category-sums.txt
    wc -l category-sums.txt
        24 category-sums.txt

**MATCHES EXCEL RESULTS, error < 0.001%**  looks good, e+06 formatting adds roundoff errors

### in summary
I've figured out how to quickly combine categories, but with many columns it because a big manual construction.  With more study I can learn to handle any size table, and provide quick summary data an pivots without opening excel.