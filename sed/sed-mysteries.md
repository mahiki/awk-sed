## sed mysteries
*i've had some problems with sed in the graphviz tutorial, this is a list of unresolved methods in sed*

- [x] mystery of the sed line endings
	+ sed bad at line endings
	+ sed needs backslash `\` all the time, like alternation `\|`

### transform asin order groups to .dot graph files
i had big problems getting the regex to change the 'X'  numerical ASINs at end of row.

example data:

	0060245867 -- 067144901X -- 0671449028 -- 078681988X
	034541005X -- 1596438134
	084313271X -- 0843183535
	048643852X -- 0843172525
	0195097467 -- 044655605X
	140193496X -- 1401934978 -- B008JNPBYK
	0345442318 -- 067189286X

desired "just turn the X-s at the end of number to '0' and add ';'

	0060245867 -- 0671449010 -- 0671449028 -- 0786819880;
	0345410050 -- 1596438134;
	0195097467 -- 0446556050;

#### attempts mostly successful

	gsed -E 's:([0-9]{5,})X\s:\190:' test33.txt	# capture 5+digit number appended by X

	0060245867 -- 0671449010 -- 0671449028 -- 078681988X
	0486438520 -- 0843172525
	0307352153 -- 159285849X

i thought \n was matched by \s

	gsed -E 's:681988X:6819880:' test33.txt
		0060245867 -- 067144901X -- 0671449028 -- 0786819880			# i'm not crazy

why won't the match work at EOL?  
CR = \r; LF = \n; CRLF = \r\n; Mac, Unix, Windows line endings

#### so i read `sed` does 'not handle line endings well'
>Sed is line-based therefore it is hard for it to grasp newlines

solution is use `tr` to transform the newlines, then work your magic and transfor back. YUCK!

	tr '\n' '&' <data.txt
	sed -i "s/`/~`/" output.txt
	tr '`' '\n' <output.txt >result.txt

#### here is the solution using `$`

	gsed -r 's:([0-9]{5,})X(\b|$):\10:' test33.txt
		0060245867 -- 0671449010 -- 0671449028 -- 078681988X		# what? all line endings except this one
		0345410050 -- 1596438134
		0843132710 -- 0843183535
		0486438520 -- 0843172525
		0307352153 -- 1592858490
		0394851420 -- 0547299630
		0195097467 -- 0446556050
		1401934960 -- 1401934978 -- B008JNPBYK

**had engough!!**

	gsed -r 's:(.)$:\1;:' test33.txt
	gsed -r 's:([0-9]{5,})X\b:\10:'
	and then remove `078681988X`, it has a ghost

