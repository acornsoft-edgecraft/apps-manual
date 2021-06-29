[TOC]

### ETCD cluster 구성
 * ETCD cluster의 실행 user는 etcd:etcd 임.
 * etcd binary를 master node에 upload하고 service file을 만들어서 기동시킨다.
 
```bash
$ useradd etcd

$ mkdir /etc/etcd/
$ mkdir /var/lib/etcd
$ chown etcd /var/lib/etcd
$ chmod 755 /var/lib/etcd

$ mkdir /data/etcd
$ chown etcd:etcd /data/etcd

$ scp etcd-v3.4.14-linux-amd64.tar.gz root@{etcd-ips}:/etc/etcd/etcd-v3.4.14-linux-amd64.tar.gz
$ tar -zxvf /etc/etcd/etcd-v3.4.14-linux-amd64.tar.gz

$ cp /etc/etcd/etcd-v3.4.14-linux-amd64/etcd /usr/bin/etcd
$ cp /etc/etcd/etcd-v3.4.14-linux-amd64/etcdctl /usr/bin/etcdctl

$ cat > /etc/etcd/etcd.conf <<EOF 

#[member]
ETCD_NAME=vm-onassis-01                                         // 각 etcd node별로 hostname 변경

ETCD_DATA_DIR=/data/etcd
#ETCD_SNAPSHOT_COUNTER="10000"
#ETCD_HEARTBEAT_INTERVAL="100"
#ETCD_ELECTION_TIMEOUT="1000"
#ETCD_MAX_SNAPSHOTS="5"
#ETCD_MAX_WALS="5"
#ETCD_CORS=""

#[cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS=https://192.168.77.121:2380    // 각 etcd node별로 ip 변경
ETCD_INITIAL_CLUSTER=node1=https://192.168.77.121:2380          // 각 etcd node별로 ip 변경
ETCD_INITIAL_CLUSTER_STATE=new
ETCD_INITIAL_CLUSTER_TOKEN=etcd-k8-cluster
#ETCD_DISCOVERY=""
#ETCD_DISCOVERY_SRV=""
#ETCD_DISCOVERY_FALLBACK="proxy"
#ETCD_DISCOVERY_PROXY=""
ETCD_LISTEN_PEER_URLS=https://0.0.0.0:2380
ETCD_ADVERTISE_CLIENT_URLS=https://192.168.77.121:2379          // 각 etcd node별로 ip 변경
ETCD_LISTEN_CLIENT_URLS="https://0.0.0.0:2379"

#[proxy]
ETCD_PROXY="off"

#[security]
ETCD_CLIENT_CERT_AUTH="true"
ETCD_PEER_CLIENT_CERT_AUTH="true"
ETCD_TRUSTED_CA_FILE=/etc/kubernetes/pki/etcd/ca.crt
ETCD_CERT_FILE=/etc/kubernetes/pki/etcd/server.crt
ETCD_KEY_FILE=/etc/kubernetes/pki/etcd/server.key
ETCD_PEER_TRUSTED_CA_FILE=/etc/kubernetes/pki/etcd/ca.crt
ETCD_PEER_CERT_FILE=/etc/kubernetes/pki/etcd/peer.crt
ETCD_PEER_KEY_FILE=/etc/kubernetes/pki/etcd/peer.key
EOF

$ vi /opt/kubernetes/pki/openssl-etcd.conf 
[ req ]
distinguished_name = req_distinguished_name
[req_distinguished_name]

[ v3_ca ]
basicConstraints = critical, CA:TRUE
keyUsage = critical, digitalSignature, keyEncipherment, keyCertSign

[ v3_req_client ]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth

[ v3_req_etcd ]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names_etcd

[ alt_names_etcd ]
DNS.1 = vm-onassis-01                                       // 각 etcd node별로 hostname 변경
IP.1 = 127.0.0.1
IP.2 = 192.168.77.121                                       // 각 etcd node별로 ip 변경

$ openssl genrsa -out /etc/kubernetes/pki/etcd/server.key 2048; chmod 644 /etc/kubernetes/pki/etcd/server.key
$ openssl req -new -key /etc/kubernetes/pki/etcd/server.key -subj '/CN=node1' |
  openssl x509 -req -CA /etc/kubernetes/pki/etcd/ca.crt -CAkey /etc/kubernetes/pki/etcd/ca.key -CAcreateserial -out /etc/kubernetes/pki/etcd/server.crt -days 36500 -extensions v3_req_etcd -extfile /opt/kubernetes/pki/openssl-etcd.conf

$ openssl genrsa -out /etc/kubernetes/pki/etcd/peer.key; chmod 644 /etc/kubernetes/pki/etcd/peer.key
$ openssl req -new -key /etc/kubernetes/pki/etcd/peer.key -subj '/CN=node1' |
  openssl x509 -req -CA /etc/kubernetes/pki/etcd/ca.crt -CAkey /etc/kubernetes/pki/etcd/ca.key -CAcreateserial -out /etc/kubernetes/pki/etcd/peer.crt -days 36500 -extensions v3_req_etcd -extfile /opt/kubernetes/pki/openssl-etcd.conf

$ openssl genrsa -out /etc/kubernetes/pki/etcd/healthcheck-client.key 2048; chmod 644 /etc/kubernetes/pki/etcd/healthcheck-client.key
$ openssl req -new -key /etc/kubernetes/pki/etcd/healthcheck-client.key -subj '/O=system:masters/CN=kube-etcd-healthcheck-client' |
  openssl x509 -req -CA /etc/kubernetes/pki/etcd/ca.crt -CAkey /etc/kubernetes/pki/etcd/ca.key -CAcreateserial -out /etc/kubernetes/pki/etcd/healthcheck-client.crt -days 36500 -extensions v3_req_client -extfile /opt/kubernetes/pki/openssl-etcd.conf

$ systemctl daemon-reload
$ systemctl enable etcd
$ systemctl restart etcd
$ ionice -c2 -n0 -p `pgrep etcd`
```      