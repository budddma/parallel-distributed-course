#!/usr/bin/env bash

IN_DIR="/data/wiki/en_articles"
OUT_DIR="budddma_mrtask2_result"
NUM_REDUCERS=8

hadoop fs -rm -r -skipTrash $OUT_DIR* > /dev/null

hadoop jar /opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/hadoop-streaming.jar \
    -D mapred.job.name="budddma_mrtask2_processing" \
    -D mapreduce.job.reduces=$NUM_REDUCERS \
    -files mapper.py,reducer.py \
    -mapper mapper.py \
    -reducer reducer.py \
    -input $IN_DIR \
    -output $OUT_DIR/processing > /dev/null

hadoop jar /opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/hadoop-streaming.jar \
    -D mapred.job.name="budddma_mrtask2_sorting" \
    -D mapreduce.job.reduces=1 \
    -D mapreduce.job.separator=\t \
    -D mapreduce.partition.keycomparator.options=-k1,1nr \
    -D mapreduce.job.output.key.comparator.class=org.apache.hadoop.mapreduce.lib.partition.KeyFieldBasedComparator \
    -files return_answer.py \
    -mapper /bin/cat \
    -reducer return_answer.py \
    -input $OUT_DIR/processing \
    -output $OUT_DIR/result > /dev/null

hadoop fs -cat $OUT_DIR/result/part-00000 | head -n 10