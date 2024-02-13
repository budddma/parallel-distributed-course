#!/usr/bin/env python
 
import sys


for line in sys.stdin:
    cnt, key, top5 = line.strip().split('\t')
    print("{}\t{}\t{}".format(key, cnt, top5))