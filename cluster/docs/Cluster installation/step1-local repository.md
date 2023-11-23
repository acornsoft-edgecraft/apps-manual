[TOC]

> 폐쇄망(air-gapped)에서 시스템 package를 설치하기 위해서는 local repository를 설치하고 각 장비에서는 local repository로 연결하도록 해야 한다.
> Ubuntu와 RHEL 계열의 repository 설정은 차이가 있으며, 특히 RHEL8/Centos8은 이전버전과 repository 설정 형식이 변경되었다.

# Ubuntu apt repository 설정
```bash
$ mv /etc/apt/sources.list /etc/apt/sources.list.bak
$ cat > /etc/apt/sources.list.d/localrepo.list <<EOF
deb [trusted=yes] http://172.16.0.134:8080/ ./
EOF
```

# RHEL/Centos yum repository 설정
## RHEL/Centos 7
```bash
$ mv /etc/yum.repos.d /etc/yum.repos.d.bak

$ cat > /etc/yum.repos.d/local.repo <<EOF
[base]
name=CentOS-\$releasever - Base
baseurl=http://192.168.77.128:8080/centos/7/os/\$basearch/
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#released updates 
[updates]
name=CentOS-\$releasever - Updates
baseurl=http://192.168.77.128:8080/centos/7/os/\$basearch/
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that may be useful
[extras]
name=CentOS-\$releasever - Extras
baseurl=http://192.168.77.128:8080/centos/7/os/\$basearch/
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-\$releasever - Plus
baseurl=http://192.168.77.128:8080/centos/7/os/\$basearch/
gpgcheck=0
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF
```

## RHEL/Centos 8
```bash
$ sudo -i
$ mv /etc/yum.repos.d /etc/yum.repos.d.bak
$ mkdir /etc/yum.repos.d

$ cat > /etc/yum.repos.d/local.repo <<EOF
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

$ yum repolist
$ yum update
```