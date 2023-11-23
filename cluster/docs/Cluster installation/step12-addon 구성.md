[TOC]

## Addons
 * Kubernetes NFS-Client Provisioner

    ## NFS-Client Provisioner Installation With Helm

    Follow these steps to get started with nfs-client:
    1. 사전 준비: you must already have an NFS Server
    2. HELM 3
    3. Kubernetes NFS-Client Provisioner helm chart
   

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
    --set nfs.server=x.x.x.x \
    --set nfs.path=/data/nfs/live \
    --set storageClass.archiveOnDelete=true \
    stable/nfs-client-provisioner
    ```

----
# 참조
> [NFS-Client Provisioner](https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/)  