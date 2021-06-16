[TOC]

# 1. Test 장비 정보
 * vm-onassis-10	ubuntu18.04	172.16.0.130, 192.168.77.130 8Core.4G memory.40G disk
 * vm-onassis-11	ubuntu18.04	172.16.0.131, 192.168.77.131 8Core.4G memory.40G disk
 * vm-onassis-12	ubuntu18.04	172.16.0.132, 192.168.77.132 8Core.4G memory.40G disk
 * vm-onassis-13	ubuntu18.04	172.16.0.133, 192.168.77.133 8Core.4G memory.40G disk
 * vm-onassis-14	ubuntu18.04	172.16.0.134, 192.168.77.134 8Core.4G memory.40G disk

 * 장비 접속 예
```bash
$ ssh-add /Users/cloud/cert/onassis/id_rsa
$ ssh ubuntu@192.168.77.134
$ sudo -i
``` 

# 2. Local HTTP deb Repository 준비
## 2.1. 기본 사항
 * 우분투에서 deb package를 다운로드만 받으면 기본적으로 /var/cache/apt/archives 디렉토리에 저장된다.
   - /var/cache/apt/archives
 * 우분투는 repository 설정을 기본적으로 아래 파일 및 디렉토리에서 설정하면 된다.   
   - /etc/apt/sources.list
   - /etc/apt/sources.list.d/
 * dep package를 192.168.77.134 서버에서 작업한다고 가정함. 
 * apt-get로 dep파일을 다운로드할 경우 `-d` 옵션외에 `--reinstall` 옵션을 추가해야 deb파일이 해당 장비에 이미 설치되어 있다 하더라고 다운로드를 받는다.
 * 설치 순서는 아래와 같이 진행한다.
    1. 필요한 deb 파일 다운로드
    2. dpkg-scanpackages 로 deb 파일을 스캔하여 Packages.gz 파일 생성
    3. Nginx로 deb파일을 다른 node에서 access 할 수 있도록 설정
 * apt-get 주요 사용볍은 [apt-get cheat sheet](apt-get cheat sheet.md) 을 참고한다.

## 2.2 deb package download
 * docker, kubernetes repository 설정
```bash
$ mkdir -p /data/localrepo

$ apt-get update && apt-get install -y curl apt-transport-https ca-certificates software-properties-common gnupg2

# $ curl -fsSLo /usr/share/keyrings/docker-archive-keyring.gpg https://download.docker.com/linux/ubuntu/gpg
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
$ cat > /etc/apt/sources.list.d/docker.list <<EOF
deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable
EOF

# $ curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
$ cat > /etc/apt/sources.list.d/kubernetes.list <<EOF
deb [arch=amd64] https://apt.kubernetes.io/ kubernetes-xenial main
EOF
```

 * deb package download
```bash
$ apt-get update
## upgrade를 하면 /var/cache/apt/archives 디렉토리에 저장된다.
$ apt-get upgrade
$ apt-get install -y -d --reinstall nfs-common
$ apt-get install -y -d --reinstall nfs-kernel-server
$ apt-get install -y -d --reinstall nginx
$ apt-get install -y -d --reinstall python-minimal
$ apt-get install -y -d --reinstall python3-minimal

$ apt-get install -y -d --reinstall containerd.io=1.4.6-1
$ apt-get install -y -d --reinstall containerd.io=1.4.4-1
$ apt-get install -y -d --reinstall containerd.io=1.4.3-1

$ apt-get install -y -d --reinstall docker-ce=5:20.10.7~3-0~ubuntu-$(lsb_release -cs)
$ apt-get install -y -d --reinstall docker-ce=5:20.10.6~3-0~ubuntu-$(lsb_release -cs)
$ apt-get install -y -d --reinstall docker-ce=5:19.03.15~3-0~ubuntu-$(lsb_release -cs)

$ apt-get install -y -d --reinstall docker-ce-cli=5:20.10.7~3-0~ubuntu-$(lsb_release -cs)
$ apt-get install -y -d --reinstall docker-ce-cli=5:20.10.6~3-0~ubuntu-$(lsb_release -cs)
$ apt-get install -y -d --reinstall docker-ce-cli=5:19.03.15~3-0~ubuntu-$(lsb_release -cs)

$ apt-get install -y -d --reinstall kubelet=1.19.11-00 kubeadm=1.19.11-00 kubectl=1.19.11-00
$ apt-get install -y -d --reinstall kubelet=1.19.10-00 kubeadm=1.19.10-00 kubectl=1.19.10-00
$ apt-get install -y -d --reinstall kubelet=1.19.9-00 kubeadm=1.19.9-00 kubectl=1.19.9-00
$ apt-get install -y -d --reinstall kubelet=1.20.7-00 kubeadm=1.20.7-00 kubectl=1.20.7-00
$ apt-get install -y -d --reinstall kubelet=1.20.6-00 kubeadm=1.20.6-00 kubectl=1.20.6-00
$ apt-get install -y -d --reinstall kubelet=1.20.5-00 kubeadm=1.20.5-00 kubectl=1.20.5-00
$ apt-get install -y -d --reinstall kubelet=1.21.1-00 kubeadm=1.21.1-00 kubectl=1.21.1-00
$ apt-get install -y -d --reinstall kubelet=1.21.0-00 kubeadm=1.21.0-00 kubectl=1.21.0-00

$ apt-get install -y -d --reinstall jq
$ apt-get install -y -d --reinstall libonig2
$ apt-get install -y -d --reinstall telnet
$ apt-get install -y -d --reinstall vim
$ apt-get install -y -d --reinstall curl
$ apt-get install -y -d --reinstall net-tools
$ apt-get install -y -d --reinstall dnsutils

$ apt-get install -y -d --reinstall dpkg-dev
$ apt-get install -y dpkg-dev

$ cp /var/cache/apt/archives/*.deb /data/localrepo
$ cd /data/localrepo

## 패키지들의 인덱스를 생성 후 압축 한다.
$ dpkg-scanpackages -m . | gzip -c > Packages.gz

## 패키지 확인
$ zcat Packages.gz
```

# 3. 검증

 * Repository 설정을 변경하여 local 파일에서 nginx를 설치한다.
 * Nginx port 및 root directory를 변경한다.
 * Local 파일 부분을 삭제하고 nginx가 서비스 되도록 repository 설정을 변경한 후 테스트로 jq 패키지가 정상적으로 설치되는지 확인힌다.

```bash
$ mv /etc/apt/sources.list /etc/apt/sources.list.bak
$ mv /etc/apt/sources.list.d/docker.list /etc/apt/sources.list.d/docker.list.bak
$ mv /etc/apt/sources.list.d/kubernetes.list /etc/apt/sources.list.d/kubernetes.list.bak

## 로컬 레파지토리를 로컬 디렉토리로 지정한다. (nginx를 설치 하기 위해서)
$ cat > /etc/apt/sources.list.d/localrepo.list <<EOF
#deb [trusted=yes] http://172.16.0.134:8080/ ./
deb [trusted=yes] file:///data/localrepo/ ./
EOF

## 위에서 dpkg-scanpackages 명령어로 패키지 인덱스를 재구성 했기 때문에 패키지 인덱스를 업데이트 한다. 
$ apt-get update
$ apt-get install -y nginx

// nginx port 변경
$ vi /etc/nginx/sites-available/default
  server {
        listen 8080 default_server;
        listen [::]:8080 default_server;
        ...
        
        root /data/localrepo;
  }

$ systemctl restart nginx

## local repository 검증
$ cat > /etc/apt/sources.list.d/localrepo.list <<EOF
deb [trusted=yes] http://172.16.0.134:8080/ ./
EOF

$ apt-get update
$ apt-get install -y jq
```

# 4. 압축파일로 저장
 * 이제 local repository 준비 및 테스트가 완료되었으므로 usb등에 해당 파일을 압축하여 저장한다.
```bash
$ mv /etc/apt/sources.list /etc/apt/sources.list.bak
$ mv /etc/apt/sources.list.d/docker.list /etc/apt/sources.list.d/docker.list.bak
$ mv /etc/apt/sources.list.d/kubernetes.list /etc/apt/sources.list.d/kubernetes.list.bak
```

# 참고

* [Creating a personal apt repository using `dpkg-scanpackages`](https://www.guyrutenberg.com/2016/07/15/creating-a-personal-apt-repository-using-dpkg-scanpackages/)
* [Ubuntu 패키지 저장소 만들기](https://www.joinc.co.kr/w/man/12/deb)
* [Ubuntu 패키지 관리 툴: apt 사용법](http://taewan.kim/tip/apt-apt-get/)
* [Kubernetes 설치 및 환경 구성하기](https://medium.com/finda-tech/overview-8d169b2a54ff)


