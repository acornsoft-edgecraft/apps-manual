# M3db Install Cli

Follow these steps to get started with M3db:
- 1. 사전 준비 helm3
  
## Architecture


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

## 노드 리소스 점유에 따른 조치 
```sh
## 노드 리소스 확인
kubectl describe nodes vm-live-02 | grep Allocatable -B 4 -A 3

## Node-pressure Eviction 설정
--eviction-hard=memory.available<500Mi
--system-reserved=memory=1.5Gi
```



---
# 참조
> [Node-pressure Eviction](https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/)