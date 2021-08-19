# M3db Getting Start
M3는 Uber에서 제작한 플랫폼 으로 프로메테우스와 차량 및 온라인 서비스를 유지하기 위해 사용하는 수 천개의 마이크로 서비스를 모니터링하는데 사용한다. 문제는 오픈 소스이기는 하지만 최근까지 문서화 등에서 진척이 없다는 점이다.

- M3DB
모든 프로메테우스 메트릭을 보유하는 TSDB Time Series Database 이며 분산되고 가용성이 높으며 복제 기능이 있는 데이터베이스로 합의 알고리즘으로 ETCD를 사용한다.

- M3Coordinator
프로메테우스와 M3DB를 연결하는 아답터로 프로메테우스가 DB로 데이터를 쓰고/읽는 엔드포인트를 노출한다.

- M3Query
선택적이며 프로메테우스에서 데이터를 가져오는 대신 동일한 PromQL을 구현하고 응답한다.

- M3Aggregator
선택적이지만 중요한 요소로 장기 저장을 위한 메트릭 다운 샘플링 처리를 수행한다.
  
## Architecture

![M3DB Architecture](./images/m3db-cluster-architecture.png)


## Installation M3db Operator
- Helm Installation
```
helm upgrade m3db -i \
  -n m3db \
  --create-namespace \
  --cleanup-on-fail \
  --repo https://m3-helm-charts.storage.googleapis.com/stable \
  m3db-operator
```

- Manually Installation
```sh
kubectl apply -f https://raw.githubusercontent.com/m3db/m3db-operator/master/bundle.yaml
```

## Installation External etcd (etcd pod 배포시)
k8s Control plane etcd를 사용시에는 [Configuring an External etcd](./m3db-etcd-operations.md)를 참조 한다.
- Etcd Cluster installation
  - etcd 배포 yaml을 내려받아 환경에 맞게 수정 한다. (affinity / volumeClaimTemplates)
  > [ 주의 ]
  > **etcd** 볼륨을 nfs 사용시 “apply entries took too long” 문제 발생
  > **etcd** 안정성을 최대화하려면 대기 시간이 일관되게 가장 짧은 스토리지 기술을 사용하는 것이 좋습니다.
  > NVMe 또는 SSD와 같이 직렬 쓰기(fsync)를 빠르게 처리하는 스토리지와 함께 etcd를 사용하는 것이 좋습니다. Ceph, NFS 및 회전 디스크는 권장되지 않습니다.

  ```sh
  curl -O https://raw.githubusercontent.com/m3db/m3db-operator/v0.10.0/example/etcd/etcd-pd.yaml
  ```
  - affinity 설정을 아래와 같이 한다.
```sh
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: kubernetes.io/hostname
                    operator: In
                    values:
                      - node2
                      - node3
                      - node4
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 1
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: "app"
                      operator: In
                      values:
                        - etcd
                topologyKey: "kubernetes.io/hostname"
```

## Installation sysctl-daemonset
- https://github.com/m3db/m3/blob/master/kube/sysctl-daemonset.yaml  
이 매니페스트는 호스트의 sysctls가 M3DB의 권장 값으로 설정되었는지 확인하는 데몬셋을 제공한다.
> [ WARNING ]
> 호스트에서 PRIVILEGED ROOT 컨테이너가 실행된다.
> 호스트 sysctl 값을 수정한다

- m3db 권장 설정 값은 아래를 참조 한다.
  - M3DB는 성능을 위해 많은 mmap-ed 파일을 사용합니다. 나중에 돌아와서 문제를 디버그할 필요가 없도록 이 값을 3000000으로 설정하는 것이 좋습니다.
  - Linux 에서 아래 명령어 사용
  ```sh
  # vm.max_map_count :
  sysctl -w vm.max_map_count=3000000
  ```

  - M3DB는 또한 많은 수의 파일을 사용할 수 있으며 파티션별 파일 세트 볼륨으로 인해 최대 파일 열기 수를 높게 설정하는 것이 좋습니다.
  - Linux 에서 아래 명령어 사용
  ```sh
  # fs.file-max / fs.nr_open
  # 이 값을 영구적으로 설정하려면 /etc/sysctl.conf 의 fs.file-max및 fs.nr_open설정을 업데이트한다.
  sysctl -w fs.file-max=3000000
  sysctl -w fs.nr_open=3000000
  ```

## Create M3DB Cluster
- Prerequisites
  - M3DB Operator 
  - ETCD
  - sysctl-daemonset.yaml

- M3DBCluster를 배포 한다.
여기에서는 Replication Factor(replicationFactor) 값을 1로 설정 하여 배포 하였다.
권장 사항에 대한 내용은 [Replication and Deployment in Zones](https://m3db.io/docs/operational_guide/replication_and_deployment_in_zones/)을 참조 한다.
> [ 참조 ]
> 상세 spec 설정은 M3DB Operator Documentation([API Docs](https://operator.m3db.io/api/))에서 확인 할 수 있다.
```sh
apiVersion: operator.m3db.io/v1alpha1
kind: M3DBCluster
metadata:
  name: m3-cluster
  labels:
    app: m3dbnode
  namespace: m3db
spec:
  image: quay.io/m3db/m3dbnode:latest
  replicationFactor: 1
  numberOfShards: 12
  keepEtcdDataOnDelete: true
  # externalCoordinator: - 활성화시 namespace가 생성 되지 않고 watch에서 멈춰 있는다.
  #   selector:
  #     app: m3coordinator
  #   serviceEndpoint: m3coordinator.m3db:7201
  # configMapName: m3db-config
  etcdEndpoints:
    # - https://<hostIP>:2379
    - http://etcd-0.etcd:2379
    - http://etcd-1.etcd:2379
    - http://etcd-2.etcd:2379

  isolationGroups:
    - name: group1
      numInstances: 2
      nodeAffinityTerms:
        - key: kubernetes.io/hostname
          values:
          - node5
          - node7
      usePodAntiAffinity: true
      podAffinityToplogyKey: kubernetes.io/hostname
    #   nodeAffinityTerms:
    #     - key: kubernetes.io/hostname
    #       values:
    #         - node2
    # - name: group2
    #   numInstances: 1
    #   nodeAffinityTerms:
    #     - key: kubernetes.io/hostname
    #       values:
    #         - node3
    # - name: group3
    #   numInstances: 1
    #   nodeAffinityTerms:
    #     - key: kubernetes.io/hostname
    #       values:
    #         - node4
  podIdentityConfig:
    sources:
      - PodUID
  namespaces:
    - name: default
      options:
        bootstrapEnabled: true
        flushEnabled: true
        writesToCommitLog: true
        cleanupEnabled: true
        snapshotEnabled: true
        repairEnabled: false
        retentionOptions:
          retentionPeriod: 240h
          blockSize: 60m
          bufferFuture: 10m
          bufferPast: 10m
          blockDataExpiry: true
          blockDataExpiryAfterNotAccessPeriod: 5m
        indexOptions:
          enabled: true
          blockSize: 60m
        aggregationOptions:
          aggregations:
            - aggregated: false
    - name: metrics-10s_2d
      options:
        bootstrapEnabled: true
        flushEnabled: true
        writesToCommitLog: true
        cleanupEnabled: true
        snapshotEnabled: true
        repairEnabled: false
        retentionOptions:
          retentionPeriod: 280h
          blockSize: 60m
          bufferFuture: 10m
          bufferPast: 10m
          blockDataExpiry: true
          blockDataExpiryAfterNotAccessPeriod: 5m
        indexOptions:
          enabled: true
          blockSize: 60m
        aggregationOptions:
          aggregations:
            - aggregated: true
              attributes:
                resolution: 10s
                downsampleOptions:
                  all: false
  containerResources:
    requests:
      memory: 6.8Gi
    limits:
      memory: 6.8Gi
  dataDirVolumeClaimTemplate:
    metadata:
      name: m3db-data
    spec:
      storageClassName: nfs-storageclass
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 30Gi
```
## M3 Aggregator로 지표(Metrics) 집계 설정 - Setup Placement for M3Coordinator and M3Aggregator
M3 Aggregator는 M3DB 노드에 메트릭을 저장하기 전에 상태 기반 스트림 기반 다운샘플링을 제공하는 전용 메트릭 애그리게이터입니다. etcd에 저장된 동적 규칙을 사용합니다.

- Initializing aggregator topology(placement)
```sh
kubectl -n m3db exec m3-cluster-rep0-0 -- curl -vvvsSf -H "Cluster-Environment-Name: m3db/m3-cluster" -X POST http://localhost:7201/api/v1/services/m3aggregator/placement/init -d '{
    "num_shards": 12,
    "replication_factor": 2,
    "instances": [
        {
            "id": "m3aggregator-0",
            "isolation_group": "group1",
            "zone": "embedded",
            "weight": 100,
            "endpoint": "m3aggregator.m3db:6000",
            "hostname": "m3aggregator-0",
            "port": 6000
        },
        {
            "id": "m3aggregator-1",
            "isolation_group": "group2",
            "zone": "embedded",
            "weight": 100,
            "endpoint": "m3aggregator.m3db:6000",
            "hostname": "m3aggregator-1",
            "port": 6000
        }
    ]
}' | jq .

## 확인
# kubectl -n m3db exec m3-cluster-rep0-0 -- curl http://localhost:7201/api/v1/services/m3aggregator/placement | jq .
```

- Initialize m3msg topic for m3aggregator to receive from m3coordinator to aggregate metrics - m3aggregator가 m3coordinators로부터 수신하여 메트릭을 집계하도록 m3msg topic 초기화
```sh
kubectl -n m3db exec m3-cluster-rep0-0 -- curl -vvvsSf -H "Cluster-Environment-Name: m3db/m3-cluster" -H "Topic-Name: aggregator_ingest" -X POST http://localhost:7201/api/v1/topic/init -d '{
    "numberOfShards": 12
}' | jq .
```
- # Add m3aggregator consumer group to ingest topic - 주제 수집에 m3aggregator 소비자 그룹 추가
m3aggregator 주제에서 트래픽을 수신 할 배치(placement)를 추가합니다
```sh
kubectl -n m3db exec m3-cluster-rep0-0 -- curl -vvvsSf -H "Cluster-Environment-Name: m3db/m3-cluster" -H "Topic-Name: aggregator_ingest" -X POST http://localhost:7201/api/v1/topic -d '{
  "consumerService": {
    "serviceId": {
      "name": "m3aggregator",
      "environment": "m3db/m3-cluster",
      "zone": "embedded"
    },
    "consumptionType": "REPLICATED",
    "messageTtlNanos": "300000000000"
  }
}' | jq .

## 확인
# kubectl -n m3db exec m3-cluster-rep0-0 -- curl -vvvsSf -H "Cluster-Environment-Name: m3db/m3-cluster" -H "Topic-Name: aggregator_ingest" http://localhost:7201/api/v1/topic | jq .
```


- Initializing m3msg topic for m3coordinator to receive from m3aggregator to write m3db - M3DB에 쓰기 위해 m3aggregator에서 수신할 m3coordinator에 대한 m3msg 주제 초기화
m3coordinator 인스턴스에서 집계된 메트릭을 m3aggregator에서 수신하여 M3DB에 쓸 주제를 설정해야 한다.
```sh
kubectl -n m3db exec m3-cluster-rep0-0 -- curl -vvvsSf -H "Cluster-Environment-Name: m3db/m3-cluster" -H "Topic-Name: aggregated_metrics" -X POST http://localhost:7201/api/v1/topic/init -d '{
    "numberOfShards": 12
}' | jq .
```

- Add m3coordinator consumer group to outbound topic - 아웃바운드 주제에 m3coordinator 소비자 그룹 추가 
m3coordinator 주제에서 트래픽을 수신 할 배치(placement)를 추가합니다
```sh
kubectl -n m3db exec m3-cluster-rep0-0 -- curl -vvvsSf -H "Cluster-Environment-Name: m3db/m3-cluster" -H "Topic-Name: aggregated_metrics" -X POST http://localhost:7201/api/v1/topic -d '{
  "consumerService": {
    "serviceId": {
      "name": "m3coordinator",
      "environment": "m3db/m3-cluster",
      "zone": "embedded"
    },
    "consumptionType": "SHARED",
    "messageTtlNanos": "300000000000"
  }
}' | jq .

## 확인
# kubectl -n m3db exec m3-cluster-rep0-0 -- curl -vvvsSf -H "Cluster-Environment-Name: m3db/m3-cluster" -H "Topic-Name: aggregated_metrics" http://localhost:7201/api/v1/topic | jq .
```


- Initializing m3coordinator topology(placement)
m3coordinator에서 이 주제에 대한 트래픽을 수신하도록 인스턴스를 구성해야 한다
```sh
kubectl -n m3db exec m3-cluster-rep0-0 -- curl -vvvsSf -H "Cluster-Environment-Name: m3db/m3-cluster" -X POST http://localhost:7201/api/v1/services/m3coordinator/placement/init -d '{
    "instances": [
        {
            "id": "m3coordinator-0",
            "zone": "embedded",
            "endpoint": "m3coordinator.m3db:7507",
            "hostname": "m3coordinator-0",
            "port": 7507
        },
        {
            "id": "m3coordinator-1",
            "zone": "embedded",
            "endpoint": "m3coordinator.m3db:7507",
            "hostname": "m3coordinator-1",
            "port": 7507
        }
    ]
}' | jq .

## 확인
# kubectl -n m3db exec m3-cluster-rep0-0 -- curl -vvvsSf -H "Cluster-Environment-Name: m3db/m3-cluster" http://localhost:7201/api/v1/services/m3coordinator/placement | jq .
```

## Create M3Coordinator
M3 Coordinator는 Prometheus와 같은 업스트림 시스템과 M3DB와 같은 다운스트림 시스템 간의 읽기 및 쓰기를 조정하는 서비스다.


- 사전준비
  - Initializing m3coordinator topology

- installation Manual
  - External etcd의 tls 설정을 configMap에 추가 한다.
  - External etcd의 tls 시크릿 사용을 위해 statefulset에 볼륨을 추가 한다.
```sh
kubectl -n m3db apply -f 
```

 


## Prometheus configuration
프로메테우스의 모니터링 설정은 [여기](./m3db-prometheus-monitoring.md)에서 확인 할 수 있다.
- Add to your Prometheus configuration.
  - remote read/write endpoints를 설정 한다.
  Prometheus의 [Remote Endpoints and Storage](https://prometheus.io/docs/operating/integrations/#remote-endpoints-and-storage)에서 확인 할 수 있다.
  > [ 참조 ]
  > [REMOTE WRITE TUNING](https://prometheus.io/docs/practices/remote_write/#remote-write-tuning)
  > CONFIGURATION 속성: [<remote_write>](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#remote_write), [<remote_read>](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#remote_read)
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

## Prometheus Helm Chart 변경 사항
- m3db 사용시 tsdb 설정을 사용 안함으로 변경 함.
  - deployment에서 args: tsdb 설정 삭제
- m3db 사용시 pvc 설정을 사용 안함으로 변경 함.
- m3db 사용시 remoteWrite/remoteRead 설정 변경
  - remoteStorage 항목을 추가 하여 사용여부(enabled)를 설정 한다.
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
> [Custom Resource Definitions used by the M3DB Operator](https://m3db.io/docs/operator/api/)
> [M3로 etcd를 작동하기 위한 모범 사례](https://m3db.io/docs/operational_guide/etcd/#best-practices-for-operating-etcd-with-m3)
> []