[TOC]

## Asia/Seoul 로 시스템 시간 설정
```bash
$ timedatectl set-timezone Asia/Seoul

$ timedatectl set-local-rtc 0
$ timedatectl set-timezone Asia/Seoul
Failed to set time zone: Failed to update /etc/localtime
$ ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
```

## RHEL/Centos selinux 옵션 설정
```bash
$ setenforce 0
$ sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```

## SWAP memory off

```bash
$ swapoff -a

$ vi /etc/fstab
UUID=8ac075e3-1124-4bb6-bef7-a6811bf8b870 /    xfs     defaults    0 0
#/swapfile none swap defaults 0 0
```

## Firewall stop & disable
```bash
# Centos, RHEL
$ systemctl stop firewalld
$ systemctl disable firewalld

# Ubuntu
$ ufw disable

```

## Centos, RHEL Install Network Manager enable
```bash
$ yum install -y NetworkManager
$ systemctl enable NetworkManager
```

## Prevent NetworkManager from managing Calico interfaces
```bash
$ cat > /etc/NetworkManager/conf.d/calico.conf <<EOF
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico
EOF
```

## Disable NetworkManager DNS processing when RHEL 8
```bash
$ cat > /etc/NetworkManager/conf.d/90-dns-none.conf <<EOF
[main]
dns=none
EOF
```

## Ubuntu kernel modules for Calico
```bash
$ cat > /etc/modules <<EOF
ip_set
ip_tables
ip6_tables
ipt_REJECT
ipt_rpfilter
ipt_set
nf_conntrack_netlink
xt_addrtype
xt_comment
xt_conntrack
xt_ipvs
xt_mark
xt_multiport
xt_sctp
xt_set
ipip
nf_conntrack_netlink
ipt_rpfilter
# Not found in Kernel 4.18.0-193
#      xt_u32
#      sctp
# Not found in Kernel 3.10.0-1062.18.1
#      xt_icmp
#      xt_icmp6
EOF
```

## Centos, RHEL kernel modules for Calico
```bash
$ modprobe ip_set ip_tables ip6_tables ipt_REJECT ipt_rpfilter ipt_set nf_conntrack_netlink xt_addrtype xt_comment xt_conntrack xt_ipvs xt_mark xt_multiport xt_sctp xt_set ipip nf_conntrack_netlink ipt_rpfilter


$ cat > /etc/modules-load.d/calico.conf <<EOF
ip_set
ip_tables
ip6_tables
ipt_REJECT
ipt_rpfilter
ipt_set
nf_conntrack_netlink
xt_addrtype
xt_comment
xt_conntrack
xt_ipvs
xt_mark
xt_multiport
xt_sctp
xt_set
ipip
nf_conntrack_netlink
ipt_rpfilter
# Not found in Kernel 4.18.0-193
#      xt_u32
#      sctp
# Not found in Kernel 3.10.0-1062.18.1
#      xt_icmp
#      xt_icmp6
EOF
```

## kube-proxy needs net.bridge.bridge-nf-call-iptables enabled when found if br_netfilter is not a module
```bash
$ modinfo br_netfilter
$ modprobe br_netfilter
$ cat > /etc/modules-load.d/cube-br_netfilter.conf <<EOF
br_netfilter
EOF
```

## IPVS configuration when kube_proxy_mode is ipvs
```bash
$ modprobe ip_vs ip_vs_rr ip_vs_wrr ip_vs_sh
```

```bash
$ modprobe nf_conntrack
```


## Persist ip_vs modules when kube-proxy is ipvs mode
```bash
$ cat > /etc/modules-load.d/ipvs.conf <<EOF
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack
EOF
```

## Modprobe nf_conntrack_ipv4 for kernels >= 4.19 when kube-proxy is ipvs mode
```bash
$ yum install -y ipvsadm ipset
$ apt-get install -y ipvsadm ipset
```

## Modprobe nf_conntrack_ipv4 for kernels >= 4.19 when kube-proxy is ipvs mode
```bash
$ sysctl -w net.bridge.bridge-nf-call-iptables=1
$ sysctl -w net.bridge.bridge-nf-call-arptables=1
$ sysctl -w net.bridge.bridge-nf-call-ip6tables=1

$ sysctl --system
```

### To prevent Pods stuck on terminating. Refer to https://bugzilla.redhat.com/show_bug.cgi?id=1441737
### Enable fs.may_detach_mounts when centos 7
```bash
$ sysctl -w fs.may_detach_mounts=1
```

## Make directory
```bash
$ mkdir /data
$ mkdir /data/log
$ mkdir -p /etc/docker/certs.d/192.168.77.128
```