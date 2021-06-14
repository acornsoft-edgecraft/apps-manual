[TOC]

## 1. 사전설정

```bash
swapoff -a

vi /etc/fstab
UUID=8ac075e3-1124-4bb6-bef7-a6811bf8b870 /    xfs     defaults    0 0
#/swapfile none swap defaults 0 0

setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

systemctl stop firewalld
systemctl disable firewalld
```



## 2. docker 설치

```bash
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum update -y && yum install -y containerd.io-1.2.13 docker-ce-19.03.8 docker-ce-cli-19.03.8

mkdir /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

mkdir -p /etc/systemd/system/docker.service.d
systemctl daemon-reload
systemctl restart docker
```



## 3. Containerd 설치

```bash
cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system

mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml

vi /etc/containerd/config.toml
plugins.cri.systemd_cgroup = true
systemctl restart containerd
```



## 4. crictl 설정

```
cat > /etc/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
EOF
```



## 5. kubeadm 으로 클러스터 생성

```bash
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

yum install -y kubelet-1.17.4 kubeadm-1.17.4 kubectl-1.17.4 --disableexcludes=kubernetes

cat > /etc/sysconfig/kubelet <<EOF
KUBELET_EXTRA_ARGS=--cgroup-driver=systemd
EOF

cat > /usr/lib/systemd/system/kubelet.service.d/20-cri.conf <<EOF
[Service]
Environment="KUBELET_EXTRA_ARGS=--container-runtime=remote --runtime-request-timeout=15m --container-runtime-endpoint=unix:///run/containerd/containerd.sock"
EOF
systemctl daemon-reload

--container-runtime=remote \
--container-runtime-endpoint={{ cri_socket }} \
```

K8s HA cluster를 구성하기 위해서는 kubeadm의 설정파일인 kubeadm-config.yaml파일을 환경에 맞게 먼저 작성한다.

```yaml
$ vi /etc/kubernetes/kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta1
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 192.168.1.141
  bindPort: 6443
---
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
networking:
  dnsDomain: cluster.local
  serviceSubnet: 10.96.0.0/12
  podSubnet: 10.32.0.0/12
kubernetesVersion: 1.13.5
controlPlaneEndpoint: 192.168.1.141:6443
certificatesDir: /etc/kubernetes/pki



cat > config.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1beta1
kind: InitConfiguration
nodeRegistration:
  criSocket: /run/containerd/containerd.sock
---
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: v1.14.6
clusterName: kubernetes
certificatesDir: /etc/kubernetes/pki
imageRepository: k8s.gcr.io
networking:
  dnsDomain: cluster.local
  podSubnet: "10.10.0.0/16"
  serviceSubnet: 10.96.0.0/12
etcd:
  local:
    dataDir: /var/lib/etcd
apiServer:
  extraArgs:
    bind-address: "0.0.0.0"
  timeoutForControlPlane: 4m0s
controllerManager:
  extraArgs:
    address: "0.0.0.0"
scheduler:
  extraArgs:
    address: "0.0.0.0"
dns:
  type: CoreDNS
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
EOF

kubeadm init --config config.yaml
```



master1번 장비에서 아래 실행.

```bash
kubeadm init --config=/etc/kubernetes/kubeadm-config.yaml --ignore-preflight-errors=all
```

나머지 mater node에서 cluster에 join하기 위해 아래 파일을 master1에서 나머지 master node로 복사함.

```bash
scp /etc/kubernetes/pki/ca.* root@192.168.1.142:/etc/kubernetes/pki
scp /etc/kubernetes/pki/sa.* root@192.168.1.142:/etc/kubernetes/pki
scp /etc/kubernetes/pki/front-proxy-ca* root@192.168.1.142:/etc/kubernetes/pki
scp /etc/kubernetes/pki/etcd/ca* root@192.168.1.142:/etc/kubernetes/pki/etcd
scp /etc/kubernetes/pki/ca.* root@192.168.1.143:/etc/kubernetes/pki
scp /etc/kubernetes/pki/sa.* root@192.168.1.143:/etc/kubernetes/pki
scp /etc/kubernetes/pki/front-proxy-ca* root@192.168.1.143:/etc/kubernetes/pki
scp /etc/kubernetes/pki/etcd/ca* root@192.168.1.143:/etc/kubernetes/pki/etcd
```

master1번에서 kubeadm init 명령의 결과로 출력되는 join 명령을 copy하여 나머지 master node에서 실행.

```bash
kubeadm join 192.168.1.141:6443 --token tfuzvi.pc63qr4u1q99o27m --discovery-token-ca-cert-hash sha256:08a81818812483b6432d689f20a068d021d900a810d4a98d77f246f5f84c22a5 --experimental-control-plane
```



master1번에서 kubeadm init 명령의 결과로 출력되는 join 명령을 copy하여 나머지 master node에서 실행.

```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```



```bash
kubeadm join 192.168.1.141:6443 --token tfuzvi.pc63qr4u1q99o27m --discovery-token-ca-cert-hash sha256:08a81818812483b6432d689f20a068d021d900a810d4a98d77f246f5f84c22a5 --ignore-preflight-errors=all
```
