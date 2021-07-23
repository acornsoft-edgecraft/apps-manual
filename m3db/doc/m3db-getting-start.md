# M3db Getting Start

Follow these steps to get started with M3db:
- 1. 사전 준비 helm3
  
## Architecture

![M3DB Architecture](./images/m3db-cluster-architecture.png)
## Installation
- helm
```
helm upgrade m3db -i \
  -n m3db \
  --create-namespace \
  --cleanup-on-fail \
  --repo m3db \
  m3db-operator \
  -f values.yaml
```

## Prometheus configuration
- Add to your Prometheus configuration the m3coordinator sidecar remote read/write endpoints
```yaml
  remoteWrite:
    - url: http://m3coordinator.m3db:7201/api/v1/prom/remote/write
  remoteRead:
    - url: http://m3query.m3db:7201/api/v1/prom/remote/read
      readRecent: true # To test reading even when lcoal prometheus has the data
```

- tsdb 관련 args 삭제
```yaml
## kubectl -n monitoring edit deployment prometheus-server
- "--storage.tsdb.no-lockfile"
- "--storage.tsdb.wal-compression"
- "--storage.tsdb.path=/prometheus/"
```

## Prometheus Helm Chart 변경
- m3db 사용시 tsdb 설정을 사용 안함으로 변경 함.
  - deployment에서 args: tsdb 설정 삭제
- m3db 사용시 pvc 설정을 사용 안함으로 변경 함.
- m3db 사용시 remoteWrite/remoteRead 설정 변경
```yaml
## values.yaml 샘플
  ### m3db 사용
  remoteStorage:
    enabled: true
  
    remoteWrite:
      - url: "http://192.168.77.232:32555/api/v1/prom/remote/write"

    ## https://prometheus.io/docs/prometheus/latest/configuration/configuration/#remote_read
    remoteRead:
      - url: "http://192.168.77.232:32558/api/v1/prom/remote/read"
        read_recent: true

```



---
# 참조
> [Prometheus 문제 해결을 위한 장기 저장소로 M3 활용](https://git.k3.acornsoft.io/ccambo/k3rndworks/-/blob/master/k8s/docs/%5Bkuberenetes-monitoring%5D_how_to_use_m3_as_a_longterm_storage_of_prometheus.md)