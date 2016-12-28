## arrays and applications in awk
[ref awk man page for original awk](http://man7.org/linux/man-pages/man1/awk.1p.html)  
[gnu awk manual *the more better awk*](https://www.gnu.org/software/gawk/manual/gawk.html) better performance and arrays  
[merlin's answer to awk array q on stackoverflow](http://stackoverflow.com/questions/3060600/awk-array-iteration-for-multi-dimensional-arrays/41357243#41357243)  

### example data
      hawkings reftag_customer_asin_brand_category_OPS.txt 
      reftag_customer_asin_brand_category_OPS.txt:
            data rows: 886754    cols: 16        
              1: CUSTOMER_ID                         2: HIT_DATE                            3: ATTRIB_REF_MARKER             
              4: FEATURE_NAME                        5: GROUP_NAME                          6: ORDER_R_WEEK                  
              7: ORDER_DAY                           8: ORDER_ID                            9: CUSTOMER_ORDER_ITEM_ID        
             10: ASIN                               11: ITEM_NAME                          12: CATEGORY                      
             13: BRAND                              14: CUST_TYPE                          15: OPS                           
             16: UNITS

### original awk examples
#### count distinct customers
      awk -F'\t' 'NR>1 {a[$1]++} END {for (i in a) j++; printf "customer count: %s\n", j }' reftag_customer_asin_brand_category_OPS.txt 
      customer count: 295305

#### count distinct group+customer rows
      time /usr/bin/awk -F'\t' 'NR>1 { gc[$5,$1]++ } 
                                 END { for (i in gc) j++; print "group/cust rows: " j}' \
            reftag_customer_asin_brand_category_OPS.txt
      group/cust rows: 298574
      11.75s
note that gnu awk performs the same in 1.1 seconds

#### count distinct customers per group
```bash
time  /usr/bin/awk -F'\t' 'NR>1 { gc[$5,$1]++ }
                           END  { for (iindex in gc) {split(iindex,arr,SUBSEP); custs[arr[1]]++; total++}
                                  for (k in custs) printf "%-30s customers:%10d\n", k, custs[k]
                                  print "total group+customers: " total }' reftag_customer_asin_brand_category_OPS.txt
12.239 seconds

SSIB-Display-Publisher         customers:      2829
AB - Registration              customers:         1
SSIB-AB-Email                  customers:      2766
SSIB-Onsite-Merchandising      customers:    153778
SSIB-Email-Campaigns           customers:     24569
SSIB-Social-Media              customers:       163
SSIB-Direct-Mail               customers:       288
SSIB-Display-Network           customers:    114084
SSIB-Influencer-Associations   customers:        96
total group+customers:                       298574
```

### gnu awk
#### count distinct customers by group
```bash
time awk -F'\t' 'NR>1 { gc[$5][$1]++ }
                 END  { for (i in gc)
                              for (j in gc[i]) { custs[i]++; total++ }
                        for (k in custs) printf "%-30s customers:%10d\n", k, custs[k]
                        print "total group+customers: " total }' reftag_customer_asin_brand_category_OPS.txt
1.1 seconds

SSIB-Email-Campaigns           customers:     24569
SSIB-Influencer-Associations   customers:        96
AB - Registration              customers:         1
SSIB-Onsite-Merchandising      customers:    153778
SSIB-AB-Email                  customers:      2766
SSIB-Display-Network           customers:    114084
SSIB-Direct-Mail               customers:       288
SSIB-Social-Media              customers:       163
SSIB-Display-Publisher         customers:      2829
total group+customers: 298574
```

sweet!

