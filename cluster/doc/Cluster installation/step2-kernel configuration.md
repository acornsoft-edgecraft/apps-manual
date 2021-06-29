[TOC]

## Asia/Seoul 로 시스템 시간 설정
```bash
$ timedatectl set-timezone Asia/Seoul

# set-timezone 명령 실패 시 해당 cmd로 재설정 한다.
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

or

$ sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

## Firewall stop & disable
```bash
# Centos, RHEL
$ systemctl stop firewalld
$ systemctl disable firewalld

# Ubuntu
## 상태 확인 - 비활성화(inactive)
$ ufw status
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

## Kernel Modules Command-Line
```sh
$ lsmod | grep ip_set : load되어 있는 module들을 보여준다.
$ insmod : insert module. module을 load 시켜준다.
$ rmmod : remove module. module을 제거 해준다.
$ modprobe : 모듈을 관리하는 명령어다.
    옵션:
        - 옵션 없음 : 모듈을 추가한다. (사용방법 : modprobe [모듈명])
        - -l : 모든 모듈 목록을 출력한다. (사용방법 : modprobe -l)
        - -r : 모듈을 제거한다. 의존성이 있는 모듈이 사용되고 있지 않으면 알아서 같이 제거한다. (사용방법 : modprobe -r [모듈명]
        - -c: 모듈 관련 환경설정파일의 내용을 전부 출력한다. (사용방법 : modprobe -c)
$ demode : module과 연관된, 혹은 module광 상관성이 있는
$ modinfo : module에 대한 정보를 출력해 준다.
$ grep -rn 'ip_set' /lib/modules/$(uname -r) : 모듈의 사용 가능 여부를 확인하는 방법
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
- centos
```bash
## centos
$ yum install -y ipvsadm ipset

## ubuntu
$ apt-get install -y ipvsadm ipset
```

- ubuntu
```bash
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