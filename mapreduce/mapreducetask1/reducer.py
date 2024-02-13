#!/usr/bin/env python3

import sys
from random import randint


id_line = ""
id_cnt = randint(1, 5)
        
for line in sys.stdin:
    try:
        id = line.strip().split('\t', 1)[1]
    except ValueError:
        pass
    
    if id_cnt > 1:
        id_line += id + ","
        id_cnt -= 1
    else:
        id_cnt = randint(1, 5)
        print(id_line + id)
        id_line = ""
    
print(id_line.strip(','))