## strings and regexes in awk
This will provide an interactive session from the shell prompt, enter: string <tab> regex

	awk -F'\t' '$1 ~ $2' -

to see what the matched elements of the string were, extend the features a bit:

	awk -F'\t' '$1 ~ $2 { if(match($1,$2)) {print "matched: " substr($1,RSTART,RLENGTH)} }' -

