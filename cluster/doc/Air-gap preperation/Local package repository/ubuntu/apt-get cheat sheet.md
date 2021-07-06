[TOC]

# apt-get cheat sheet

```bash
$ apt-get update : /etc/apt/source.list에 인덱스를 update함.
$ apt-get upgrade : 설치된 패키지 upgrade
$ apt-get dist-upgrade : 의존성 검사하며 설치함.
$ apt-get -y install [패키지명]
$ apt-get -y --reinstall install [패키지명]
$ apt-get -y remove [패키지명]
$ apt-get -y --purge remove [패키지명] : 설정파일까지 삭제함.
$ apt-get source [패키지명]
$ apt-get build-dep [패키지명] : 받은 소스코드를 의존성있게 빌드함.
$ apt-cache search [패키지명] : 패키지 검색
$ apt-cache show [패키지명] : 패키지 정보 보기.
$ apt-cache madison [패키지명] : 사용 가능한 패키지 버전을 표 형식으로 표시함.
$ apt-cache madison containerd.io
  containerd.io |    1.4.6-1 | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
  containerd.io |    1.4.4-1 | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
  containerd.io |    1.4.3-2 | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
  containerd.io |    1.4.3-1 | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
  ...
$ apt-cache madison docker-ce
   docker-ce | 5:20.10.7~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
   docker-ce | 5:20.10.6~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
   docker-ce | 5:20.10.5~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
   docker-ce | 5:20.10.4~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
   docker-ce | 5:20.10.3~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
   docker-ce | 5:20.10.2~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
   docker-ce | 5:20.10.1~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
   docker-ce | 5:20.10.0~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
   docker-ce | 5:19.03.15~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
   ...
$ apt-cache policy [패키지명] : 패키지의 우선 순위 선택에 대한 자세한 정보 출력함.
$ apt-cache policy docker-ce
  
$ dpkg --get-selections | grep [패키지명] : Get list of selections to stdout.
$ dpkg -l | grep [패키지명]
$ apt list --installed | grep [패키지명]

$ apt-mark hold [패키지명] : apt-get upgrade시 자동 upgrade를 방지
$ apt-mark unhold [패키지명]
```

 * 참고 - deb 파일을 기본 cache directory인 /var/cache/apt/archives 외 다른 디렉토리에 받기
```bash
$ apt-get install -y -d --reinstall -o=dir::cache=/data/localrepo docker-ce-cli=5:20.10.6~3-0~ubuntu-$(lsb_release -cs)
```

## 2.1-1 apt 명령어 설명
```sh
## 패키지 설치: apt-get install
apt install

## 	패키지 삭제: apt-get remove
apt remove

## 패키지와 관련 설정 제거: apt-get purge
apt purge

## 레파지토리 인덱스 갱신: apt-get update
apt update

## 업그레이드 가능한 모든 패키지 업그레이드: apt-get upgrade	
apt upgrade

## 불필요한 패키지 제거: apt-get autoremove
apt autoremove

## 의존성 고려한 패키지 업그레이드: apt-get dist-upgrade
apt full-upgrade

## 프로그램 검색: apt-cache search
apt search

## 패키지 상세 정보 출력: apt-cache show
apt show

## 패키지 리스트
apt list

## 소스 리스트 편집
apt edit-sources
```

## 2.1-1 dpkg 명령어 설명
```sh
## dpkg-scanpackages - create Packages index files
## Option -m , --multiversion : 발견 된 모든 패키지를 출력에 포함합니다.
dpkg-scanpackages -m .
```
