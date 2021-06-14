[TOC]

# apt-get cheat sheet

```bash
$ yum check-update
$ yum update
$ yum repolist
$ yum upgrade : yum update -obsoletes 와 동일. yum upgrade 명령 사용이 권장됨. 
$ yum install -y [패키지명]
$ yum remove -y [패키지명]
$ yum autoremove -y [패키지명] : 종속성 자동 제거
$ yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

// 설치 버전 확인 
$ yum provides [패키지명]
$ yum list [패키지명] --showduplicates | sort -r : 권고함.
  $ yum list docker-ce --showduplicates | sort -r
  docker-ce.x86_64                3:20.10.7-3.el8                 Docker-CE-Stable
  docker-ce.x86_64                3:20.10.6-3.el8                 Docker-CE-Stable
  docker-ce.x86_64                3:20.10.5-3.el8                 Docker-CE-Stable
  docker-ce.x86_64                3:20.10.4-3.el8                 Docker-CE-Stable
  docker-ce.x86_64                3:20.10.3-3.el8                 Docker-CE-Stable
  docker-ce.x86_64                3:20.10.2-3.el8                 Docker-CE-Stable
  docker-ce.x86_64                3:20.10.1-3.el8                 Docker-CE-Stable
  docker-ce.x86_64                3:20.10.0-3.el8                 Docker-CE-Stable
  docker-ce.x86_64                3:19.03.15-3.el8                Docker-CE-Stable
  docker-ce.x86_64                3:19.03.14-3.el8                Docker-CE-Stable
  docker-ce.x86_64                3:19.03.13-3.el8                Docker-CE-Stable
  $ yum list containerd.io --showduplicates | sort -r
  containerd.io.x86_64               1.4.6-3.1.el8                Docker-CE-Stable
  containerd.io.x86_64               1.4.4-3.1.el8                Docker-CE-Stable
  containerd.io.x86_64               1.4.3-3.2.el8                Docker-CE-Stable
  containerd.io.x86_64               1.4.3-3.1.el8                Docker-CE-Stable
  containerd.io.x86_64               1.3.9-3.1.el8                Docker-CE-Stable
  containerd.io.x86_64               1.3.7-3.1.el8                Docker-CE-Stable

// 설치 여부 확인 
$ yum list --installed | grep [패키지명]

// yum cache로 인해 잘못된 동작이 일어날 경우 cache 삭제
$ yum clean {metadata,packages,dbcache,expire-cache,all}
$ rm -rf /var/cache/yum
```

 * 참고1 - yum update vs upgrade
   - yum update: 패키지 업데이트함.
   - yum upgrade: 패키지 업그레이드 하면서 **더 이상 사용되지 않는 관련된 파일이나 패키지를 삭제함**. 이는 `yum update --obsoletes`와 동일. 이 방식이 권고됨.
      
 * 참고2 - apt update vs upgrade
   - apt update: 단순히 패키지 업데이트가 존재하는지 저장소 경로를 통해 확인하는 작업만 수행함.
   - apt upgrade: 실제로 패키지 업그레이드 작업을 수행함.
   
 * 참고3 - Centos yum 변수 확인 방법
```bash
$ yum install yum-utils
$ yum-debug-dump   // 이 명령을 실행하면 /tmp/ 폴더에 dnf_debug_dump로 시작되는 gz파일이 생성됨
$ zcat /tmp/dnf_debug_dump-node1-2021-06-02_01:11:19.txt.gz   // 첫 부분에서 yum 변수값을 확인할 수 있음.
```   