#!/usr/bin/env bash

IN_DIR="/data/ids"
OUT_DIR="mapreducetask1_result"
NUM_REDUCERS=8

hadoop fs -rm -r -skipTrash $OUT_DIR* >/dev/null

yarn jar /opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/hadoop-streaming.jar \
    -D mapreduce.job.name="budddma_mrtask1" \
    -D mapreduce.job.reduces=${NUM_REDUCERS} \
    -files mapper.py,reducer.py \
    -mapper mapper.py \
    -reducer reducer.py \
    -input $IN_DIR \
    -output $OUT_DIR >/dev/null

hdfs dfs -cat ${OUT_DIR}/part-00000 | head -n 50