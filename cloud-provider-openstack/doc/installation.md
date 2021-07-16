# cloud-provider-openstack 설치 방법

## 1. MasterNode 설정
> Master 노드별 설정
```sh
$ cd /etc/kubernetes/manifests

$ vi kube-apiserver.yaml
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubeadm.kubernetes.io/kube-apiserver.advertise-address.endpoint: 172.16.77.31:6443
  creationTimestamp: null
  labels:
    component: kube-apiserver
    tier: control-plane
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-apiserver
    - --advertise-address=172.16.77.31
    - --allow-privileged=true
    - --apiserver-count=1
    - --authorization-mode=Node,RBAC
    - --bind-address=0.0.0.0
    - --client-ca-file=/etc/kubernetes/pki/ca.crt
    - --cloud-provider=external  # cloud-provider 추가
    - --default-not-ready-toleration-seconds=30
    - --default-unreachable-toleration-seconds=30
    - --enable-admission-plugins=NodeRestriction
    - --enable-bootstrap-token-auth=true
    - --encryption-provider-config=/etc/kubernetes/secrets_encryption.yaml
    - --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
    - --etcd-certfile=/etc/kubernetes/pki/etcd/server.crt
    - --etcd-keyfile=/etc/kubernetes/pki/etcd/server.key
    - --etcd-servers=https://172.16.77.31:2379
    - --feature-gates=TTLAfterFinished=true,RemoveSelfLink=false,LocalStorageCapacityIsolation=true
    - --insecure-port=0
```

```sh
$ cd /etc/kubernetes/manifests

$ vi kube-controller-manager.yaml
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    component: kube-controller-manager
    tier: control-plane
  name: kube-controller-manager
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-controller-manager
    - --address=0.0.0.0
    - --allocate-node-cidrs=true
    - --authentication-kubeconfig=/etc/kubernetes/controller-manager.conf
    - --authorization-kubeconfig=/etc/kubernetes/controller-manager.conf
    - --bind-address=127.0.0.1
    - --client-ca-file=/etc/kubernetes/pki/ca.crt
    - --cloud-provider=external  # cloud-provider 추가
    - --cluster-cidr=10.32.0.0/12
    - --cluster-name=kubernetes
    - --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt
    - --cluster-signing-key-file=/etc/kubernetes/pki/ca.key
    - --controllers=*,bootstrapsigner,tokencleaner
    - --feature-gates=TTLAfterFinished=true,RemoveSelfLink=false
    - --kubeconfig=/etc/kubernetes/controller-manager.conf
    - --leader-elect=true
    - --node-monitor-grace-period=16s
    - --node-monitor-period=2s
    - --port=0
```
```sh
$ kubectl -n kube-system describe po kube-apiserver-vm-live-01
$ kubectl -n kube-system describe po kube-controller-manager-vm-live-01
    .......................
    ...............

    Port:          <none>
    Host Port:     <none>
    Command:
      kube-apiserver
      --advertise-address=172.16.77.31
      --allow-privileged=true
      --apiserver-count=1
      --authorization-mode=Node,RBAC
      --bind-address=0.0.0.0
      --client-ca-file=/etc/kubernetes/pki/ca.crt
      --cloud-provider=external # 이부분 확인
      --default-not-ready-toleration-seconds=30

    ...............
    .......................

# kube-apiserver-xxx 및 kube-controller-xxx Pod에 param 정보가 추가 되었는지 확인한다.
# 만약 설정이 설정이 안된경우 apiserver , controller-manager 재시작
```

## 2. WorkerNode 설정
> Worker 노드별 설정
```sh
$ cd /etc/sysconfig

$ vi kubelet

====================================================================

KUBELET_EXTRA_ARGS="--log-dir=/data/log \
--logtostderr=false \
--cloud-provider=external \ # 이부분 추가
--v=2 \
--container-runtime=remote \
--runtime-request-timeout=15m \
--container-runtime-endpoint=unix:///run/containerd/containerd.sock \
--node-labels=cube.acornsoft.io/clusterid=k3lab-live"

=====================================================================
$ systemctl restart kubelet

$ systemctl status kubelet

● kubelet.service - kubelet: The Kubernetes Node Agent
   Loaded: loaded (/usr/lib/systemd/system/kubelet.service; enabled; vendor preset: disabled)
  Drop-In: /usr/lib/systemd/system/kubelet.service.d
           └─10-kubeadm.conf
   Active: active (running) since Wed 2021-07-14 04:22:01 UTC; 57min ago
     Docs: https://kubernetes.io/docs/
 Main PID: 3798455 (kubelet)
    Tasks: 32 (limit: 101363)
   Memory: 94.0M
   CGroup: /system.slice/kubelet.service
           └─3798455 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf
```

## 3. openstack controller 배포

### 3-1 Secret 생성

> cloud.conf 정보는 openstack 의 접속 정보 및 네트워크 정보를 포함하고 있음.
```sh
[Global]
auth-url=http://192.168.77.11/identity      # 접속 URL
username=admin                              # 아이디
password=@c0rns0ft                          # 패스워드
region=RegionOne
tenant-id=1cf5fa24ba31447d8e8757015af0463b  # project ID (NO.1)
domain-id=default                           # demain ID (NO.2)

[LoadBalancer]                              # default
use-octavia=true
subnet-id=d4c17b7f-124d-424d-97ef-a8d038f4144b  #subnet ID (NO.3)
floating-network-id=3bd5f7f4-da7b-4756-8609-514f16666296  # network ID (NO.4)

```
> project ID (NO.1) -> Project ID 필드
![jaeger-spans-traces](images/projectid.png)

> demain ID (NO.2)  -> 예) k3lab-live > 도메인 아이디
![jaeger-spans-traces](images/domain.png)

> subnet ID (NO.3) -> 예) k3lab-live-net > ID 항목
![jaeger-spans-traces](images/subnet.png)

> network ID (NO.4) -> 예) public-subnet > 네트워크 ID 항목
![jaeger-spans-traces](images/floating.png)

> Secret 생성 (cloud-config-secret.yaml)
```sh

apiVersion: v1
data:
  cloud.conf: IyBrM2xhYi1saXZlIGNsb3VkIGNvbmZpZ3VyYXRpb24KW0dsb2JhbF0KYXV0aC11cmw9aHR0cDovLzE5Mi4xNjguNzcuMTEvaWRlbnRpdHkKdXNlcm5hbWU9YWRtaW4KcGFzc3dvcmQ9QGMwcm5zMGZ0CnJlZ2lvbj1SZWdpb25PbmUKdGVuYW50LWlkPTFjZjVmYTI0YmEzMTQ0N2Q4ZTg3NTcwMTVhZjA0NjNiCmRvbWFpbi1pZD1kZWZhdWx0CgpbTG9hZEJhbGFuY2VyXQp1c2Utb2N0YXZpYT10cnVlCnN1Ym5ldC1pZD1kNGMxN2I3Zi0xMjRkLTQyNGQtOTdlZi1hOGQwMzhmNDE0NGIKZmxvYXRpbmctbmV0d29yay1pZD0zYmQ1ZjdmNC1kYTdiLTQ3NTYtODYwOS01MTRmMTY2NjYyOTYKCiNbQmxvY2tTdG9yYWdlXQojYnMtdmVyc2lvbj12Mg==
kind: Secret
metadata:
  name: cloud-config
  namespace: kube-system
type: Opaque

# cloud.conf : base64 encodeing (cloud-config file)
$ kubectl apply -f cloud-config-secret.yaml
```

### 3-2 RBAC, openstack-cloud-controller-namager 생성
```sh
$ kubectl apply -f cloud-controller-manager-role.yaml
$ kubectl apply -f cloud-controller-manager-role-bindings.yaml
$ kubectl apply -f openstack-cloud-controller-manager-ds.yaml
```

## 4. openstack controller 배포 확인 및 테스트
```sh

# 배포 확인
$ k get po -n kube-system

NAME                                       READY   STATUS    RESTARTS   AGE
kube-proxy-rgmr7                           1/1     Running   36         97d
kube-scheduler-vm-live-01                  1/1     Running   535        21d
kube-state-metrics-55cb7cd98b-js6r5        1/1     Running   2          5d22h
metrics-server-6d7588485b-fvmr5            1/1     Running   8          5d19h
nfs-pod-provisioner-6949dbbbd5-nmz2r       1/1     Running   9          5d22h
openstack-cloud-controller-manager-bf55q   1/1     Running   0          36m
openstack-cloud-controller-manager-dqgtz   1/1     Running   0          36m
openstack-cloud-controller-manager-hgjzh   1/1     Running   0          36m
snapshot-controller-0                      1/1     Running   1          5d22h

# Pod 배포
$ kubectl run nginx --image=192.168.77.30/library/nginx:latest --port=80

$ kubectl get po
NAME                                READY   STATUS    RESTARTS   AGE
my-app-58cbb9b58d-rl2gr             1/1     Running   1          5d23h
nginx                               1/1     Running   0          73m

# LoadBalancer 타입의 service 배포
$ k expose pod nginx --type=LoadBalancer --target-port=80 --port=80 --name nginx

$ kubectl get svc
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
kubernetes   ClusterIP      10.96.0.1       <none>           443/TCP        97d
nginx        LoadBalancer   10.107.33.228   192.168.77.108   80:32326/TCP   73m

# EXTERNAL-IP 로 접속 시도
```
![jaeger-spans-traces](images/nginx.png)
