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

$ cd /etc/etcd
$ curl -LO http://192.168.77.128:8080/etcd-v3.4.14-linux-amd64.tar.gz
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

$ cat > /opt/kubernetes/pki/openssl-etcd.conf <<EOF  
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
EOF
```

 * 인증서 생성
```bash
$ openssl genrsa -out /etc/kubernetes/pki/etcd/server.key 2048; chmod 644 /etc/kubernetes/pki/etcd/server.key
$ openssl req -new -key /etc/kubernetes/pki/etcd/server.key -subj '/CN=vm-onassis-01' |
  openssl x509 -req -CA /etc/kubernetes/pki/etcd/ca.crt -CAkey /etc/kubernetes/pki/etcd/ca.key -CAcreateserial -out /etc/kubernetes/pki/etcd/server.crt -days 36500 -extensions v3_req_etcd -extfile /opt/kubernetes/pki/openssl-etcd.conf

$ openssl genrsa -out /etc/kubernetes/pki/etcd/peer.key; chmod 644 /etc/kubernetes/pki/etcd/peer.key
$ openssl req -new -key /etc/kubernetes/pki/etcd/peer.key -subj '/CN=vm-onassis-01' |
  openssl x509 -req -CA /etc/kubernetes/pki/etcd/ca.crt -CAkey /etc/kubernetes/pki/etcd/ca.key -CAcreateserial -out /etc/kubernetes/pki/etcd/peer.crt -days 36500 -extensions v3_req_etcd -extfile /opt/kubernetes/pki/openssl-etcd.conf

$ openssl genrsa -out /etc/kubernetes/pki/etcd/healthcheck-client.key 2048; chmod 644 /etc/kubernetes/pki/etcd/healthcheck-client.key
$ openssl req -new -key /etc/kubernetes/pki/etcd/healthcheck-client.key -subj '/O=system:masters/CN=kube-etcd-healthcheck-client' |
  openssl x509 -req -CA /etc/kubernetes/pki/etcd/ca.crt -CAkey /etc/kubernetes/pki/etcd/ca.key -CAcreateserial -out /etc/kubernetes/pki/etcd/healthcheck-client.crt -days 36500 -extensions v3_req_client -extfile /opt/kubernetes/pki/openssl-etcd.conf
```

 * 인증서 확인
```bash
$ ll /etc/kubernetes/pki/etcd
-rw-r--r--. 1 root root 1046  6월 29 17:18 ca.crt
-rw-------. 1 root root 1675  6월 29 17:18 ca.key
-rw-r--r--. 1 root root   41  6월 29 18:06 ca.srl
-rw-r--r--. 1 root root 1127  6월 29 18:06 healthcheck-client.crt
-rw-r--r--. 1 root root 1675  6월 29 18:06 healthcheck-client.key
-rw-r--r--. 1 root root 1139  6월 29 18:06 peer.crt
-rw-r--r--. 1 root root 1675  6월 29 18:06 peer.key
-rw-r--r--. 1 root root 1139  6월 29 18:06 server.crt
-rw-r--r--. 1 root root 1679  6월 29 18:06 server.key

$ openssl x509 -text -noout -in /etc/kubernetes/pki/etcd/server.crt
$ openssl x509 -text -noout -in /etc/kubernetes/pki/etcd/peer.crt
``` 

```bash
$ cat > /etc/systemd/system/etcd.service <<EOF
[Unit]
Description=Etcd Server
After=network.target

[Service]
Type=simple
WorkingDirectory=/var/lib/etcd/
EnvironmentFile=-/etc/etcd/etcd.conf
User=etcd
ExecStart=/usr/bin/etcd
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
```

```bash
$ systemctl daemon-reload
$ systemctl enable etcd
$ systemctl restart etcd

$ export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
$ export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/peer.crt
$ export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/peer.key
$ etcdctl --endpoints=https://192.168.77.121:2379,https://192.168.77.122:2379,https://192.168.77.123:2379 member list -w table
+------------------+---------+---------------+-----------------------------+-----------------------------+------------+
|        ID        | STATUS  |     NAME      |         PEER ADDRS          |        CLIENT ADDRS         | IS LEARNER |
+------------------+---------+---------------+-----------------------------+-----------------------------+------------+
|  b99c3b51ec9243b | started | vm-onassis-01 | https://192.168.77.121:2380 | https://192.168.77.121:2379 |      false |
| 65e5d5f52c8b0aa8 | started | vm-onassis-03 | https://192.168.77.123:2380 | https://192.168.77.123:2379 |      false |
| bb369dcbe77cb397 | started | vm-onassis-02 | https://192.168.77.122:2380 | https://192.168.77.122:2379 |      false |
+------------------+---------+---------------+-----------------------------+-----------------------------+------------+

$ etcdctl --endpoints=https://192.168.77.121:2379,https://192.168.77.122:2379,https://192.168.77.123:2379 endpoint health -w table
+-----------------------------+--------+-------------+-------+
|          ENDPOINT           | HEALTH |    TOOK     | ERROR |
+-----------------------------+--------+-------------+-------+
| https://192.168.77.123:2379 |   true | 21.921311ms |       |
| https://192.168.77.121:2379 |   true |   19.8803ms |       |
| https://192.168.77.122:2379 |   true | 20.587902ms |       |
+-----------------------------+--------+-------------+-------+

$ etcdctl --endpoints=https://192.168.77.121:2379,https://192.168.77.122:2379,https://192.168.77.123:2379 endpoint status -w table
+-----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|          ENDPOINT           |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+-----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://192.168.77.121:2379 |  b99c3b51ec9243b |  3.4.14 |   16 kB |      true |      false |         7 |          9 |                  9 |        |
| https://192.168.77.122:2379 | bb369dcbe77cb397 |  3.4.14 |   16 kB |     false |      false |         7 |          9 |                  9 |        |
| https://192.168.77.123:2379 | 65e5d5f52c8b0aa8 |  3.4.14 |   16 kB |     false |      false |         7 |          9 |                  9 |        |
+-----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

$ ionice -c2 -n0 -p `pgrep etcd`

```