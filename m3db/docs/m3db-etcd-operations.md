## etcd Operations
> **etcd**는 M3 스택 내의 모든 구성 요소(예: M3 Query, M3DB, M3 Aggregator)의 분산 키-값 저장소로 활용 한다. 
> **etcd** 메타데이터가 사용되는 방법의 예는 아래를 참조 한다.
> 1. 실시간으로 클러스터 구성 업데이트
> 2. M3DB 및 M3Aggregator와 같은 분산/샤딩 계층에 대한 배치 관리
> 3. M3Aggregator에서 리더 선출 수행
> 4. M3DB 클러스터 내의 노드 배치 정의
> 5. M3DB 클러스터 내에서 주어진 노드에 연결된 샤드 정의

## Configuring an External etcd (k8s Control plane etcd 사용시)
- K8s Control plane etcd를 사용시 TLS를 통한 인증을 위해서 PKI 인증서가 필요하다.
- 만약 쿠버네티스를 kubeadm으로 설치했다면 인증서는 /etc/kubernetes/pki에 저장된다.
- 인증서를 시크릿으로 생성 한다.
  - 필요한 인증서: etcd-ca(etcd/ca.crt), kube-etcd-peer(etcd/peer.key, etcd/peer.crt)
  > [ 주의 ]
  > m3db operator에서 시크릿 볼륨 생성 [ClusterSpec](https://operator.m3db.io/api/#clusterspec)을 지원 하지 않는다.
  > 해결방안: 최초 설치후 M3DBCluster의 statefulset을 직접 수정하여 볼륨 설정을 추가 한 후 operator를 삭제 한다.
  > 다른 방안으로는 운영사항에 맞게 m3db operator를 수정 할 수도 있다. 
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: etcd-tls
type: Opaque
data:
  ca.crt: |
    <ca.crt | base64 -w 0>
  etcd-client.crt: |
    <peer.crt | base64 -w 0>
  etcd-client.key: |
    <peer.key | base64 -w 0>
```

- M3DBCluster 설정에서 ClusterSpec의 **configMapName**을 사용한다.
  - 작성한 컨피그맵을 사용할 수 있다.(etcdEndpoints ClusterSpec은 주석 처리 한다.)
```yaml
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
  configMapName: m3db-config
  # etcdEndpoints:
  .
  .
  .
```
  
- M3DB Configuration file을 configmap으로 생성 한다.
> [ 주의 ]
> M3DB Documents에는 M3DB Configuration file 설정에 tls: 설정에 대한 설명이 없다. 아래와 같이 사용 할 수 있다.
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: m3db-config
data:
  m3.yml: |2

    coordinator: {}

    db:
      hostID:
        resolver: file
        file:
          path: /etc/m3db/pod-identity/identity
          timeout: 5m

      client:
        writeConsistencyLevel: majority
        readConsistencyLevel: unstrict_majority

      discovery:
        config:
          service:
            env: "m3db/m3-cluster"
            zone: embedded
            service: m3db
            cacheDir: /var/lib/m3kv
            etcdClusters:
            - zone: embedded
              endpoints:
              - "https://<hostIP>:2379"
              # TLS configuration
              tls:
                # Certificiate authority path
                caCrtPath: /etcd-secret-tls/ca.crt
                # Certificate path
                crtPath: /etcd-secret-tls/etcd-client.crt
                # Key store path
                keyPath: /etcd-secret-tls/etcd-client.key
```