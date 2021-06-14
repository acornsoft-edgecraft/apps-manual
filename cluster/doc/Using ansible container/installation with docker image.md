[TOC]

> 클러스터 설치 ansible script가 포함된 docker image를 사용할 수 있다.
> Ansible docker image를 사용하기 위해서는 docker 환경이 구성되어 있어야 한다.

## Docker container 및 ansible-playbook 실행
 1. 작업 디렉토리 생성하기
```bash
$ mkdir -p ~/workspace/cluster/lab01
$ cd ~/workspace/cluster/lab01
```

 2. 각 장비에 SSH 암호없이 접속하도록 설정하기
[SSH Key 설정하기](../ssh key.md)

 3. Inventory 및 클러스터 설치 관련 변수 설정
```bash
knit
├── group_vars
│   └── all
│       ├── basic.yml
│       └── expert.yml
└── inventory.ini

$ cat knit/inventory.ini
# Inventory sample
[all]
master-01   ansible_ssh_host=192.168.77.223  ip=192.168.77.223
etcd-01     ansible_ssh_host=192.168.77.223  ip=192.168.77.223
node-01     ansible_ssh_host=192.168.77.224  ip=192.168.77.224
node-02     ansible_ssh_host=192.168.77.225  ip=192.168.77.225
node-03     ansible_ssh_host=192.168.77.226  ip=192.168.77.226
node-04     ansible_ssh_host=192.168.77.227  ip=192.168.77.227
storage-01  ansible_ssh_host=192.168.77.228  ip=192.168.77.228
registry-01 ansible_ssh_host=192.168.77.228  ip=192.168.77.228

[etcd]
etcd-01

[etcd-private]
etcd-01

[masters]
master-01

[sslhost]
master-01

[node]
node-01
node-02
node-03
node-04

[gpu-node]

[multi-nic-node]

[registry]
registry-01

[storage]
storage-01

$ cat knit/group_vars/all/basic.yml
provider: false
cloud_provider: onpremise
cluster_name: test-cluster

# install directories
install_dir: /var/lib/cocktail
data_root_dir: /data

# kubernetes options
k8s_version: 1.20.6
cluster_id: test-cluster
api_lb_ip: https://192.168.77.223:6443
lb_ip: 192.168.77.223
lb_port: 6443
pod_ip_range: 10.0.0.0/16
service_ip_range: 172.16.0.0/16

# for air gap installation
closed_network: false
local_repository: ""

# option for master isolation
master_isolated: false
audit_log_enable: true
cert_validity_days: 36500

# container runtime [containerd | docker]
container_runtime: containerd

# kube-proxy mode [iptables | ipvs]
kube_proxy_mode: ipvs

# option for harbor registry
registry_install: true
registry_data_dir: /data/harbor
registry: 192.168.77.228
registry_domain: 192.168.77.228
registry_public_cert: false

# option for NFS storage
storage_install: true
nfs_ip: 192.168.77.228

# for internal load-balancer
haproxy: true
haproxy_dir: /etc/haproxy
haproxy_port: 6443

$ cat knit/group_vars/all/expert.yml
# kubernetes images and directories
kube_config_dir: /etc/kubernetes
manifest_config_dir: /etc/kubernetes/manifests
cert_dir: /etc/kubernetes/pki
master_cert_dir: /opt/kubernetes/pki
kube_addon_dir: /etc/kubernetes/addon
account_private_key: /etc/kubernetes/pki/sa.key
account_key: /etc/kubernetes/pki/sa.pub
ca_key: /etc/kubernetes/pki/ca.key
ca_cert: /etc/kubernetes/pki/ca.crt
api_key: /etc/kubernetes/pki/kube-apiserver.key
api_cert: /etc/kubernetes/pki/kube-apiserver.crt
api_kubelet_client_key: /etc/kubernetes/pki/apiserver-kubelet-client.key
api_kubelet_client_cert: /etc/kubernetes/pki/apiserver-kubelet-client.crt
proxy_ca_cert: /etc/kubernetes/pki/front-proxy-ca.crt
proxy_client_key: /etc/kubernetes/pki/front-proxy-client.key
proxy_client_cert: /etc/kubernetes/pki/front-proxy-client.crt
dashboard_cert: /etc/kubernetes/pki/dashboard.crt
dashboard_key: /etc/kubernetes/pki/dashboard.key
kubeadminconfig: /etc/kubernetes/admin.conf
api_image: gcr.io/google_containers/kube-apiserver-amd64:{{ k8s_version }}
controller_image: gcr.io/google_containers/kube-controller-manager-amd64:{{ k8s_version }}
scheduler_image: gcr.io/google_containers//kube-scheduler-amd64:{{ k8s_version }}
auth_mode: Node,Rbac
audit_log_enable: true
encrypt_secret: true
kubernetes_service_ip: "{{ service_ip_range|ipaddr('net')|ipaddr(1)|ipaddr('address') }}"
dns_ip: "{{ service_ip_range|ipaddr('net')|ipaddr(10)|ipaddr('address') }}"
api_secure_port: 6443
api_insecure_port: 8080


# etcd certificate
etcd_peer_url_scheme: https
etcd_ca_file: /etc/kubernetes/pki/etcd/ca.crt
etcd_cert_file: /etc/kubernetes/pki/etcd/server.crt
etcd_key_file: /etc/kubernetes/pki/etcd/server.key
etcd_peer_ca_file: /etc/kubernetes/pki/etcd/ca.crt
etcd_peer_cert_file: /etc/kubernetes/pki/etcd/peer.crt
etcd_peer_key_file: /etc/kubernetes/pki/etcd/peer.key
etcd_healthcheck_cert_file: /etc/kubernetes/pki/etcd/healthcheck-client.crt
etcd_healthcheck_key_file: /etc/kubernetes/pki/etcd/healthcheck-client.key

# addons
metrics_server: true
addon_install: true
prometheus_rules_lang: ko
ingress: true
ingress_http_external_port: 30001
ingress_https_external_port: 30002
yum_proxy: ""

subscription_id: ""
client_id: ""
client_secret: ""
tenant_id: ""
resource_group: ""
location: local
vnet_name: ""
subnet_name: ""
security_group_name: ""
primary_availability_set_name: ""
route_table_name: ""
efs_file_system_id: ""
storage_account: ""
yum_kubernetes_url: ""
api_sans: []
single_volume_dir: ""
single_volume_size: 0
shared_volume_dir: ""
static_volume_dir: ""
cluster_type: small
volume_size: 30
volume_dir: /storage
base64_controller_secret: ""
base64_monitoring_secret: ""
base64_cluster_seq: ""
base64_cluster_id: ""
storage_class_name: default-storage
storage_type: nfs
chart_repo_url: https://regi.acloud.run/chartrepo
chart_repo_project_name: addon-charts-beta
chart_repo_user: acorn_chart
chart_repo_password: AcornWkd#3
sctp_support: false
multus_install: false
device_name: ""
device_ven: ""
device_dev: ""
device_driver: ""
ingress_type: Deployment
cube_install_dir: /var/lib/cocktail
fs_type: xfs
mirror_count: 1
perf_tier: best-effort
volume_binding_mode: WaitForFirstConsumer
istio_install: false

release_name: cocktail
release_ver: ""
cocktail: false
dashboard_public_cert: false
ha_type: ""
```
 
 4. Run container and ansible-playbook
```bash
$ docker run -it --name=cubepack --rm -v ${PWD}:/cube/work regi.acloud.run/library/knit:1.0.0 /bin/bash

# 대상 장비 접속 여부 확인하기(필수)
$ ansible -i knit/inventory.ini -u root --private-key id_rsa  all -m ping

# 대상 장비 VM 파라미터 등 확인(옵션)
$ ansible -i knit/inventory.ini -u root --private-key id_rsa  all -m setup

# 클러스터 설치하기
$ ansible-playbook -i knit/inventory.ini -u root --private-key id_rsa ../scripts/cluster.yml

# 클러스터 Worker node 추가하기
$ ansible-playbook -i knit/inventory.ini -u root --private-key id_rsa ../scripts/add-node.yml

# 클러스터 업그레이드 하기
$ ansible-playbook -i knit/inventory.ini -u root --private-key id_rsa ../scripts/upgrade.yml

# 클러스터 Worker node 삭제하기
$ ansible-playbook -i knit/inventory.ini -u root --private-key id_rsa -e remove_node_name=node3 -e target=192.168.77.225 remove-node.yml
```

$ yum upgrade -y
$ reboot


[centos@vm-onassis-04 ~]$ uname -r   // CentOS Linux release 8.2.2004
4.18.0-193.6.3.el8_2.x86_64

[root@vm-onassis-01 ~]# uname -r     // CentOS Linux release 8.4.2105
4.18.0-305.3.1.el8.x86_64