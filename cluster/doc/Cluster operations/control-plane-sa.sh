#!/bin/sh

hostname=$(hostname)
api_url=$(cat /etc/kubernetes/admin.conf  | grep server | awk -F 'server:' '{ print $2 }' | tr -d ' ')

openssl genrsa -out ./admin.key 2048
openssl req -new -key ./admin.key -subj '/O=system:masters/CN=kubernetes-admin' |
openssl x509 -req -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out ./admin.crt -days 3650 -extensions v3_req_client -extfile ./common-openssl.conf

openssl genrsa -out ./apiserver.key 2048
openssl req -new -key ./apiserver.key -subj '/CN=kube-apiserver' |
openssl x509 -req -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out ./apiserver.crt -days 3650 -extensions v3_req_apiserver -extfile ./common-openssl.conf


openssl genrsa -out ./controller-manager.key 2048
openssl req -new -key ./controller-manager.key -subj '/CN=system:kube-controller-manager' |
openssl x509 -req -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out ./controller-manager.crt -days 3650 -extensions v3_req_client -extfile ./common-openssl.conf

openssl genrsa -out ./controller-manager.key 2048
openssl req -new -key ./controller-manager.key -subj '/CN=system:kube-controller-manager' |
openssl x509 -req -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out ./controller-manager.crt -days 3650 -extensions v3_req_client -extfile ./common-openssl.conf

openssl genrsa -out ./scheduler.key 2048
openssl req -new -key ./scheduler.key -subj '/CN=system:kube-scheduler' |
openssl x509 -req -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out ./scheduler.crt -days 3650 -extensions v3_req_client -extfile ./common-openssl.conf


openssl genrsa -out ./etcd/server.key 2048; chmod 644 ./etcd/server.key
openssl req -new -key ./etcd/server.key -subj '/CN=$hostname' |
openssl x509 -req -CA ./etcd/ca.crt -CAkey ./etcd/ca.key -CAcreateserial -out ./etcd/server.crt -days 3650 -extensions v3_req_etcd -extfile ./openssl-etcd.conf

openssl genrsa -out ./etcd/peer.key; chmod 644 ./etcd/peer.key
openssl req -new -key ./etcd/peer.key -subj '/CN=$hostname' |
openssl x509 -req -CA ./etcd/ca.crt -CAkey ./etcd/ca.key -CAcreateserial -out ./etcd/peer.crt -days 3650 -extensions v3_req_etcd -extfile ./openssl-etcd.conf


cat > admin.conf << EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $(cat /etc/kubernetes/pki/ca.crt | base64 -w0)
    server: ${api_url}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: $(cat ./admin.crt | base64 -w0)
    client-key-data: $(cat ./admin.key | base64 -w0)
EOF

cat > controller-manager.conf << EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $(cat /etc/kubernetes/pki/ca.crt | base64 -w0)
    server: ${api_url}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: system:kube-controller-manager
  name: system:kube-controller-manager@kubernetes
current-context: system:kube-controller-manager@kubernetes
kind: Config
preferences: {}
users:
- name: system:kube-controller-manager
  user:
    client-certificate-data: $(cat ./controller-manager.crt | base64 -w0)
    client-key-data: $(cat ./controller-manager.key | base64 -w0)
EOF

cat > scheduler.conf << EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $(cat /etc/kubernetes/pki/ca.crt | base64 -w0)
    server: ${api_url}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: system:kube-scheduler
  name: system:kube-scheduler@kubernetes
current-context: system:kube-scheduler@kubernetes
kind: Config
preferences: {}
users:
- name: system:kube-scheduler
  user:
    client-certificate-data: $(cat ./scheduler.crt | base64 -w0)
    client-key-data: $(cat ./scheduler.key | base64 -w0)
EOF

cp ./admin.crt /etc/kubernetes/pki
cp ./admin.key /etc/kubernetes/pki
yes |cp -f ./admin.conf /etc/kubernetes

cp ./apiserver.crt /etc/kubernetes/pki
cp ./apiserver.key /etc/kubernetes/pki

cp ./controller-manager.crt /etc/kubernetes/pki
cp ./controller-manager.key /etc/kubernetes/pki
yes |cp -f ./controller-manager.conf /etc/kubernetes

cp ./scheduler.crt /etc/kubernetes/pki
cp ./scheduler.key /etc/kubernetes/pki
yes |cp -f ./scheduler.conf /etc/kubernetes

cp ./etcd/server.crt /etc/kubernetes/pki/etcd/
cp ./etcd/peer.crt /etc/kubernetes/pki/etcd/