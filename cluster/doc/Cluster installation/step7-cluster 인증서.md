[TOC]

### K8S cluster 인증서 생성
 * K8s cluster의 공통적으로 사용되는 인증서와 ETCD cluster에서 공통적으로 사용되는 인증서를 생성한다.
 * /opt/kubernetes/pki/ca.key, /opt/kubernetes/pki/etcd/ca.key 파일의 존재여부를 체크하여 없을 경우에만 인증서를 생성함.
 
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

[ v3_req_etcd ]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names_etcd

[ v3_req_istio_ingress ]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names_istio_ingress

[ v3_req_metricsserver ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names_metricsserver

[ alt_names_cluster ]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
DNS.5 = localhost
IP.1 = 127.0.0.1
IP.2 = 192.168.77.223
IP.3 = 172.16.0.1
IP.4 = 192.168.77.223

[ alt_names_etcd ]
DNS.1 = 192.168.77.223
IP.1 = 192.168.77.223
IP.2 = 127.0.0.1

[ alt_names_istio_ingress ]
IP.1 = 127.0.0.1
IP.2 = 192.168.77.223
IP.3 = 192.168.77.223

[ alt_names_metricsserver ]
DNS.1 = metrics-server
DNS.2 = metrics-server.kube-system
DNS.3 = metrics-server.kube-system.svc
DNS.4 = metrics-server.kube-system.svc.cluster
DNS.5 = metrics-server.kube-system.svc.cluster.local
DNS.6 = localhost
IP.1 = 127.0.0.1
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

### ETCD cluster 인증서 생성
```bash
$ openssl genrsa -out /opt/kubernetes/pki/etcd/ca.key 2048
$ openssl req -x509 -new -nodes -key /opt/kubernetes/pki/etcd/ca.key -days 36500 -out /opt/kubernetes/pki/etcd/ca.crt -subj '/CN=etcd-ca' -extensions v3_ca -config /opt/kubernetes/pki/common-openssl.conf

$ openssl genrsa -out /opt/kubernetes/pki/apiserver-etcd-client.key 2048
$ openssl req -new -key /opt/kubernetes/pki/apiserver-etcd-client.key -subj '/O=system:masters/CN=kube-apiserver-etcd-client' |
  openssl x509 -req -CA /opt/kubernetes/pki/etcd/ca.crt -CAkey /opt/kubernetes/pki/etcd/ca.key -CAcreateserial -out /opt/kubernetes/pki/apiserver-etcd-client.crt -days 36500 -extensions v3_req_client -extfile /opt/kubernetes/pki/common-openssl.conf

$ openssl genrsa -out /opt/kubernetes/pki/etcd/healthcheck-client.key 2048
$ openssl req -new -key /opt/kubernetes/pki/etcd/healthcheck-client.key -subj '/O=system:masters/CN=kube-etcd-healthcheck-client' |
  openssl x509 -req -CA /opt/kubernetes/pki/etcd/ca.crt -CAkey /opt/kubernetes/pki/etcd/ca.key -CAcreateserial -out /opt/kubernetes/pki/etcd/healthcheck-client.crt -days 36500 -extensions v3_req_client -extfile /opt/kubernetes/pki/common-openssl.conf
```