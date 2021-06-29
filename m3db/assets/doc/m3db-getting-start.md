# M3db Install Cli

Follow these steps to get started with M3db:
- 1. 사전 준비 helm3
  
## Architecture


## Installation



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