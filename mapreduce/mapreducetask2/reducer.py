#!/usr/bin/env python

import sys


def get_top5(words_items):
    top5_items = sorted(words_items, key=lambda x: x[1], reverse=True)[:5]
    return "".join(["{}:{};".format(word, str(cnt)) for word, cnt in top5_items])


prev_key = ""
sum_cnt = 0
words = dict()

for line in sys.stdin:
    key, word, word_cnt = line.split('\t')
    word_cnt = int(word_cnt)
    if key != prev_key:
        if prev_key:
            top5 = get_top5(words.items())
            print("{}\t{}\t{}".format(str(sum_cnt), prev_key, top5))
        prev_key = key
        sum_cnt = word_cnt
        words = {word : word_cnt}
    else:
        sum_cnt += word_cnt
        if word in words.keys():
            words[word] += word_cnt
        else:
            words[word] = word_cnt

if prev_key:
    top5 = get_top5(words.items())
    print("{}\t{}\t{}".format(str(sum_cnt), prev_key, top5))