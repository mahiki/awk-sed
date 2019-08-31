# anagram.awk --- An implementation of the anagram-finding algorithm
#                 from Jon Bentley's "Programming Pearls," 2nd edition.
#                 Addison Wesley, 2000, ISBN 0-201-65788-0.
#                 Column 2, Problem C, section 2.8, pp 18-20.
#
#   usage to get all words starting with b:
#       $ gawk -f anagram.awk /usr/share/dict/words | grep '^b'


/'s$/   { next }        # Skip possessives

{
    key = word2key($1)  # Build signature
    data[key][$1] = $1  # Store word with signature
}

# word2key --- split word apart into letters, sort, and join back together

function word2key(word,     a, i, n, result)
{
    n = split(word, a, "")
    asort(a)

    for (i = 1; i <= n; i++)
        result = result a[i]

    return result
}

END {
    sort = "sort"
    for (key in data) {
        # Sort words with same key
        nwords = asorti(data[key], words)
        if (nwords == 1)
            continue

        # And print. Minor glitch: trailing space at end of each line
        for (j = 1; j <= nwords; j++)
            printf("%s ", words[j]) | sort
        print "" | sort
    }
    close(sort)
}

