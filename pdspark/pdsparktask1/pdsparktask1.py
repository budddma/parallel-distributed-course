import re
from pyspark import SparkContext, SparkConf

config = SparkConf().setAppName('pd202253_pdsparktask1').setMaster('yarn')
spark_context = SparkContext(conf=config)

RDD = spark_context.textFile('/data/wiki/en_articles_part/articles-part')
RDD = RDD.map(lambda x: re.sub('[^a-z]', ' ', x.strip().lower()))
RDD = RDD.map(lambda x: x.split(' '))
RDD = RDD.filter(lambda x: len(x))
RDD = RDD.flatMap(lambda x: ([x[i], x[i + 1]] for i in range(len(x) - 1)))

key = 'narodnaya'
RDD = RDD.filter(lambda x: x[0] == key)
RDD = RDD.map(lambda x: x[0] + '_' + x[1])
RDD = RDD.map(lambda x: (x, 1))
RDD = RDD.reduceByKey(lambda a, b: a + b)
RDD = RDD.sortBy(lambda a: a[1])

result = RDD.collect()

for bigram in result:
    print(bigram[0] + '\t' + str(bigram[1]))