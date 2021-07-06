# Kubernetes NFS-Client Provisioner

Follow these steps to get started with nfs-client:
1. 사전 준비: you must already have an NFS Server
  
## Architecture


## Installation With Helm
```sh
## archiveOnDelete=true (default:true) 
helm upgrade nfs-client-provisioner -i \
  -n kube-system \
  --create-namespace \
  --cleanup-on-fail \
  --set nfs.server=x.x.x.x \
  --set nfs.path=/data/nfs/live \
  --set storageClass.archiveOnDelete=true \
  nfs-client-provisioner
```

## storageclass 수정
- **archiveOnDelete**:	If it exists and has a false value, delete the directory. if **onDelete** exists, **archiveOnDelete** will be ignored.
```sh
## 1. 현재 nfs-storageclass의 yaml생성 
$ kubectl get sc get sc nfs-storageclass -o yaml > nfs-storageclass.yaml -o yaml > nfs-storageclass.yaml

## 2. nfs-storageclass.yaml 수정
## archiveOnDelete: 값을 수정 한다.
parameters:
  archiveOnDelete: "true"
```

## 3. nfs-storageclass 를 삭제 후 / 재 설치 
```sh
 $ kubectl delete -f nfs-storageclass.yaml
 
 $ kubectl apply -f nfs-storageclass.yaml
```

---
# 참조
> [Node-pressure Eviction](https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/)