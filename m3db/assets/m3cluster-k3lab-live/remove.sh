#!/bin/bash

# kubectl delete -f 6.m3aggregator.yaml
# kubectl delete -f 5.m3db-coordinator.yaml

kubectl -n m3db exec etcd-0 -- env ETCDCTL_API=3 etcdctl del --prefix ""
kubectl -n m3db delete m3dbcluster m3-cluster

kubectl delete -f ./manifests -f ./manifests/setup
kubectl delete customresourcedefinition m3dbclusters.operator.m3db.io