[TOC]

## K8S worker node 구성
 * /etc/kubernetes/kubelet.conf 가 존재하면 node가 join 되어 있다고 가정한다.
 * kubectl, kubelet, kubeadm package를 설치하고 ubunutu의 경우 hold로 mark함으로 apt upgrade시 자동 upgrade되는 것을 방지한다.
 * kubeadm-client.conf 파일 구성
 * kubeadm join 
 * /etc/kubernetes/kubelet.conf설정 파일 구성
 * Node label 설정 


### 개별 master node TLS 인증서 생성
 
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

### kubeadm join
```bash
$ kubeadm --kubeconfig=/etc/kubernetes/admin.conf token create

$ cat > /etc/kubernetes/kubeadm-client.conf <<EOF
apiVersion: kubeadm.k8s.io/v1beta2
kind: JoinConfiguration
caCertPath: /etc/kubernetes/pki/ca.crt
discovery:
  bootstrapToken:
    apiServerEndpoint: 192.168.77.223:6443
    token: s3vhzz.aahlr0idsm3y4wmi
    unsafeSkipCAVerification: true
EOF

// Ubuntu: /etc/default/kubelet, Centos: /etc/default/kubelet
$ cat > /etc/sysconfig/kubelet <<EOF
KUBELET_EXTRA_ARGS="--root-dir=/data/kubelet \
--log-dir=/data/log \
--logtostderr=false \
--v=2 \
--container-runtime=remote \
--runtime-request-timeout=15m \
--container-runtime-endpoint=unix:///run/containerd/containerd.sock \
--node-labels=cube.acornsoft.io/clusterid=test-cluster"
EOF

$ systemctl daemon-reload
$ systemctl start kubelet

$ kubeadm join --config /etc/kubernetes/kubeadm-client.conf --ignore-preflight-errors=all
```

### kubelet.conf 파일 수정
```bash
$ sed -i 's#server:.*#server: {{ api_lb_ip }}#g' /etc/kubernetes/kubelet.conf
$ sed -i 's#server:.*#server: https://localhost:6443#g' /etc/kubernetes/kubelet.conf
```

### Node label
```bash
$ kubectl --kubeconfig=/etc/kubernetes/admin.conf label node node1 node-role.kubernetes.io/node='' --overwrite
```
