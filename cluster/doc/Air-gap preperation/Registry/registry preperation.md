[TOC]

# 1. Get harbor offline-installer
```bash
$ curl -L -O https://github.com/goharbor/harbor/releases/download/v1.10.3/harbor-offline-installer-v1.10.3.tgz
```
# 2. Harbor backup
 * harbor를 online상에서 설치하고 필요한 docker image와 chart를 harbor상에 upload한다.
 * harbor backup script를 실행하여 harbor db와 docker image 등을 모두 압축하여 저장한다.
 * 저장한 harbor 압축파일을 usb등에 저장하여 사용한다.
 
## 2.1 harbor 설치
 [harbor 설치](../../Cluster%20installation/step6-registry.md)
 
## 2.2 k8s 설치 관련 image upload
```bash
 * upload_image.sh을 이용한다. k8s버전 및 harbor-ip를 지정하면 docker pull & push 를 수행한다.
$ upload_image.sh 1.20.8 192.168.77.128
```

## 2.3 harbor 백업파일 저장
```bash
$ scp registry-backup.sh centos@192.168.77.128:/tmp
$ chmod +x /tmp/registry-backup.sh

$ /tmp/registry-backup.sh /tmp 1
```
