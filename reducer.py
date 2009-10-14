#!/usr/bin/env python
import sys

# maps words to their counts
word2count = {}

for line in sys.stdin:
    # remove leading and trailing whitespace
    line = line.strip()

    # parse the input we got from mapper.py
    word, count = line.split('\t', 1)
    # convert count (currently a string) to int
    try:
        count = int(count)
        word2count[word] = word2count.get(word, 0) + count
    except ValueError:
        # count was not a number, so silently
        # ignore/discard this line
        pass

# sort the words lexigraphically;
sorted_word2count = word2count.items()
sorted_word2count.sort()

for word, count in sorted_word2count:
    print '%s\t%s'% (word, count)
