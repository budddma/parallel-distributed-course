ADD JAR /opt/cloudera/parcels/CDH/lib/hive/lib/hive-contrib.jar;
ADD jar /opt/cloudera/parcels/CDH/lib/hive/lib/hive-serde.jar;
ADD FILE udf.sh;

USE budazhapovma;

SET hive.exec.max.dynamic.partitions=10000;
SET hive.exec.max.dynamic.partitions.pernode=10000;
SET hive.exec.dynamic.partition.mode=nonstrict;

select transform(page_size)
using './udf.sh' as megabyte_transformer 
from Logs
limit 10;