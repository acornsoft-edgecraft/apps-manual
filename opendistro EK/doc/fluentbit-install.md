# Fluentbit daemonset installation

> Logstash는 JRuby, Fluentd는 CRuby로 되어 있음. Logstash에 비해 Fluentd는 조금 더 가벼우며, 로그 전송만 담당하는 더욱 경량화된 Fluent Bit을 사용할 수 있음

## Fluentbit configmap
```bash
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
  namespace: elastic
  labels:
    k8s-app: fluent-bit
data:
  fluent-bit.conf: |
    [SERVICE]
        Flush         1
        Log_Level     info
        Daemon        off
        Parsers_File  parsers.conf
        HTTP_Server   On
        HTTP_Listen   0.0.0.0
        HTTP_Port     2020
    @INCLUDE input-apache2.conf
    @INCLUDE input-applog.conf
    @INCLUDE filter-applog.conf
    @INCLUDE output-elasticsearch.conf
  input-apache2.conf: |
    [INPUT]
        # https://docs.fluentbit.io/manual/pipeline/inputs/tail 
        Name               tail
        Path               /data/applog/apache*.log
        Path_Key           filepath
        Tag                apache2.*
        Parser             apache2
        Refresh_Interval   10
        Mem_Buf_Limit      100MB
        Skip_Long_Lines    On
        Ignore_Older       1h
        Buffer_Max_Size    1MB
  input-applog.conf: |
    [INPUT]
        Name               tail
        Path               /data/applog/app*.log
        Multiline          On
        Parser_Firstline   applog_parser
        Path_Key           filepath
        Tag                app.*
        Rotate_Wait        5
        Refresh_Interval   10
        Mem_Buf_Limit      100MB
        Skip_Long_Lines    On
        Ignore_Older       1h
        Buffer_Max_Size    1MB
  filter-applog.conf: |
    [FILTER]
        # https://docs.fluentbit.io/manual/pipeline/filters/record-modifier
        Name                record_modifier
        Match               app.*
        Record              clusterid ${CLUSTER_ID}
        Record              hostip ${HOST_IP}
        Record              kind ApplicationLog
  output-elasticsearch.conf: |
    [OUTPUT]
        # https://docs.fluentbit.io/manual/pipeline/outputs/elasticsearch 
        Name            es
        Match           *
        Host            ${FLUENT_ELASTICSEARCH_HOST}
        Port            ${FLUENT_ELASTICSEARCH_PORT}
        Logstash_Format On
        Replace_Dots    On
        Retry_Limit     False
        HTTP_User       ${FLUENT_ELASTICSEARCH_USER}
        HTTP_Passwd     ${FLUENT_ELASTICSEARCH_PASSWD}
        tls             On
        tls.verify      Off
        tls.debug       1
        tls.ca_file     /secure/ca.crt
  parsers.conf: |
    [PARSER]
        # https://docs.fluentbit.io/manual/pipeline/parsers/regular-expression
        Name applog_parser
        Format regex
        Regex ^(?<severity>INFO|DEBUG|WARNING|CRITICAL) (?<errorcode>[^ ]*) (?<time>[^ ]*) (?<source>[^ ]*)](?<message>.*)
        Time_Key time
        Time_Format %Y-%m-%dT%H:%M:%S
        Time_Keep    On
    [PARSER]
        Name   apache2
        Format regex
        Regex  ^(?<host>[^ ]*) [^ ]* (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^ ]*) +\S*)?" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>.*)")?$
        Time_Key time
        Time_Format %d/%b/%Y:%H:%M:%S %z
        Time_Keep    On
```

```bash
[root@node1 applog]# cat gen.sh
#!/bin/bash

while true
do
  APP_TIME=`date '+%Y-%m-%dT%H:%M:%S'`
  CURRENT_TIME=`date '+%d/%b/%Y:%H:%M:%S %z'`

  echo 'INFO 0000 '"${APP_TIME}"' main.py:123] Application ready to service ...' >> ./app.log
  echo '  SELECT userid, username'>> ./app.log
  echo '  FROM userInfo'>> ./app.log
  echo '  WHERE userId=aaa and userName=cloud'>> ./app.log

  echo '192.168.23.195 - frank ['"${CURRENT_TIME}"'] "GET /apache_pb.gif HTTP/1.0" 200 2326 "http://www.example.com/start.html" "Mozilla/4.08 [en] (Win98; I ;Nav)"' >> ./apache.log
  sleep 2
done


[root@node1 applog]# cat apache.log
192.168.23.195 - frank [08/May/2021:08:08:35 +0000] "GET /apache_pb.gif HTTP/1.0" 200 2326 "http://www.example.com/start.html" "Mozilla/4.08 [en] (Win98; I ;Nav)"
192.168.23.195 - frank [08/May/2021:08:08:37 +0000] "GET /apache_pb.gif HTTP/1.0" 200 2326 "http://www.example.com/start.html" "Mozilla/4.08 [en] (Win98; I ;Nav)"
192.168.23.195 - frank [08/May/2021:08:08:39 +0000] "GET /apache_pb.gif HTTP/1.0" 200 2326 "http://www.example.com/start.html" "Mozilla/4.08 [en] (Win98; I ;Nav)"
192.168.23.195 - frank [08/May/2021:08:08:41 +0000] "GET /apache_pb.gif HTTP/1.0" 200 2326 "http://www.example.com/start.html" "Mozilla/4.08 [en] (Win98; I ;Nav)"

[root@node1 applog]# cat app.log
INFO 0000 2021-05-08T12:16:07 main.py:123] Application ready to service ...
  SELECT userid, username
  FROM userInfo
  WHERE userId=aaa and userName=cloud
INFO 0000 2021-05-08T12:16:09 main.py:123] Application ready to service ...
  SELECT userid, username
  FROM userInfo
  WHERE userId=aaa and userName=cloud
```


[](github.com/fluent/fluent-bit/blob/master/conf/parsers.conf)
[](regex101.com)
[](rubular.com)
[](config.calyptia.com/#/regex)