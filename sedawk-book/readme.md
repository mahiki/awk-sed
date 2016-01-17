### sed-awk book excercises and notes
these are general notes and snippets  
a tighter more organized bit is in `best-of-sedawk.md` which I'll move to parent folder.

    	../repo/awk-sed/sedawk-book/

using `hamlet.txt`

#### ch 3 regular expressions

extract headings from a group of chapter files

    	grep '\.H[123]' ch0[12]

for this directory, try this to return every line with 'awk', recursively and with filename in current directory.

	grep -rH 'awk' .

this pulls all the entrances in hamlet and counts them

	awk '/\[Enter/' hamlet.txt | wc -l
		61

similarly, there are 249 `[ ]` closed braces on a line, and 463 occurrences of `Ham`

##### character classes (`[   ]` members) in awk
	\ 	escapes special characters (awk only)
	-     indicates a range unless in first/last position
	^	reverse the match, if in first position

examples  
`[1-9]` 		the numbers 1 through 9  
`[A-Z]` 		capital letters.  
`[-/+*]` 		matches the arithmetic operators.
`[^0-9]`		to exclude a class of numbers, match every non-numeric character

###### egrep vs grep
POSIX standards cover non-english, and define classes with `[[:alpha:]]` and such.

egrep is the extended regular expressions

POSIX standard classes

	Class		Matching Characters
	[:alnum:]	Printable characters (includes whitespace)
	[:alpha:]	Alphabetic characters
	[:blank:]	Space and tab characters
	[:cntrl:]	Control characters
	[:digit:]	Numeric characters
	[:graph:]	Printable and visible (non-space) characters
	[:lower:]	Lowercase characters
	[:print:]	Printable characters (includes whitespace)
	[:punct:]	Punctuation characters
	[:space:]	Whitespace characters
	[:upper:]	Uppercase characters
	[:xdigit:]	Hexadecimal digits

The POSIX definitions will gradually become more prevalent, but you can see how awkward this is.

I think i'll ignore these, unless unicode multi-language stuff.

###### wildcards
```
. + *	?					the wildcards, single/one or more/zero or more/zero or one
?  ??						optional match lazy/greedy
+?						one or more, lazy
".*"						all characters between, plus the quotation marks.
\[.*\]					all characters and brackets enclosed
awk '/\[.*Horatio.*]/' hamlet.txt	all brackets containing 'Horatio'
^$						blank line
^ *$						blank line with spaces
```

note that `?` in the shell is like `.` in regex.

in sed or grep, `^` and `$` are special only at begin/end of regex.  
in awk, `^`, `$` are always special.


