# Kubernetes NFS-Client Provisioner

Follow these steps to get started with nfs-client:
1. 사전 준비: you must already have an NFS Server
2. Helm 3
3. Kubernetes NFS-Client Provisioner Helm chart
  
## Architecture


## Installation With Helm
```sh
## Helm is set up properly, add the repo as follows:
helm repo add stable https://charts.helm.sh/stable

## nfs.server= nfs server ip address
## nfs.path= nfs server directory
## archiveOnDelete=true (default:true) 
helm upgrade nfs-client-provisioner -i \
  -n kube-system \
  --create-namespace \
  --cleanup-on-fail \
  --set storageClass.name=nfs-storageclass \
  --set nfs.server=x.x.x.x \
  --set nfs.path=/data/nfs/live \
  --set storageClass.archiveOnDelete=true \
  --repo https://charts.helm.sh/stable \
  nfs-client-provisioner
```

## PVC 생성 테스트
```sh
cat <<EOF | kubectl -n kube-system apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc-test
spec:
  storageClassName: nfs-storageclass # SAME NAME AS THE STORAGECLASS
  accessModes:
    - ReadWriteMany #  must be the same as PersistentVolume
  resources:
    requests:
      storage: 1Gi
EOF
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

- nfs-storageclass 를 삭제 후 / 재 설치 
```sh
 $ kubectl delete -f nfs-storageclass.yaml
 
 $ kubectl apply -f nfs-storageclass.yaml
```

---
# 참조
> [Kubernetes NFS-Client Provisioner](https://github.com/kubernetes-incubator/external-storage/tree/master/nfs-client)