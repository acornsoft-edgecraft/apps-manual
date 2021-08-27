# Chek List
- [ ] M3DB ETCD Create Namespace on M3DB Cluster - cli
- [ ] M3DB ETCD 백업 / 복원
- [ ] M3DB Cluster 백업 / 복원

## M3DB ETCD - Create Namespace on M3DB Cluster

## M3DB ETCD 클러스터 백업 / 복원 for external ETCD(pod)
```sh
# ETCD Check
kubectl -n m3db exec etcd-0 -- env ETCDCTL_API=3 etcdctl member list --write-out=table
kubectl -n m3db exec etcd-0 -- env ETCDCTL_API=3 etcdctl endpoint status --write-out=table
kubectl -n m3db exec etcd-1 -- env ETCDCTL_API=3 etcdctl endpoint status --write-out=table
kubectl -n m3db exec etcd-2 -- env ETCDCTL_API=3 etcdctl endpoint status --write-out=table
kubectl -n m3db exec etcd-0 -- env ETCDCTL_API=3 etcdctl endpoint health --write-out=table
kubectl -n m3db exec etcd-1 -- env ETCDCTL_API=3 etcdctl endpoint health --write-out=table
kubectl -n m3db exec etcd-2 -- env ETCDCTL_API=3 etcdctl endpoint health --write-out=table

## etcd 조회
kubectl -n m3db exec etcd-0 -- env ETCDCTL_API=3 etcdctl get "" --prefix --keys-only | sed '/^\s*$/d'

## etcd 초기화
kubectl -n m3db exec etcd-0 -- env ETCDCTL_API=3 etcdctl del --prefix "" 

## etcd backup
kubectl -n m3db exec etcd-0 -- env ETCDCTL_API=3 etcdctl snapshot save snapshot.db

## etcd backup file copy to local directory
kubectl -n m3db cp etcd-0:snapshot.db snapshot.db

## etcd restore file copy to pod 
kubectl -n m3db cp snapshot.db etcd-0:snapshot.db

## etcd 클러스터 복원
kubectl -n m3db exec etcd-0 -- env ETCDCTL_API=3 etcdctl snapshot restore snapshot.db
```

## M3DB ETCD 클러스터 백업 / 복원 for embedded ETCD(master node)
```sh
# ETCD Check
ETCDCTL_API=3 etcdctl member list --write-out=table
ETCDCTL_API=3 etcdctl endpoint status --write-out=table
ETCDCTL_API=3 etcdctl endpoint status --write-out=table
ETCDCTL_API=3 etcdctl endpoint status --write-out=table
ETCDCTL_API=3 etcdctl endpoint health --write-out=table
ETCDCTL_API=3 etcdctl endpoint health --write-out=table
ETCDCTL_API=3 etcdctl endpoint health --write-out=table

## etcd 조회
ETCDCTL_API=3 etcdctl get "" --prefix --keys-only | sed '/^\s*$/d'

## etcd 초기화
ETCDCTL_API=3 etcdctl del --prefix "" 

## etcd backup
ETCDCTL_API=3 etcdctl --endpoints $ENDPOINT snapshot save snapshot.db

## snapshot 확인
ETCDCTL_API=3 etcdctl --write-out=table snapshot status snapshotd.b

## etcd 클러스터 복원
## 모든 M3DB 인스턴스 중지 > 복원 > 재가동

ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=<trusted-ca-file> --cert=<cert-file> --key=<key-file> \
  snapshot save <backup-file-location>
```

-----
## 참고
> [Kubernetes용 etcd 클러스터 운영](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/)