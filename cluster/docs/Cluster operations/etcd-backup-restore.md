# etcd data snapshot and restore

# 1. etcd 스냅샷을 주기적으로 저정함.
 * etcd snapshot은 `etcdctl snapshot save` 명령으로 간단히 저장할 수 있다.
 
```bash
$ export ETCDCTL_API=3
$ export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/peer.crt
$ export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
$ export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/peer.key

$ mkdir /root/backup

$ etcdctl --endpoints=https://192.168.77.121:2379 snapshot save /root/backup/etcd-snapshot-$(date '+%Y%m%d_%H%M%S')
```

# 2. 저장된 etcd snapshot으로 복원
 * etcd snapshot은 `etcdctl snapshot restore` 명령으로 간단히 복원할 수 있다.
 * etcd user가 없을 경우 생성하고 반드시 etcd data 디렉토리 권한은 etcd:etcd로 설정해야 한다.
 
```bash
$ useradd -s /sbin/nologin etcd
$ chown -R etcd:etcd /data/etcd


$ export ETCDCTL_API=3
$ export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/peer.crt
$ export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
$ export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/peer.key
$ etcdctl --endpoints=https://192.168.77.121:2379,https://192.168.77.122:2379,https://192.168.77.123:2379 \
--name=vm-onassis-01 --initial-advertise-peer-urls="https://192.168.77.121:2380" \
--initial-cluster="vm-onassis-01=https://192.168.77.121:2380,vm-onassis-02=https://192.168.77.122:2380,vm-onassis-03=https://192.168.77.123:2380" \
--initial-cluster-token="etcd-k8-cluster" \
--data-dir="/data/etcd" \
snapshot restore /root/backup/etcd-snapshot-20200417_101537

$ systemctl enable etcd
$ systemctl daemon-reload
$ systemctl start etcd
```