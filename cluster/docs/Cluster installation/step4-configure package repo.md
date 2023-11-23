[TOC]

# 1. Repository 설정
 * Internet이 가능한 상황에서 일반적인 docker, kubernetes repository 설정 방법임.

## 1.1 Centos, RHEL

```bash
$ cat > /etc/yum.repos.d/kubernetes.repo <<EOF
[Kubernetes]
baseurl = http://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled = 1
exclude = kube*
gpgcheck = 1
gpgkey = http://packages.cloud.google.com/yum/doc/yum-key.gpg
	     http://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
name = Kubernetes repo
repo_gpgcheck = 1
EOF

$ cat > /etc/yum.repos.d/docker.repo <<EOF
[Docker-CE-Stable]
baseurl = https://download.docker.com/linux/centos/\$releasever/\$basearch/stable
enabled = 0
gpgcheck = 1
gpgkey = https://download.docker.com/linux/centos/gpg
name = Docker-ce repo
repo_gpgcheck = 0
EOF
```

## 1.2 Ubuntu

```bash
$ sudo apt-get update
$ sudo apt-get install -y apt-transport-https ca-certificates curl
$ sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
$ echo "deb [arch=amd64 signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list


$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
$ echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

$ sudo apt-get update
```

 * 참고1 - Centos yum 변수 확인 방법
```bash
$ yum install yum-utils
$ yum-debug-dump   // 이 명령을 실행하면 /tmp/ 폴더에 dnf_debug_dump로 시작되는 gz파일이 생성됨
$ zcat /tmp/dnf_debug_dump-node1-2021-06-02_01:11:19.txt.gz   // 첫 부분에서 yum 변수값을 확인할 수 있음.
```