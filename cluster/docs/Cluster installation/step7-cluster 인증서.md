[TOC]

# 1. K8S cluster 인증서 생성 (master 1번 장비에서만 실행)
 * K8s cluster의 공통적으로 사용되는 인증서와 ETCD cluster에서 공통적으로 사용되는 인증서를 생성한다.
 * /opt/kubernetes/pki/ca.key, /opt/kubernetes/pki/etcd/ca.key 파일의 존재여부를 체크하여 없을 경우에만 인증서를 생성함.
 * **K8S 인증서 관련 파일은 master1번에서 작성하여 master2, 3번에 복사해야 한다.**
   - apiserver-etcd-client.crt
   - apiserver-etcd-client.key
   - ca.crt
   - ca.key
   - front-proxy-ca.crt
   - front-proxy-ca.key
   - sa.crt
   - sa.key

 * ** ETCD 인증서는 ca.crt, ca.key를 master1번에서 작성하여 master2, 3번에 복사해야 한다.**

```bash
$ mkdir -p /opt/kubernetes/pki/etcd


$ vi /opt/kubernetes/pki/common-openssl.conf
[ req ]
distinguished_name = req_distinguished_name
[req_distinguished_name]

[ v3_ca ]
basicConstraints = critical, CA:TRUE
keyUsage = critical, digitalSignature, keyEncipherment, keyCertSign

[ v3_req_server ]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[ v3_req_client ]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth

[ v3_req_apiserver ]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names_cluster

[ alt_names_cluster ]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
DNS.5 = localhost
IP.1 = 127.0.0.1
IP.2 = 192.168.77.121                   // master node 별 IP
IP.3 = 172.20.0.1                       // kubernetes service ip
```

```bash
$ openssl genrsa -out /opt/kubernetes/pki/ca.key 2048
$ openssl req -x509 -new -nodes -key /opt/kubernetes/pki/ca.key -days 36500 -out /opt/kubernetes/pki/ca.crt -subj '/CN=kubernetes-ca' -extensions v3_ca -config /opt/kubernetes/pki/common-openssl.conf

$ openssl genrsa -out /opt/kubernetes/pki/sa.key 2048
$ openssl rsa -in /opt/kubernetes/pki/sa.key -outform PEM -pubout -out /opt/kubernetes/pki/sa.pub

$ openssl req -new -key /opt/kubernetes/pki/sa.key -subj '/CN=system:kube-controller-manager' |
  openssl x509 -req -CA /opt/kubernetes/pki/ca.crt -CAkey /opt/kubernetes/pki/ca.key -CAcreateserial -out /opt/kubernetes/pki/sa.crt -days 36500 -extensions v3_req_client -extfile /opt/kubernetes/pki/common-openssl.conf

$ openssl genrsa -out /opt/kubernetes/pki/front-proxy-ca.key 2048
$ openssl req -x509 -new -nodes -key /opt/kubernetes/pki/front-proxy-ca.key -days 36500 -out /opt/kubernetes/pki/front-proxy-ca.crt -subj '/CN=front-proxy-ca' -extensions v3_ca -config /opt/kubernetes/pki/common-openssl.conf

```

# 2. ETCD cluster 인증서 생성
```bash
$ openssl genrsa -out /opt/kubernetes/pki/etcd/ca.key 2048
$ openssl req -x509 -new -nodes -key /opt/kubernetes/pki/etcd/ca.key -days 36500 -out /opt/kubernetes/pki/etcd/ca.crt -subj '/CN=etcd-ca' -extensions v3_ca -config /opt/kubernetes/pki/common-openssl.conf
$ openssl genrsa -out /opt/kubernetes/pki/apiserver-etcd-client.key 2048
$ openssl req -new -key /opt/kubernetes/pki/apiserver-etcd-client.key -subj '/O=system:masters/CN=kube-apiserver-etcd-client' |
  openssl x509 -req -CA /opt/kubernetes/pki/etcd/ca.crt -CAkey /opt/kubernetes/pki/etcd/ca.key -CAcreateserial -out /opt/kubernetes/pki/apiserver-etcd-client.crt -days 36500 -extensions v3_req_client -extfile /opt/kubernetes/pki/common-openssl.conf
```

# 3. 인증서 복사
# 3.1 master 1번 node
```bash
$ mkdir -p /etc/kubernetes/pki/etcd
$ cp /opt/kubernetes/pki/ca.key /etc/kubernetes/pki/ca.key
$ cp /opt/kubernetes/pki/ca.crt /etc/kubernetes/pki/ca.crt
$ cp /opt/kubernetes/pki/apiserver-etcd-client.key /etc/kubernetes/pki/apiserver-etcd-client.key
$ cp /opt/kubernetes/pki/apiserver-etcd-client.crt /etc/kubernetes/pki/apiserver-etcd-client.crt
$ cp /opt/kubernetes/pki/front-proxy-ca.key /etc/kubernetes/pki/front-proxy-ca.key
$ cp /opt/kubernetes/pki/front-proxy-ca.crt /etc/kubernetes/pki/front-proxy-ca.crt
$ cp /opt/kubernetes/pki/sa.key /etc/kubernetes/pki/sa.key
$ cp /opt/kubernetes/pki/sa.crt /etc/kubernetes/pki/sa.crt

$ cp /opt/kubernetes/pki/etcd/ca.key /etc/kubernetes/pki/etcd/ca.key
$ cp /opt/kubernetes/pki/etcd/ca.crt /etc/kubernetes/pki/etcd/ca.crt

$ ls -al /etc/kubernetes/pki
-rw-r--r--. 1 root root 1127  6월 29 17:18 apiserver-etcd-client.crt
-rw-------. 1 root root 1679  6월 29 17:18 apiserver-etcd-client.key
-rw-r--r--. 1 root root 1062  6월 29 17:18 ca.crt
-rw-------. 1 root root 1679  6월 29 17:18 ca.key
drwxr-xr-x. 2 root root  176  6월 29 17:20 etcd
-rw-r--r--. 1 root root 1066  6월 29 17:18 front-proxy-ca.crt
-rw-------. 1 root root 1679  6월 29 17:18 front-proxy-ca.key
-rw-r--r--. 1 root root 1107  6월 29 17:18 sa.crt
-rw-------. 1 root root 1675  6월 29 17:18 sa.key

$ ls -al /etc/kubernetes/pki/etcd

-rw-r--r--. 1 root root 1046  6월 29 17:18 ca.crt
-rw-------. 1 root root 1675  6월 29 17:18 ca.key
```

# 3.2 master 2, 3번 노드
 * 인증서 저장 디렉토리 생성
```bash
$ mkdir -p /etc/kubernetes/pki/etcd
```

 * master 1번 장비에서 관련파일을 복사함.
 * scp가 접속되도록 환경 설정해야 함.
```bash
$ mkdir -p /etc/kubernetes/pki/etcd
$ scp /etc/kubernetes/pki/ca.key root@192.168.77.122:/etc/kubernetes/pki/ca.key
$ scp /etc/kubernetes/pki/ca.crt root@192.168.77.122:/etc/kubernetes/pki/ca.crt
$ scp /etc/kubernetes/pki/apiserver-etcd-client.key root@192.168.77.122:/etc/kubernetes/pki/apiserver-etcd-client.key
$ scp /etc/kubernetes/pki/apiserver-etcd-client.crt root@192.168.77.122:/etc/kubernetes/pki/apiserver-etcd-client.crt
$ scp /etc/kubernetes/pki/front-proxy-ca.key root@192.168.77.122:/etc/kubernetes/pki/front-proxy-ca.key
$ scp /etc/kubernetes/pki/front-proxy-ca.crt root@192.168.77.122:/etc/kubernetes/pki/front-proxy-ca.crt
$ scp /etc/kubernetes/pki/sa.key root@192.168.77.122:/etc/kubernetes/pki/sa.key
$ scp /etc/kubernetes/pki/sa.crt root@192.168.77.122:/etc/kubernetes/pki/sa.crt

$ scp /etc/kubernetes/pki/etcd/ca.key root@192.168.77.122:/etc/kubernetes/pki/etcd/ca.key
$ scp /etc/kubernetes/pki/etcd/ca.crt root@192.168.77.122:/etc/kubernetes/pki/etcd/ca.crt


$ mkdir -p /etc/kubernetes/pki/etcd
$ scp /etc/kubernetes/pki/ca.key root@192.168.77.123:/etc/kubernetes/pki/ca.key
$ scp /etc/kubernetes/pki/ca.crt root@192.168.77.123:/etc/kubernetes/pki/ca.crt
$ scp /etc/kubernetes/pki/apiserver-etcd-client.key root@192.168.77.123:/etc/kubernetes/pki/apiserver-etcd-client.key
$ scp /etc/kubernetes/pki/apiserver-etcd-client.crt root@192.168.77.123:/etc/kubernetes/pki/apiserver-etcd-client.crt
$ scp /etc/kubernetes/pki/front-proxy-ca.key root@192.168.77.123:/etc/kubernetes/pki/front-proxy-ca.key
$ scp /etc/kubernetes/pki/front-proxy-ca.crt root@192.168.77.123:/etc/kubernetes/pki/front-proxy-ca.crt
$ scp /etc/kubernetes/pki/sa.key root@192.168.77.123:/etc/kubernetes/pki/sa.key
$ scp /etc/kubernetes/pki/sa.crt root@192.168.77.123:/etc/kubernetes/pki/sa.crt
$ scp /etc/kubernetes/pki/sa.pub root@192.168.77.123:/etc/kubernetes/pki/sa.pub

$ scp /etc/kubernetes/pki/etcd/ca.key root@192.168.77.123:/etc/kubernetes/pki/etcd/ca.key
$ scp /etc/kubernetes/pki/etcd/ca.crt root@192.168.77.123:/etc/kubernetes/pki/etcd/ca.crt
```

 * PC에서 SSH 인증키를 가지고 있으면 master1에서 download 후 master 2,3으로 upload
```bash
// master1번에서 pki tar 파일 생성
$ tar -cvf pki.tar pki
$ mv pki.tar /tmp

// download 후 master 2,3으로 upload
$ scp centos@192.168.77.121:/tmp/pki.tar .
$ scp pki.tar centos@192.168.77.122:/tmp/pki.tar
$ scp pki.tar centos@192.168.77.123:/tmp/pki.tar
```

