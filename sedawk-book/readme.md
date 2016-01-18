### sed-awk book excercises and notes
these are general notes and snippets  
a tighter more organized bit is in [`best-of-sedawk.md`][1] which I'll move to parent folder.

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

##### wildcards
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

	\^ | \$				always escape these in awk when literal matching
	grep [Dix^Ha]			^ not special if not first

**matching across lines**  
`sed` can match across multiple lines, but grep and awk are not good for this

##### more items
```
{m,n}						braces provide 0 to 255 repetion (or more?)
[0-9]{3}-[0-9]{2}-[0-9]{4}		match any SSN
A | B						either of the two
jah( rastafari)?				jah or 'jah rastafari'
hotline( bling| jamz)			
```

pre-POSIX awk doesn't have braces. so awk version can matter, and sed/grep use `\{ or \}`

##### a lesson in extent of match
```
sample: 'All of us, including Zippy, our dog'
A*Z						only matches the Z
A.*Z						everything up through Z
```

I'm pretty unhappy with the solutions I'm seeing in the book.  `.*` is a bad idea because of the backtracking performance hit. The `?` addition still a mystery. I'm moving on to sed scripting.


#### ch 4 sed scripts
first rule: `sed` applies every rule in order to the current state of the current line, so mutations can change the expected result of subsequent rules. might wanna not overlap too many rules at once.

##### sed command structure

	sed /regex or address reference/command/find/replace/command

examples

	sed 1d filename				deletes first line of file
	sed /rasta/s/Ziggy/Bob/g		on lines containing 'rasta', substitute 'Bob' for 'Ziggy'
	sed 10/s/Zigg/Bob/g			only on line 10
	



#### references
[1]:https://github.com/mahiki/awk-sed/blob/master/sedawk-book/best-of-sedawk.md
