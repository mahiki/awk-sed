## parsing csv with awk
**its a nightmare**

### **DONE**
To read and process a csv with quoted fields, newlines in fields, etc. and output as CSV or TSV

```bash
/Users/merlinr/repo/awk-sed/csv-parsing/awk-parse-csv.awk
usage: ./awk-parse-csv.awk datafile.csv
```

###### rsrc
[SO: parse csv with comma in field](https://stackoverflow.com/questions/4351434/parse-a-csv-file-that-contains-commans-in-the-fields-with-awk)
*does it work with newlines in field?*

### the awk
***establish record separator as regex***

```bash
awk 'BEGIN { FS = "\",\"|^\""; RS = "\"\n" } {print NF " : " $0 }' testfile.csv

```

### test
```bash
# normal embedded comma, second to last line has embed newline
# 5 rows, 3 fields each
# HOW TO INCLUDE NEWLINE?

# /Users/merlinr/repo/awk-sed/csv-parsing/testfile.csv
# NF: 5, 6, 5, 6, 5
"amazon.com","amazon.com","kadarm","pwoe83833",""
"amazon.com shopper","amazon.com","kpaiiha","kpaiiha@gmail.com","pwd84848",""
"amzn biss virt","amazon.com","BISS_RO","Zer0$chance","ETLM: BISS_ETL is the virt name
BISS_BI_RO: Zer0$chance
BISS_BI_DDL: zer0$chancE
BISS_BI_DML: zer0$chancE"
"photobucket.com","photobucket.com","kadarm-amazon","kadarm@amazon.com","as8d9uf9",""
"prophetservices.com golf registration seattle","prophetservices.com","mdr8001@mac.com","faw4v334","Premier Golf Seattle
http://www.premiergc.com/
"
awk 'BEGIN { FS = "\",\"|^\""; RS = "\"\n" } {print NF " : " $0 }' testfile.csv
# strips away the trailing "
6 : "amazon.com","amazon.com","merlinr","pwoe83833","
7 : "amazon.com shopper","amazon.com","kpaiiha","kpaiiha@gmail.com","pwd84848","
6 : "amzn biss virt","amazon.com","BISS_RO","Zer0$chance","ETLM: BISS_ETL is the virt name
BISS_BI_RO: Zer0$chance
BISS_BI_DDL: zer0$chancE
BISS_BI_DML: zer0$chancE
7 : "photobucket.com","photobucket.com","merlinr-amazon","merlinr@amazon.com","as8d9uf9","
6 : "prophetservices.com golf registration seattle","prophetservices.com","mdr3000@mac.com","faw4v334","Premier Golf Seattle
http://www.premiergc.com/
```
```bash
awk 'BEGIN { FS = "\",\"|^\""; RS = "\"\n"; OFS = "\t" } {print NF " : " $2,$3,$4,$5,$6,$7,$8 }' testfile.csv
awk 'BEGIN { FS = "\",\"|^\""; RS = "\"\n"; OFS = "\t" } {$1=$1; print NF " : " $2,$3,$4,$5,$6,$7,$8 }' testfile.csv

# password first
awk 'BEGIN { FS = "\",\"|^\""; RS = "\"\n"; OFS = "\t" } 
     NF == 6 {$1=$5; print $1,$2,$3,$4,$6 }
     NF == 7 {$1=$6; print $1,$2,$3,$4,$5,$7 }' testfile.csv

```

### review fields
```
# hand review
field 1 = field 2

fields         pwd field      notes          email
4              3              4
5              4              none
5              4              5
6              5              none
6              5              6

# those are all the cases I found, email is todo
```
mostly true, password seems to be N - 1 field.
1. Name
2. site
3. username
4. password
5. "" (blank) OR something notes

or
1. name
2. site
3. username
4. email
5. password
6. "" (blank)

### field number with email
```bash
# NF - 1 is actual number of fields
awk 'BEGIN { FS = "\",\"|^\""; RS = "\"\n"; OFS = "\t" }
     BEGIN {print "row\t: NF-1\t: email\t:: dist from end"}
          {    printf("%s\t: %s\t: ", NR, NF - 1)
               for (i = 1; i <= NF; i++) if($i ~ /@/) { printf("%s\t:: %s", i - 1, (NF - 1) - (i - 1)); flag = 1; break }
               if (!flag) printf("\t:: ")
               split($0, linearr, "\n")
               printf("\t::\t%s\n",linearr[1])
               flag = ""
          }' testfile.csv
row   : NF-1   : email   :: dist from end
 1    : 5      :         ::                 ::   "amazon.com","amazon.com","merlinr","pwoe83833","                                                                       "
 2    : 6      : 4       :: 2               ::   "amazon.com shopper","amazon.com","kpaiiha","kpaiiha@gmail.com","pwd84848","                                            "
 3    : 5      :         ::                 ::   "amzn biss virt","amazon.com","BISS_RO","Zer0$chance","ETLM: BISS_ETL is the virt name                                  "
 4    : 6      : 4       :: 2               ::   "photobucket.com","photobucket.com","merlinr-amazon","merlinr@amazon.com","as8d9uf9","                                  "
 5    : 5      : 3       :: 2               ::   "prophetservices.com golf registration seattle","prophetservices.com","mdr3000@mac.com","faw4v334","Premier Golf Seattle"

# running on the archive file gives some anomalies
- email is uniformly 2 from the end (ie $4 if NF == 6)
- when email is not in NF-2, its still OK: either no email given, or NF-2 still has an email, the @ was found in the notes (NF)
```

### $1 == $1 count
```bash
# remember the first field is empty
awk 'BEGIN { FS = "\",\"|^\""; RS = "\"\n" ; same = diffr = 0}
     $2 == $3 { same++ }
     $2 != $3 { diffr++ }
     END  {print same "\tlines with $1 = $2\n" diffr "\tlines different"}' testfile.csv
2    lines with $1 = $2
3    lines different

$SAME on archive file:
112  lines with $1 = $2
24   lines different
when different, the first field is mostly better
```
### sort the file by special cases, for reference on manual update
- $1 != $2
- email not NF-2
```bash
# lead: mismatch fields, emay: email not in NF-2
# sort file email weird, then first two fields weird, then normals

awk 'BEGIN { FS = "\",\"|^\""; RS = "\"\n"; OFS = "\t" }
     {    if($2 != $3) lead = 1; else lead = 2
          emay = 1
          for (i = 1; i <= NF; i++) if($i ~ /@/ && ((NF - 1) - (i - 1) == 2)) emay = 2
          split($0, linearr, "\n")
          print "\"" emay " " lead "\"," linearr[1] "\"" | "sort -n"
     }' testfile.csv

"1 1","amzn biss virt","amazon.com","BISS_RO","Zer0$chance","ETLM: BISS_ETL is the virt name"
"1 2","amazon.com","amazon.com","kadarm","pwoe83833",""
"2 1","amazon.com shopper","amazon.com","kpaiiha","kpaiiha@gmail.com","pwd84848",""
"2 1","prophetservices.com golf registration seattle","prophetservices.com","mdr8001@mac.com","faw4v334","Premier Golf Seattle"
"2 2","photobucket.com","photobucket.com","kadarm-amazon","kadarm@amazon.com","as8d9uf9",""

# now export labelled file to eliminate weirds
# sort fails because record separator not respected
awk 'BEGIN { FS = "\",\"|^\""; RS = "\"\n"; OFS = "\t"; ORS = "\"\n" }
     {    if($2 != $3) lead = 1; else lead = 2
          emay = 1
          for (i = 1; i <= NF; i++) if($i ~ /@/ && ((NF - 1) - (i - 1) == 2)) emay = 2
          print "\"" emay " " lead "\"," $0 
     }' $pwfile > archive-reference-sorted.csv
```

### SO: established
(using 'actual' field numbers, subtract 1 for the leading field)
label/site: at 1
username = NF-3 if NF = 6
email = at NF-2
pwd   = NF-1
notes = NF


### **ready!** drop NF = 2 and export to new rules
$1 is excluded as empty field
$3 is dropped, mostly duplicated by $2 the site
```bash
new output:
title, URL, username(email), pwd, note (append username to note)
field 1:  $2, title
field 2:  $3, url mostly
field 3:  NF-2, email if NF = 6 else NF-3
field 4:  NF-1, password
field 5:  (NF-3 or NF-2 email if NF = 5) + NF, notes

# exclude first 3 rows
# NF = 5 then username only or username is email, assign NF-2 to username field

awk 'BEGIN  {  FS = "\",\"|^\""; RS = "\"\n"; OFS = "\",\""; ORS = "\"\n" }
            {  f1 = $2
               f2 = $3
               f3 = $(NF-2)
               f4 = $(NF-1)
               f5 = "username: " ((NF-1) == 6 ? $(NF-3) : $(NF-2)) "\n" $NF
               print "\"" f1,f2,f3,f4,f5
            }' testfile.csv

"amazon.com","kadarm","kadarm","pwoe83833",""
"amazon.com shopper","kpaiiha","kpaiiha@gmail.com","pwd84848",""
"amzn biss virt","BISS_RO","BISS_RO","Zer0$chance","ETLM: BISS_ETL is the virt name
BISS_BI_RO: Zer0$chance
BISS_BI_DDL: zer0$chancE
BISS_BI_DML: zer0$chancE"
"photobucket.com","kadarm-amazon","kadarm@amazon.com","as8d9uf9",""
"prophetservices.com golf registration seattle","mdr8001@mac.com","mdr8001@mac.com","faw4v334","Premier Golf Seattle
http://www.premiergc.com/"

# PASS!

"NR > 3 <same awk script>"  $pwfile > pwfile-clean-for-import.csv

awk 'BEGIN { FS = "\",\"|^\""; RS = "\"\n" }
     {print NF-1}' pwfile-clean-for-import.csv
# all 5's good 
```
