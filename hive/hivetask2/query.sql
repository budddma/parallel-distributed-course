ADD JAR /opt/cloudera/parcels/CDH/lib/hive/lib/hive-contrib.jar;
USE budazhapovma;

SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.max.dynamic.partitions=1000;
SET hive.exec.max.dynamic.partitions.pernode=1000;

SELECT query_time, COUNT(DISTINCT http_status_code) AS count
FROM Logs
GROUP BY query_time
ORDER BY count DESC;