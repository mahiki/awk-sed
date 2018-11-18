#!/usr/bin/env awk -f
# -------------------------------------------------------------------
#   parses csv fields in double quotes, fields with newlines within
#
#   notes:          rearranges fields to give uniformity to import
#                   based on input of variable field number
#                   transforms proper field order for import elsewhere
#
#   todo:           --help option
#
#   dependencies:   gnu awk
#   author:         merlinr@
# -------------------------------------------------------------------

BEGIN {
        FS = "\",\"|^\""; RS = "\"\n"; OFS = "\",\""; ORS = "\"\n"
}

NR > 3 {    
        f1 = $2
        f2 = $3
        f3 = $(NF-2)
        f4 = $(NF-1)
        f5 = "username: " ((NF-1) == 6 ? $(NF-3) : $(NF-2)) "\n" $NF
        print "\"" f1,f2,f3,f4,f5
}
