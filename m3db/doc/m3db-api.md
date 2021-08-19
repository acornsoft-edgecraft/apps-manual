# M3DB API

## M3db Cluster placement check
```
kubectl -n m3db exec m3-cluster-rep0-1 -- curl http://localhost:7201/api/v1/services/m3db/placement | jq .
```

## m3db placement 삭제
```
kubectl -n m3db exec m3-cluster-rep0-1 -- curl -X DELETE http://localhost:7201/api/v1/services/m3db/placement/4e78fd7e-7c52-4a32-8247-96770d3626b9 | jq .
```

## M3db placement 충돌 복구
```sh
# On Linux, using a limited shell, update the value for env=default_env
echo -n "ChF1bnN0cmljdF9tYWpvcml0eQ==" | base64 -d | env ETCDCTL_API=3 etcdctl put _kv/m3db/m3-cluster/m3db.client.bootstrap-consistency-level

# On MacOS, update the value for a cluster "test_cluster" in Kubernetes namespace "m3db"
ETCD_POD=etcd-0
echo -n "ChF1bnN0cmljdF9tYWpvcml0eQ==" | base64 -D | kubectl -nm3db exec -i $ETCD_POD -- env ETCDCTL_API=3 etcdctl put _kv/m3db/m3-cluster/m3db.client.bootstrap-consistency-level

# Delete the key to restore normal behavior
env ETCDCTL_API=3 etcdctl del _kv/m3db/m3-cluster/m3db.client.bootstrap-consistency-level
```