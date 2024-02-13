#!/usr/bin/env python3

import sys
from random import randint


for line in sys.stdin:
    try:
        id = line.strip()
    except ValueError:
        pass
    print(str(randint(0, 100000)), id, sep='\t')