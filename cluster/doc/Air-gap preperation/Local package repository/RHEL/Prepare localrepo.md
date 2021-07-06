[TOC]

# 1. Test 장비 정보
 * vm-onassis-01	centos8	172.16.0.121, 192.168.77.121 8Core.8G memory.80G disk
 * vm-onassis-02	centos8	172.16.0.122, 192.168.77.122 8Core.8G memory.80G disk
 * vm-onassis-03	centos8	172.16.0.123, 192.168.77.123 8Core.8G memory.80G disk
 * vm-onassis-04	centos8	172.16.0.124, 192.168.77.124 8Core.8G memory.80G disk
 * vm-onassis-05	centos8	172.16.0.125, 192.168.77.125 8Core.8G memory.80G disk
 * vm-onassis-06	centos8	172.16.0.126, 192.168.77.126 8Core.8G memory.80G disk
 * vm-onassis-07	centos8	172.16.0.127, 192.168.77.127 8Core.8G memory.80G disk
 * vm-onassis-08	centos8	172.16.0.128, 192.168.77.128 8Core.8G memory.80G disk

 * 장비 접속 예
```bash
$ ssh-add /Users/cloud/cert/onassis/id_rsa
$ ssh centos@192.168.77.128
$ sudo -i
``` 

# 2. Local HTTP deb Repository 준비
## 2.1. 기본 사항
 * rpm package를 192.168.77.128 서버에서 작업한다고 가정함. 
 * 우선 local-repository를 사전 준비하기 위해서는 createrepo, yum-utils package를 설치함. 
 * Repository로 사용할 디렉토리(아래에서는 /data/localrepo)로 생성한 후 필요한 package를 yumdownloader 명령을 사용하여 저장한 후 "createrepo ."으로 yum db를 만들어 주면 됨.
 * yum --downloadonly 옵션으로도 rpm package를 다운로드 할 수는 있으나, **이미 설치된 package일 경우 다운로드 하지 않는 문제가 있음**.
   이를 해결하기 위해 yumdownloader 사용하고, `--arch x86_64` 로 지정함으로써 x86_64 아키텍처를 위한 package만 다운로드 하도록 한다. 단, package가 noarch로만 되어 있는 경우에는 `--arch x86_64`는 지정하지 않는다.
 * 설치 순서는 아래와 같이 진행한다.
    1. 필요한 rpm 파일 다운로드
    2. createrepo 로 rpm 파일을 스캔하여 repomd.xml 파일 생성
    3. nginx로 rmp파일을 다른 node에서 access 할 수 있도록 설정
 * yum 주요 사용볍은 [yum cheat sheet](yum cheat sheet.md) 을 참고한다.

## 2.2 rpm package download
 * docker, kubernetes repository 설정
```bash

$ cat > /etc/yum.repos.d/docker.repo <<EOF
[Docker-CE-Stable]
baseurl = https://download.docker.com/linux/centos/\$releasever/\$basearch/stable
enabled = 1
gpgcheck = 1
gpgkey = https://download.docker.com/linux/centos/gpg
name = Docker-ce repo
repo_gpgcheck = 0
EOF

$ cat > /etc/yum.repos.d/kubernetes.repo <<EOF
[Kubernetes]
baseurl = http://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled = 1
exclude = kube*
gpgcheck = 1
gpgkey = http://packages.cloud.google.com/yum/doc/yum-key.gpg
         http://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
name = Kubernetes repo
repo_gpgcheck = 0
EOF
```

 * rpm package download
```bash
$ mkdir -p /data/localrepo
$ cd /data/localrepo

$ yum repolist
$ yum install -y createrepo
$ yum install -y yum-utils

$ yumdownloader --arch x86_64 --resolve  --downloaddir=. createrepo
$ yumdownloader --resolve --downloaddir=. yum-utils

$ yumdownloader --arch x86_64 --resolve --downloaddir=. jq
$ yumdownloader --resolve --downloaddir=. nginx
$ yumdownloader --arch x86_64 --resolve --downloaddir=. telnet
$ yumdownloader --arch x86_64 --resolve --downloaddir=. net-tools
$ yumdownloader --arch x86_64 --resolve --downloaddir=. bind-utils

$ yumdownloader --arch x86_64 --resolve --downloaddir=. nfs-utils
$ yumdownloader --arch x86_64 --resolve --downloaddir=. ipvsadm
$ yumdownloader --arch x86_64 --resolve --downloaddir=. ipset
$ yumdownloader --arch x86_64 --resolve --downloaddir=. lksctp-tools
$ yumdownloader --arch x86_64 --resolve --downloaddir=. libselinux-python   // centos 8 이하
$ yumdownloader --arch x86_64 --resolve --downloaddir=. python3-libselinux  // centos 8
$ yumdownloader --arch x86_64 --resolve --downloaddir=. socat
$ yumdownloader --arch x86_64 --resolve --downloaddir=. conntrack-tools

$ yumdownloader --arch x86_64 --resolve --downloaddir=. containerd.io-1.4.6
$ yumdownloader --arch x86_64 --resolve --downloaddir=. containerd.io-1.4.4
$ yumdownloader --arch x86_64 --resolve --downloaddir=. containerd.io-1.4.3

$ yumdownloader --arch x86_64 --resolve --downloaddir=. docker-ce-20.10.7 docker-ce-cli-20.10.7
$ yumdownloader --arch x86_64 --resolve --downloaddir=. docker-ce-20.10.6 docker-ce-cli-20.10.6
$ yumdownloader --arch x86_64 --resolve --downloaddir=. docker-ce-19.03.15 docker-ce-cli-19.03.15

$ yumdownloader --arch x86_64 --resolve --downloaddir=. --disableexcludes=Kubernetes kubectl-1.19.11 kubelet-1.19.11 kubeadm-1.19.11
$ yumdownloader --arch x86_64 --resolve --downloaddir=. --disableexcludes=Kubernetes kubectl-1.19.10 kubelet-1.19.10 kubeadm-1.19.10
$ yumdownloader --arch x86_64 --resolve --downloaddir=. --disableexcludes=Kubernetes kubectl-1.19.9 kubelet-1.19.9 kubeadm-1.19.9

$ yumdownloader --arch x86_64 --resolve --downloaddir=. --disableexcludes=Kubernetes kubectl-1.20.7 kubelet-1.20.7 kubeadm-1.20.7
$ yumdownloader --arch x86_64 --resolve --downloaddir=. --disableexcludes=Kubernetes kubectl-1.20.6 kubelet-1.20.6 kubeadm-1.20.6
$ yumdownloader --arch x86_64 --resolve --downloaddir=. --disableexcludes=Kubernetes kubectl-1.20.5 kubelet-1.20.5 kubeadm-1.20.5

$ yumdownloader --arch x86_64 --resolve --downloaddir=. --disableexcludes=Kubernetes kubectl-1.21.1 kubelet-1.21.1 kubeadm-1.21.1
$ yumdownloader --arch x86_64 --resolve --downloaddir=. --disableexcludes=Kubernetes kubectl-1.21.0 kubelet-1.21.0 kubeadm-1.21.0

# 주의) container-selinux를 폐쇄망에서 설치하려고 하면 "~사용 가능한 메타 데이터가 없으며 시스템에 설치할 수 없습니다" 오류가 발생함.
# 따라서 yum install -y http://ip:8080/container-selinux-2.158.0-1.el8.4.0.noarch.rpm 방식으로 설치해야 함.
# 파일명이 혼잡하여 단순화 함.
$ mv container-selinux-2.158.0-1.module_el8.4.0+781+acf4c33b.noarch.rpm container-selinux-2.158.0-1.el8.4.0.noarch.rpm

$ createrepo .
```

# 3. 검증

 * Repository 설정을 변경하여 local 파일에서 nginx를 설치한다.
 * Nginx port 및 root directory를 변경한다.
 * Local 파일 부분을 삭제하고 nginx가 서비스 되도록 repository 설정을 변경한 후 테스트로 jq 패키지가 정상적으로 설치되는지 확인힌다.

```bash
$ mv /etc/yum.repos.d /etc/yum.repos.d.bak

# 우선 로컬 파일로 repository를 설정한 후 nginx를 설치 & 기동 한 후 다시 URL로 변경하여 jq 패키지가 설치되는지 확인한다.
$ cat > /etc/yum.repos.d/local.repo <<EOF
[LocalRepo_BaseOS]
name=Local Repository
baseurl=file:///data/localrepo
enabled=1
gpgcheck=0

[LocalRepo_AppStream]
name=LocalRepo_AppStream
baseurl=file:///data/localrepo
enabled=1
gpgcheck=0
EOF

$ setenforce 0

$ yum clean all
$ yum repolist
$ yum install -y nginx

// nginx port 변경
$ vi /etc/nginx/default.conf
  server {
        listen 8080 default_server;
        listen [::]:8080 default_server;
        ...
        
        root /data/localrepo;
  }

$ systemctl enable nginx
$ systemctl start nginx
$ systemctl status nginx
$ curl http://localhost:8080

$ cat > /etc/apt/sources.list.d/localrepo.list <<EOF
[LocalRepo_BaseOS]
name=LocalRepo_BaseOS
enabled=1
gpgcheck=0
baseurl=http://192.168.77.128:8080

[LocalRepo_AppStream]
name=LocalRepo_AppStream
enabled=1
gpgcheck=0
baseurl=http://192.168.77.128:8080
EOF

$ yum clean all
$ yum repolist
$ yum install jq
```

# 4. 압축파일로 저장
 * 이제 local repository 준비 및 테스트가 완료되었으므로 usb등에 해당 파일을 압축하여 저장한다.
```bash
$ tar -cvf localrepo_20210607.tar /data/localrepo
```

# 참고
 * https://www.tecmint.com/create-local-http-yum-dnf-repository-on-rhel-8/
 * https://vmware.github.io/vsphere-storage-for-kubernetes/documentation/storageclass.html
 * https://access.redhat.com/solutions/253273
 * https://www.lesstif.com/lpt/rhel-centos-8-network-82215015.html
 * https://access.redhat.com/articles/3078
 * https://www.tecmint.com/install-a-kubernetes-cluster-on-centos-8/
 * https://arisu1000.tistory.com/27829
 * https://github.com/kubernetes/kubernetes/tree/master/build/pause
 * https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html
 * https://docs.projectcalico.org/getting-started/kubernetes/requirements#kernel-dependencies
 * https://github.com/jmutai/k8s-pre-bootstrap/blob/master/roles/kubernetes-bootstrap/tasks/configure_firewalld.yml
 * https://github.com/kubernetes-sigs/kubespray/blob/master/docs/centos8.md
 * https://docs.projectcalico.org/reference/felix/configuration#iptables-dataplane-configuration
 * https://www.redhat.com/en/blog/using-nftables-red-hat-enterprise-linux-8