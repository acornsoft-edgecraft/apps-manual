[TOC]

## K8S master node 구성
 * 각 master node에서 control plane 구성에 필요한 TLS 인증서를 생성한다.
 * /etc/kubernetes/pki/apiserver.key파일이 존재하면 이미 인증서가 생성되어 있다고 가정하고 skip한다.
 * kubectl, kubelet, kubeadm package를 설치하고 ubunutu의 경우 hold로 mark함으로 apt upgrade시 자동 upgrade되는 것을 방지한다.
 * jq 명령 설치
 * audit policy, secret encryption 구성
 * kubeadm.yaml 파일 구성
 * /etc/kubelet/kubelet 설정 파일 구성
 * kubelet 기동
 * kubeadm init으로 초기 master 구성
 * admin.conf, control-manager.conf, scheduler.conf, acloud-client-kubeconfig 파일 구성
 * .profile or .bash_profile 구성
 * Calico, Metrics server 설치

### 개별 master node TLS 인증서 생성
 
```bash
$ openssl genrsa -out /etc/kubernetes/pki/apiserver.key 2048
$ openssl req -new -key /etc/kubernetes/pki/apiserver.key -subj '/CN=kube-apiserver' |
  openssl x509 -req -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out /etc/kubernetes/pki/apiserver.crt -days 36500 -extensions v3_req_apiserver -extfile /opt/kubernetes/pki/common-openssl.conf

$ openssl req -new -key /etc/kubernetes/pki/apiserver-kubelet-client.key -subj '/CN=kube-apiserver-kubelet-client/O=system:masters' |
  openssl x509 -req -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out /etc/kubernetes/pki/apiserver-kubelet-client.crt -days 36500 -extensions v3_req_client -extfile /opt/kubernetes/pki/common-openssl.conf

$ openssl genrsa -out /etc/kubernetes/pki/front-proxy-client.key 2048
$ openssl req -new -key /etc/kubernetes/pki/front-proxy-client.key -subj '/CN=front-proxy-client' |
  openssl x509 -req -CA /etc/kubernetes/pki/front-proxy-ca.crt -CAkey /etc/kubernetes/pki/front-proxy-ca.key -CAcreateserial -out /etc/kubernetes/pki/front-proxy-client.crt -days 36500 -extensions v3_req_client -extfile /opt/kubernetes/pki/common-openssl.conf

$ openssl genrsa -out /etc/kubernetes/pki/admin.key 2048
$ openssl req -new -key /etc/kubernetes/pki/admin.key -subj '/O=system:masters/CN=kubernetes-admin' |
  openssl x509 -req -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out /etc/kubernetes/pki/admin.crt -days 36500 -extensions v3_req_client -extfile /opt/kubernetes/pki/common-openssl.conf

$ openssl genrsa -out /etc/kubernetes/pki/controller-manager.key 2048
$ openssl req -new -key /etc/kubernetes/pki/controller-manager.key -subj '/CN=system:kube-controller-manager' |
  openssl x509 -req -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out /etc/kubernetes/pki/controller-manager.crt -days 36500 -extensions v3_req_client -extfile /opt/kubernetes/pki/common-openssl.conf

$ openssl genrsa -out /etc/kubernetes/pki/scheduler.key 2048
$ openssl req -new -key /etc/kubernetes/pki/scheduler.key -subj '/CN=system:kube-scheduler' |
  openssl x509 -req -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out /etc/kubernetes/pki/scheduler.crt -days 36500 -extensions v3_req_client -extfile /opt/kubernetes/pki/common-openssl.conf

$ openssl genrsa -out /etc/kubernetes/acloud/acloud-client.key 2048
$ openssl req -new -key /etc/kubernetes/acloud/acloud-client.key -subj '/CN=acloud-client' |
  openssl x509 -req -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out /etc/kubernetes/acloud/acloud-client.crt -days 36500 -extensions v3_req_client -extfile /opt/kubernetes/pki/common-openssl.conf
```

 * Ubuntu 
```bash
$ apt-get install -y kubelet=1.20.2-00 kubeadm=1.20.2-00 kubectl=1.20.2-00
$ apt-get install -y jq

```  
 * Centos, RHEL 
```bash
$ yum install -y kubelet-1.20.2 kubeadm-1.20.2 kubectl-1.20.2 --disableexcludes=kubernetes
$ yum install -y jq
```  

### Audit policy
```bash
$ cat > /etc/kubernetes/audit-policy.yaml <<EOF
apiVersion: audit.k8s.io/v1
kind: Policy
omitStages:
  - "RequestReceived"
rules:
  - level: None
    users: ["system:kube-proxy"]
    verbs: ["watch"]
    resources:
      - group: "" # core
        resources: ["endpoints", "services", "services/status"]
  - level: None
    users: ["system:unsecured"]
    namespaces: ["kube-system"]
    verbs: ["get"]
    resources:
      - group: "" # core
        resources: ["configmaps"]
  - level: None
    users: ["kubelet"] # legacy kubelet identity
    verbs: ["get"]
    resources:
      - group: "" # core
        resources: ["nodes", "nodes/status"]
  - level: None
    userGroups: ["system:nodes"]
    verbs: ["get"]
    resources:
      - group: "" # core
        resources: ["nodes", "nodes/status"]
  - level: None
    users:
      - system:kube-controller-manager
      - system:kube-scheduler
      - system:serviceaccount:kube-system:endpoint-controller
    verbs: ["get", "update"]
    namespaces: ["kube-system"]
    resources:
      - group: "" # core
        resources: ["endpoints"]
  - level: None
    users: ["system:apiserver"]
    verbs: ["get"]
    resources:
      - group: "" # core
        resources: ["namespaces", "namespaces/status", "namespaces/finalize"]
  - level: None
    users:
      - system:kube-controller-manager
    verbs: ["get", "list"]
    resources:
      - group: "metrics.k8s.io"
  - level: None
    nonResourceURLs:
      - /healthz*
      - /version
      - /swagger*
  - level: None
    resources:
      - group: "" # core
        resources: ["events"]
  - level: Request
    users: ["kubelet", "system:node-problem-detector", "system:serviceaccount:kube-system:node-problem-detector"]
    verbs: ["update","patch"]
    resources:
      - group: "" # core
        resources: ["nodes/status", "pods/status"]
  - level: Request
    userGroups: ["system:nodes"]
    verbs: ["update","patch"]
    resources:
      - group: "" # core
        resources: ["nodes/status", "pods/status"]
  - level: Request
    users: ["system:serviceaccount:kube-system:namespace-controller"]
    verbs: ["deletecollection"]
  - level: Metadata
    resources:
      - group: "" # core
        resources: ["secrets", "configmaps"]
      - group: authentication.k8s.io
        resources: ["tokenreviews"]
  - level: Request
    verbs: ["get", "list", "watch"]
    resources:
      - group: "" # core
      - group: "admissionregistration.k8s.io"
      - group: "apiextensions.k8s.io"
      - group: "apiregistration.k8s.io"
      - group: "apps"
      - group: "authentication.k8s.io"
      - group: "authorization.k8s.io"
      - group: "autoscaling"
      - group: "batch"
      - group: "certificates.k8s.io"
      - group: "extensions"
      - group: "metrics.k8s.io"
      - group: "networking.k8s.io"
      - group: "policy"
      - group: "rbac.authorization.k8s.io"
      - group: "scheduling.k8s.io"
      - group: "settings.k8s.io"
      - group: "storage.k8s.io"
  - level: RequestResponse
    resources:
      - group: "" # core
      - group: "admissionregistration.k8s.io"
      - group: "apiextensions.k8s.io"
      - group: "apiregistration.k8s.io"
      - group: "apps"
      - group: "authentication.k8s.io"
      - group: "authorization.k8s.io"
      - group: "autoscaling"
      - group: "batch"
      - group: "certificates.k8s.io"
      - group: "extensions"
      - group: "metrics.k8s.io"
      - group: "networking.k8s.io"
      - group: "policy"
      - group: "rbac.authorization.k8s.io"
      - group: "scheduling.k8s.io"
      - group: "settings.k8s.io"
      - group: "storage.k8s.io"
  # Default level for all other requests.
  - level: Metadata
EOF
```

### Secret Encryption
```bash
$ cat > /etc/kubernetes/secrets_encryption.yaml <<EOF
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
    - secrets
    providers:
    - aescbc:
        keys:
        - name: cocktail
          secret: "N9o5U/W/evtItR6rUYogsh8C2x1Fre7/s4WSzmHXC7k="
    - identity: {}
EOF
```

### kubeadm init
```bash
$ cat > /etc/kubernetes/kubeadm.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 192.168.77.223
  bindPort: 6443
nodeRegistration:
  criSocket: /run/containerd/containerd.sock
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
etcd:
  external:
    endpoints:
    - https://192.168.77.223:2379
    caFile: /etc/kubernetes/pki/etcd/ca.crt
    certFile: /etc/kubernetes/pki/etcd/server.crt
    keyFile: /etc/kubernetes/pki/etcd/server.key
networking:
  dnsDomain: cluster.local
  serviceSubnet: 172.16.0.0/16
  podSubnet: 10.0.0.0/16
kubernetesVersion: 1.20.6
controlPlaneEndpoint: 192.168.77.223:6443
certificatesDir: /etc/kubernetes/pki
apiServer:
  extraArgs:
    bind-address: "0.0.0.0"
    apiserver-count: "1"
    secure-port: "6443"
    feature-gates: TTLAfterFinished=true,RemoveSelfLink=false
    default-not-ready-toleration-seconds: "30"
    default-unreachable-toleration-seconds: "30"
    encryption-provider-config: /etc/kubernetes/secrets_encryption.yaml
    audit-log-maxage: "7"
    audit-log-maxbackup: "10"
    audit-log-maxsize: "100"
    audit-log-path: /var/log/kubernetes/kubernetes-audit.log
    audit-policy-file: /etc/kubernetes/audit-policy.yaml
    audit-webhook-config-file: /etc/kubernetes/audit-webhook
  extraVolumes:
  - name: audit-policy
    hostPath: /etc/kubernetes
    mountPath: /etc/kubernetes
    pathType: DirectoryOrCreate
    readOnly: true
  - name: k8s-audit
    hostPath: /var/log/kubernetes
    mountPath: /data/k8s-audit
    pathType: DirectoryOrCreate
  certSANs:
  - 192.168.77.223
  - localhost
  - 127.0.0.1
controllerManager:
  extraArgs:
    address: "0.0.0.0"
    node-monitor-period: 2s
    node-monitor-grace-period: 16s
    feature-gates: TTLAfterFinished=true,RemoveSelfLink=false
scheduler:
  extraArgs:
    address: "0.0.0.0"
    feature-gates: TTLAfterFinished=true,RemoveSelfLink=false
imageRepository: k8s.gcr.io
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
featureGates: { TTLAfterFinished: true }
mode: ipvs
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
nodeStatusUpdateFrequency: 4s
readOnlyPort: 0
clusterDNS:
- 172.16.0.10
EOF

$ kubeadm init --config=/etc/kubernetes/kubeadm.yaml --ignore-preflight-errors=all
```

### admin.conf, controller-manager.conf, scheduler.conf 파일 구성
```bash
$ cat > /etc/kubernetes/admin.conf <<EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: {{ ca_data.stdout | b64encode }}
    server: https://{{ hostvars[inventory_hostname]['ip'] }}:{{ api_secure_port }}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: {{ admin_crt_data.stdout | b64encode }}
    client-key-data: {{ admin_key_data.stdout | b64encode }}
EOF

$ cat > /etc/kubernetes/controller-manager.conf <<EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: {{ ca_data.stdout | b64encode }}
    server: https://{{ hostvars[inventory_hostname]['ip'] }}:{{ api_secure_port }}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: system:kube-controller-manager
  name: system:kube-controller-manager@kubernetes
current-context: system:kube-controller-manager@kubernetes
kind: Config
preferences: {}
users:
- name: system:kube-controller-manager
  user:
    client-certificate-data: {{ controller_manager_crt_data.stdout | b64encode }}
    client-key-data: {{ controller_manager_key_data.stdout | b64encode }}
EOF

$ cat > /etc/kubernetes/scheduler.conf <<EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: {{ ca_data.stdout | b64encode }}
    server: https://{{ hostvars[inventory_hostname]['ip'] }}:{{ api_secure_port }}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: system:kube-scheduler
  name: system:kube-scheduler@kubernetes
current-context: system:kube-scheduler@kubernetes
kind: Config
preferences: {}
users:
- name: system:kube-scheduler
  user:
    client-certificate-data: {{ scheduler_crt_data.stdout | b64encode }}
    client-key-data: {{ scheduler_key_data.stdout | b64encode }}
EOF
```

### acloud-client-kubeconfig 파일 구성
```bash
$ openssl genrsa -out /etc/kubernetes/acloud/acloud-client.key 2048
$ openssl req -new -key /etc/kubernetes/acloud/acloud-client.key -subj '/CN=acloud-client' |
  openssl x509 -req -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out /etc/kubernetes/acloud/acloud-client.crt -days 36500 -extensions v3_req_client -extfile /opt/kubernetes/pki/common-openssl.conf

$ cat > /etc/kubernetes/acloud/acloud-client-crb.yaml <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: acloud-binding
subjects:
- kind: User
  name: acloud-client
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF

$ cat > /etc/kubernetes/acloud/acloud-client-kubeconfig <<EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: {{ acloud_client_ca_crt | b64encode }}
    server: https://{{ lb_ip }}:{{ lb_port }}
  name: acloud-client
contexts:
- context:
    cluster: acloud-client
    user: acloud-client
  name: acloud-client
current-context: acloud-client
kind: Config
preferences: {}
users:
- name: acloud-client
  user:
    client-certificate-data: {{ acloud_client_crt | b64encode }}
    client-key-data: {{ acloud_client_key | b64encode }}
EOF
```

### alias
```bash
$ cat > /root/.profile <<EOF
export ETCDCTL_API=3
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/peer.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/peer.key

export KUBECONFIG=/etc/kubernetes/admin.conf

alias ll='ls -al'
alias etcdlet="etcdctl --endpoints={{ etcd_access_addresses }} "
alias psg="ps -ef | grep "
alias wp="watch -n1 'kubectl get pods --all-namespaces -o wide'"
alias k="kubectl "
EOF
```

```bash
$ cat > /root/.profile <<EOF
export ETCDCTL_API=3
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/peer.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/peer.key

export KUBECONFIG=/etc/kubernetes/admin.conf

alias ll='ls -al'
alias etcdlet="etcdctl --endpoints={{ etcd_access_addresses }} "
alias psg="ps -ef | grep "
alias wp="watch -n1 'kubectl get pods --all-namespaces -o wide'"
alias k="kubectl "
alias cert="openssl x509 -text -noout -in "
EOF
```

### alias
 * master isolation 옵션이 있을 경우 taint 구성
```bash
kubectl --kubeconfig=/etc/kubernetes/admin.conf taint nodes node1 node-role.kubernetes.io/master:NoSchedule-
```

### metrics-server
```bash
$ scp calico.yaml root@{master1-ip}:/etc/kubernetes/addon/calico/calico.yaml
$ scp metrics-server-rbac.yaml.j2 root@{master1-ip}:/etc/kubernetes/addon/metrics-server/metrics-server-rbac.yaml
$ scp metrics-server-controller.yaml.j2 root@{master1-ip}:/etc/kubernetes/addon/metrics-server/metrics-server-controller.yaml
```

### Update apiserver endpoint in kube-proxy configmap in order to using haproxy
```bash
kubectl --kubeconfig=/etc/kubernetes/admin.conf get cm kube-proxy -n kube-system -o yaml | sed 's#server:.*#server: https://localhost:6443#g' | kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f -
kubectl --kubeconfig=/etc/kubernetes/admin.conf delete pods -n kube-system -l k8s-app=kube-proxy
```