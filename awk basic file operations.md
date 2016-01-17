# awk - random informative examples
*its all about big file outputs from ETL, and chunking them down quickly* 

we'll call the data file `data.txt`, it will be general tab-delimited text, with unicode. this means you always need these in front of your `awk`, `sort`, `cut` commands, etc.

    LC_ALL=C

you can see how this works with `LC_ALL=C locale`

for awk you always have to set the delimiters `FS`, `OFS` for tabs

    BEGIN {FS=OFS="\t";}

----
### count unique values in a column
you can do it with bash only. the delimiter flag is`-d$'\t'` is for tab in this case. this gives all the unique values of column 1, and `uniq -c` gives a count of each value.

    LC_ALL=C cut -f1 -d$'\t' data.txt | sort | uniq -c

or with awk, and using the `-F` delimiter flag

    LC_ALL=C awk -F '\t' '{print $1}' data.txt | sort | uniq -c | sort -nr

from now on assume we are using `LC_ALL=C` all the time. you are likely to get trouble on a big file with utf-8 encoding. simplify your problems by **setting the `LC_ALL` environment variable** in your command.

----
### selecting only rows that match
a quick way to deal with an unmanageable set. first column is date `01-SEP-14` and we want all of 2015 results. let's preserve the header by grabbing it first. then make a regex match.

    head -n1 data.txt > data2015.txt

    awk -F '\t' '$1 ~ /..-...-15/ {print;}' data.txt >> data2015.txt

alternately, by using the date delimiter and exact match:

    awk -F '[-\t]' '$3 == "15" {print;}' data.txt >> data2015.txt

a little tricky - the separator is a hyphen `-` or tab `\t`, you need a separator after the date field. how about all the year 2014 or 2015 results?

    LC_ALL=C awk -F '[-\t]' '$3 ~ /14|15/ {print;}' data.txt | LC_ALL=C sort -t$'-' -k3nr -k2nr >> data2014-2015.txt

**nice!** i'll explain the sort later, notice you need `LC_ALL=C` in both commands.

----
### multiple delimiters
this will recognise '/' or '=' as a delimiter in a file, because the delimiter can be a regex:

    /logs/tc0001/tomcat/tomcat7.1/conf/catalina.properties:app.env.server.name = demo.example.com
    /logs/tc0001/tomcat/tomcat7.2/conf/catalina.properties:app.env.server.name = quest.example.com
    /logs/tc0001/tomcat/tomcat7.5/conf/catalina.properties:app.env.server.name = www.example.com

    cat data.txt | awk -F '[/=]' '{print $3 "\t" $5 "\t" $8}'

    tc0001   tomcat7.1    demo.example.com  
    tc0001   tomcat7.2    quest.example.com  
    tc0001   tomcat7.5    www.example.com

----
### randomly selecting rows

randomly take 0.001%, keep header row

    awk 'BEGIN {srand()} !/^$/ { if (rand() <= .00001 || FNR==1) print $0}' data.txt

without header row

    tail -n +2 data.txt | awk 'BEGIN {srand()} !/^$/ { if (rand() <= .00001) print $0}'

----
### sorting by date

take our random rows from above and work on the sort of first column date field.

dates are in a `01-JUN-13` format. awk flags must specify delimeter of date structure to access year first, then month.

    sort -t$'-' -k3n -k2M data.txt

pretty simple, sort number in 3rd field, month in second field.  if dates were YYYY-MM-DD it would be easier. if we want to sort descending...

    sort -t$'-' -k3nr -k2Mr data.txt

- [ ]  i'd like to include both delimiters in the sort `-` and `\t`.

----
### aggregating out some groups

we have a file too big for excel. we can shrink it by aggregating unwanted groups like category or date. consider this example file `data.txt`, from which you already pulled `headings.txt`:

    brand   cohort  category    gms     awas
    3M      a2014   1000        45.00   2
    Litt    a2014   1000        10.00   3
    Zebra   a2014   2000        5.00    6
    3M      a2015   2000        1.50    1
    3M      a2015   3000        10.50   1
    Litt    a2014   2000        300.00  12
    Zebra   a2015   3000        0.13    1

    tail -n +2 data.txt | awk 'BEGIN {FS=OFS="\t";} { a[$1,FS,$2]+=$4;b[$1,FS,$2]+=$5;}END{for (i in a)print i, a[i], b[i];}' >> headings.txt

    Litt    a2014   310     15
    3M      a2014   45      2
    3M      a2015   12      2
    Zebra   a2014   5       6
    Zebra   a2015   0.13    1

**categories begone!** the delimeter stuff at the beginning turns out to be pretty important. your file will have fields with whitespace - then you are f'd man! but no, thanks to `FS`.

**one last complication** the  symbol you get at the beginning and ending of fields. hmmm.
