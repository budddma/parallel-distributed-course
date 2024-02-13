#!/usr/bin/env python
 
import sys
import re


for line in sys.stdin:
    text = line.strip().split('\t', 1)[1]
    words = re.sub('\W', ' ', text).split(' ')
    for word in words:
        if len(word) >= 3:
            word = word.lower()
            print("{}\t{}\t{}".format("".join(sorted(word)), word, 1))