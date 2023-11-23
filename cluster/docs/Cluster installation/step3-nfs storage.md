[TOC]

# 1. NFS server 설정

### Copy exports file.
```bash
$ mkdir /storage
$ cat > /etc/exports <<EOF
# nfs_mountdir *(rw,sync,all_squash,no_subtree_check)
/storage  *(rw,async,no_root_squash,no_all_squash,no_subtree_check)
EOF
```

### Install nfs server on ubuntu
```bash
$ apt-get install -y nfs-common nfs-kernel-server
```

### Install nfs server on centos, RHEL
```bash
$ yum install -y nfs-utils
$ systemctl enable rpcbind
$ systemctl start rpcbind
$ systemctl start nfs-server

# nfs mount point 확인
$ showmount -e 192.168.77.228
Export list for 192.168.77.228:
/storage *
```
