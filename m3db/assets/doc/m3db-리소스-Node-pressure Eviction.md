# Node-pressure Eviction

Follow these steps to get started with Node-pressure Eviction:
- 1. 노드 리소스 확인
- 2. Node-pressure Eviction 정책 정하기
  
## Architecture


## Node-pressure Eviction
> Kubelet 노드에서 리소스를 회수하기 위해 사전에 포드를 종료합니다.


> kubelet이 회수하는 리소스의 양이 적 으면 시스템이 반복적으로 제거 임계 값에 도달 할 수 있습니다. 이는 잘못된 예약 결정과 Pod의 빈번한 제거로 이어질 수 있으므로 바람직한 동작이 아닙니다.  
> 이 시나리오를 방지하기 위해 사용자는 —- eviction-minimum-reclaimkubelet 바이너리에서 플래그를 사용하여 리소스 당 최소 회수 수준을 설정할 수 있다.

## Node-pressure Eviction - Best practices
**다음과 같이 클러스터 크기에 따라 래더를 설정합니다 (GKE 권장)**

- 메모리 자원의 경우: 할당 가능 = 용량 - 예약 됨 - 퇴거 임계 값
  - 메모리가 1GB 미만인 경우 255MiB를 설정하십시오.
  - 메모리가 4G보다 큽니다. 처음 4GB 메모리의 25 %를 설정합니다.
  - 다음 4GB 메모리의 20 % (최대 8GB)
  - 8GB RAM의 다음 10 % (최대 16GB)
  - 112GB 메모리의 다음 6 % (최대 128GB)
  - 128GB 이상 메모리의 2 %
  - 1.12.0 이전 버전에서는 메모리가 1GB 미만인 노드는 메모리를 예약 할 필요가 없습니다.
  
- CPU 리소스의 경우 :
  - 첫 번째 코어의 6 %
  - 다음 코어의 1 % (최대 2 개 코어)
  - 다음 2 개 코어의 0.5 % (최대 4 개 코어)
  - 4 개 이상의 코어는 전체의 0.25 %입니다.

- 노드의 할당 가능한 리소스보기 :
```sh
## Allocatable 값을 기준으로 Before 4 line / After 3 line 출력
$ kubectl describe node [NODE_NAME] | grep Allocatable -B 4 -A 3

Capacity:
 cpu:                24
 ephemeral-storage:  83874796Ki
 hugepages-2Mi:      0
 memory:             16250408Ki
 pods:               110
Allocatable:
 cpu:                24
 ephemeral-storage:  77299011866
 hugepages-2Mi:      0
 memory:             16148008Ki
 pods:               110
```


- Eviction 구성
```sh
--eviction-hard=memory.available<5%,nodefs.available<10%,imagefs.available<10%

--eviction-soft=memory.available<10%,nodefs.available<15%,imagefs.available<15%

--eviction-soft-grace-period=memory.available=2m,nodefs.available=2m,imagefs.available=2m

--eviction-max-pod-grace-period=30

--eviction-minimum-reclaim=memory.available=0Mi,nodefs.available=500Mi,imagefs.available=500Mi

```

## 라이브 클러스터에서 노드의 Kubelet 재구성
자세한 내용은 [ [여기](../../../cluster/doc/Cluster%20installation/zzz-dynamic-kublet-configuration.md) ] 참조.
```sh
$ kubectl -n kube-system get cm
$ kubectl -n kube-system edit cm kubelet-config-1.21


## 아래 내용 configmap에 추가
    eviction-hard:
      memory.available: "5%"
      nodefs.available: "10%"
      imagefs.available: "10%"
    eviction-soft:
      memory.available: "10%"
      nodefs.available: "15%"
      imagefs.available: "15%"
    eviction-soft-grace-period:
      memory.available: "2m"
      nodefs.available: "2m"
      imagefs.available: "2m"
    eviction-soft-grace-period: 30
    eviction-minimum-reclaim:
      memory.available: "0Mi"
      nodefs.available: "500Mi"
      imagefs.available: "500Mi"
```

## 새 구성을 사용하도록 노드 설정
다음 명령을 사용하여 새 ConfigMap을 가리 키도록 노드의 참조를 편집하십시오
```sh
kubectl edit node ${NODE_NAME}
```

텍스트 편집기에서 아래에 다음 YAML을 추가합니다 spec.
```
spec:
  configSource:
    configMap:
      name: CONFIG_MAP_NAME # replace CONFIG_MAP_NAME with the name of the ConfigMap
      namespace: kube-system
      kubeletConfigKey: kubelet
```



## 노드 리소스 점유에 따른 조치 
```sh
## 
kubectl describe nodes vm-live-02 | grep Allocatable -B 4 -A 3

##
--eviction-hard=memory.available<500Mi
--system-reserved=memory=1.5Gi
```



-----
# 참조
> [Node-pressure Eviction](https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/)
> [라이브 클러스터에서 노드의 Kubelet 재구성](https://kubernetes.io/docs/tasks/administer-cluster/reconfigure-kubelet/)
> [라이브 클러스터에서 노드의 Kubelet 재구성](https://kubernetes.io/docs/tasks/administer-cluster/reconfigure-kubelet/)