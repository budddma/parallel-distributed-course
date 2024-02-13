#!/bin/bash

blocks_cnt=$(hdfs fsck $1 -files -blocks -locations | sed -n 2p)
blocks_cnt=${blocks_cnt#*bytes, }
blocks_cnt=${blocks_cnt% block*}
echo $blocks_cnt