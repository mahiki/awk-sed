#!/usr/bin/env awk -f
# -------------------------------------------------------------------
#   parses csv fields in double quotes, fields with newlines within
#       make transformations
#       output in CSV
#       can embed newlines in fields
#   
#   usage: ./awk-parse-csv.awk datafile.csv   
#   
#   notes:          rearranges fields to give uniformity to downstream import
#                   based on input of variable field number
#                   transforms proper field order for import elsewhere
#
#   todo:           --help option
#                   take the body actions as -c '' argument
#
#   dependencies:   gnu awk
#   author:         merlinr@
# -------------------------------------------------------------------


    #   the field separator definition is the main thing
    #   an extra field is generated
BEGIN {
        FS = "\",\""; RS = "\"\n"; OFS = "\",\""; ORS = "\"\n"
}

NR > 0 {    # change to 1 if excluding header rows

        sub(/^\"/, "", $1)          # strip the leading "

        # body: <replace with what you need to transform>
        # this example uses testfile.csv, with 5 or 6 fields per row, outputting 5 fields
        # transform your fields
            f1 = $1
            f2 = $2
            f3 = $(NF-2)
            f4 = $(NF-1)
            f5 = "username: " (NF == 6 ? $(NF-3) : $(NF-2)) ($NF == "" ? $NF : "\n" $NF)    # prepending the username to the notes field

            $0 = ""
            $1 = f1
            $2 = f2
            $3 = f3
            $4 = f4
            $5 = f5

        # ready to output
        sub(/^/, "\"", $1)          # restore the leading "
        print $0                    # output is fully qutoed csv
}
