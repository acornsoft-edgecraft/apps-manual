[TOC]

> 클러스터 설치 ansible script가 포함된 docker image를 사용할 수 있다.
> Ansible docker image를 사용하기 위해서는 docker 환경이 구성되어 있어야 한다.

# Docker container 및 ansible-playbook 실행
 1. 작업 디렉토리 생성하기
```bash
$ mkdir -p ~/workspace/cluster/lab01
$ cd ~/workspace/cluster/lab01
```

 2. 각 장비에 SSH 암호없이 접속하도록 설정하기
[SSH Key 설정하기](../ssh key.md)

 3. Inventory 및 클러스터 설치 관련 변수 설정
```bash
lab01
├── group_vars
│   └── all
│       ├── basic.yml
│       └── expert.yml
└── inventory.ini
``` 
 
# ansible-playbook을 사용한 클러스터 설치

## 폐쇄망에서 설치를 위한 사전 준비(local-repo, registry 압축 파일 만들기)
 * ansible 환경 설정 및 작업 디렉토리로 이동
```bash
$ export ANSIBLE_CONFIG=/Users/cloud/gows/src/git.acornsoft.io/infra/knit/Dockerfile/scripts/ansible.cfg
$ cd /Users/cloud/gows/src/git.acornsoft.io/infra/knit/test
```

 * inventory.ini 파일에 target server ip 설정하기
```bash
$ vi inventory/lab01/inventory.ini
# Inventory sample
[all]
master-01   ansible_ssh_host=192.168.77.223  ip=192.168.77.223
master-02   ansible_ssh_host=192.168.77.224  ip=192.168.77.224
master-03   ansible_ssh_host=192.168.77.225  ip=192.168.77.225
etcd-01     ansible_ssh_host=192.168.77.223  ip=192.168.77.223
etcd-02     ansible_ssh_host=192.168.77.224  ip=192.168.77.224
etcd-03     ansible_ssh_host=192.168.77.225  ip=192.168.77.225
node-01     ansible_ssh_host=192.168.77.226  ip=192.168.77.226
node-02     ansible_ssh_host=192.168.77.227  ip=192.168.77.227
storage-01  ansible_ssh_host=192.168.77.228  ip=192.168.77.228
registry-01 ansible_ssh_host=192.168.77.228  ip=192.168.77.228

[etcd]
etcd-01
etcd-02
etcd-03

[masters]
master-01
master-02
master-03

[sslhost]
master-01

[node]
node-01
node-02

[gpu-node]

[multi-nic-node]

[storage]
storage-01

[registry]
registry-01

[cluster:children]
masters
node
gpu-node
multi-nic-node
```

 * inventory/lab01/group_vars/all/basic.yml
```bash
$ vi inventory/lab01/group_vars/all/basic.yml
provider: false
cloud_provider: onpremise
cluster_name: test-cluster

# install directories
install_dir: /var/lib/knit
data_root_dir: /data

# kubernetes options
k8s_version: 1.21.2
cluster_id: test-cluster
api_lb_ip: https://192.168.77.223:6443
lb_ip: 192.168.77.223
lb_port: 6443
pod_ip_range: 10.0.0.0/16
service_ip_range: 172.20.0.0/16

# for air gap installation
closed_network: true              <------------  (중요) 사전준비시에는 반드시 internet 가능한 상태이어야 함.
local_repository: http://192.168.77.228:8080
local_repository_archieve_file:

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
registry_archieve_file:

# option for NFS storage
storage_install: true
nfs_ip: 192.168.77.228
nfs_volume_dir: /storage

# for internal load-balancer
haproxy: true
``` 

 * inventory/lab01/group_vars/all/expert.yml
```bash
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

# haproxy for internal loadbalancer
haproxy_dir: /etc/haproxy
haproxy_port: 6443
haproxy_health_check_port: 8081

# option for preparing local-repo and registry (do not modify when fully understand this flag)
archive_repo: true                        <------------  (중요) 리포지터리 압축 여부 true로 설정.

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
base64_controller_secret: ""
base64_monitoring_secret: ""
base64_cluster_seq: ""
base64_cluster_id: ""
storage_class_name: default-storage
storage_type: nfs
sctp_support: false
multus_install: false
device_name: ""
device_ven: ""
device_dev: ""
device_driver: ""
ingress_type: Deployment
fs_type: xfs
mirror_count: 1
perf_tier: best-effort
volume_binding_mode: WaitForFirstConsumer
istio_install: false

dashboard_public_cert: false
ha_type: ""

kube_support_versions:
  [
    "1.19.10",
    "1.19.11",
    "1.19.12",
    "1.20.6",
    "1.20.7",
    "1.20.8",
    "1.21.0",
    "1.21.1",
    "1.21.2"
  ]

kube_feature_gates: |-
    [
      "TTLAfterFinished=true"
      ,"RemoveSelfLink=false"
      {%- if sctp_support is defined and sctp_support -%}
      ,"SCTPSupport=true"
      {%- endif -%}
    ]

kubeproxy_feature_gates: |-
    [
      "TTLAfterFinished: true"
      {%- if sctp_support -%}
      , "SCTPSupport: true"
      {%- endif -%}
    ]
``` 

 * prepare-repository.yml 플래이북 실행으로 local-repo, harbor 압축 파일 생성 및 다운로드 하기
```bash
// Centos 8

$ vi inventory/lab01/group_vars/all/basic.yml
...
local_repository_archieve_file: /Users/cloud/gows/src/git.acornsoft.io/infra/knit/test/inventory/lab01/local-repo.20210720_095540.tgz
closed_network: true
registry_archieve_file: /Users/cloud/gows/src/git.acornsoft.io/infra/knit/test/inventory/lab01/harbor.20210720_100126.tgz
...

$ ansible-playbook -i inventory/lab01/inventory.ini -u root --private-key ~/cert/knit/id_rsa ../Dockerfile/scripts/prepare-repository.yml
$ scp root@192.168.77.228:/tmp/local-repo.20210720_095540.tgz .
$ scp root@192.168.77.228:/tmp/harbor.20210720_100126.tgz .
$ ansible-playbook -i inventory/lab01/inventory.ini -u root --private-key ~/cert/knit/id_rsa ../Dockerfile/scripts/reset.yml --tags reset-registry

// Ubuntu 20.04
$ vi inventory/lab03/group_vars/all/basic.yml
...
local_repository_archieve_file: /Users/cloud/gows/src/git.acornsoft.io/infra/knit/test/inventory/lab03/local-repo.20210723_041357.tgz
closed_network: true
registry_archieve_file: /Users/cloud/gows/src/git.acornsoft.io/infra/knit/test/inventory/lab03/harbor.20210723_041643.tgz
...

 
$ ansible-playbook -i inventory/lab03/inventory.ini -u root --private-key ~/cert/knit/id_rsa ../Dockerfile/scripts/prepare-repository.yml
$ scp root@192.168.77.194:/tmp/local-repo.20210723_041357.tgz .
$ scp root@192.168.77.194:/tmp/harbor.20210723_041643.tgz .
$ ansible-playbook -i inventory/lab03/inventory.ini -u root --private-key ~/cert/knit/id_rsa ../Dockerfile/scripts/reset.yml --tags reset-registry
```

 * 클러스터 설치, 노드 추가, 업그레이드 삭제   
```bash
// Centos 8
$ ansible-playbook -i inventory/lab01/inventory.ini -u root --private-key ~/cert/knit/id_rsa ../Dockerfile/scripts/cluster.yml
$ ansible-playbook -i inventory/lab01/inventory.ini -u root --private-key ~/cert/knit/id_rsa ../Dockerfile/scripts/add-node.yml
$ ansible-playbook -i inventory/lab01/inventory.ini -u root --private-key ~/cert/knit/id_rsa ../Dockerfile/scripts/upgrade.yml

// Ubuntu 20.04
$ ansible-playbook -i inventory/lab03/inventory.ini -u root --private-key ~/cert/knit/id_rsa ../Dockerfile/scripts/cluster.yml
$ ansible-playbook -i inventory/lab03/inventory.ini -u root --private-key ~/cert/knit/id_rsa ../Dockerfile/scripts/add-node.yml
$ ansible-playbook -i inventory/lab03/inventory.ini -u root --private-key ~/cert/knit/id_rsa ../Dockerfile/scripts/upgrade.yml
```

# docker container를 활용한 클러스터 설치 
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