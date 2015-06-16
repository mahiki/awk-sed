# execute: awk -f queue_fun.awk PATH_TO_FILE
#{ print $0; }  # prints $0. In this case, equivalent to 'print' alone
#{ exit; }      # ends the program
#{ next; }      # skips to the next line of input
#{ a=$1; b=$0 } # variable assignment
#{ c[$1] = $2 } # variable assignment (array)

#{ if (BOOLEAN) { ACTION }
#  else if (BOOLEAN) { ACTION }
#  else { ACTION }
#}
#{ for (i=1; i<x; i++) { ACTION } }
#{ for (item in c) { ACTION } }

# here goes
/pwd/ {print "bingo! command " $2 ":pwd"; }
