## chapter 2
AWK, Awo - Kernighan - Weinberg

### notes
the first thing notice in the chapter is

*expression*  { *statements* }

the statements are executed if *expression* is `true`, ie `expression != 0 or NULL`

on any test file, 

	i < 11 { if (i++ % 2 == 0) print }
		row	date	asin	sales	units
		2	12-25-2011	B000HL1333	193333.60	360	
		4	11-06-2012	B000XI1....

**you can put formulas and variable expressions, even functions in the expression.

