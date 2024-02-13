ADD JAR /opt/cloudera/parcels/CDH/lib/hive/lib/hive-contrib.jar;
ADD jar /opt/cloudera/parcels/CDH/lib/hive/lib/hive-serde.jar;

USE budazhapovma;

SELECT TRANSFORM(ip, query_time, http_query_from_ip, page_size, http_status_code, client_app_info)
USING "sed -r 's|http|ftp|'" AS ip, query_time, http_query_from_ip, page_size, http_status_code, client_app_info
FROM Logs
LIMIT 10;