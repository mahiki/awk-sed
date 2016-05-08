## 01 awk performance
slowness can depend on machine specific implementations of:

- pattern matching
- field splitting
- concatenation
- substitution

The following table of timing tests will help you refactor code for each machine
```
program                                              -|- MBP           -|- RHEL VM on Intel PC
------------------------------------------------------|-----------------|----------------------------------------------
END { print NR }
{ n++ }; END { print n }                              
{ i = NF }
wc command

