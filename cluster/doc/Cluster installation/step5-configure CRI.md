[TOC]

### Docker 설치
* Ubuntu
```bash
$ mkdir -p /data/docker
$ mkdir /etc/docker
$ cat > /etc/docker/daemon.json <<EOF
{
  "data-root": "/data/docker",
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

$ apt-get install -y containerd.io=1.4.6-1
$ apt-get install -y docker-ce=5:19.03.15~3-0~ubuntu-bionic
$ apt-get install -y docker-ce-cli=5:19.03.15~3-0~ubuntu-bionic

$ apt-mark hold docker-ce  // hold from upgrade
$ apt-mark hold containerd.io  // hold from upgrade

$ docker info
# 일반 사용자 docker 실행 허용하기
$ sudo usermod -aG docker ${USER}

```

 * Centos, RHEL
```bash
# Internet 연결이 되는 환경에서 docker-ce repository 설정.
$ yum install -y yum-utils device-mapper-persistent-data lvm2
$ yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

$ yum update -y && yum install -y http://192.168.77.128:8080/container-selinux-2.158.0-1.el8.4.0.noarch.rpm

- containerd 사용인 경우
$ yum update -y && yum install -y containerd.io-1.4.6

- docker 사용인 경우
$ yum update -y && yum install -y docker-ce-19.03.15 docker-ce-cli-19.03.15

$ mkdir -p /data/docker
$ mkdir /etc/docker
$ cat > /etc/docker/daemon.json <<EOF
{
  "data-root": "/data/docker",
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

$ systemctl daemon-reload
$ systemctl restart docker

$ docker info

# 일반 사용자 docker 실행 허용하기
$ sudo usermod -aG docker ${USER}
```

### Containerd 설치

 * CRI를 containerd로 설정할 경우 cluster를 구성하는 master, worker node는 containerd로 설치하고, registry는 docker를 설치함.
 * Ubuntu
```bash
$ apt install -y containerd.io=1.4.3-1
$ apt-mark hold containerd  // hold from upgrade
```

 * Centos, RHEL
```bash
$ yum install http://192.168.77.128:8080/container-selinux-2.158.0-1.el8.4.0.noarch.rpm
$ yum install -y containerd.io-1.4.6

$ mkdir /etc/containerd
$ containerd config default > /etc/containerd/config.toml

$ vi /etc/containerd/config.toml
version = 2
root = "/data/containerd"   # containerd data root directory 변경
state = "/run/containerd"
plugin_dir = ""
disabled_plugins = []
required_plugins = []
oom_score = 0
...

[plugins]
  [plugins."io.containerd.gc.v1.scheduler"]
    pause_threshold = 0.02
    deletion_threshold = 0
    mutation_threshold = 100
    schedule_delay = "0s"
    startup_delay = "100ms"
  [plugins."io.containerd.grpc.v1.cri"]
    disable_tcp_service = true
    stream_server_address = "127.0.0.1"
    stream_server_port = "0"
    stream_idle_timeout = "4h0m0s"
    enable_selinux = false
    selinux_category_range = 1024
    sandbox_image = "192.168.77.128/google_containers/pause:3.2"  # 폐쇄망일 경우 반드시 변경햐야 함. 기본값은 k8s.gcr.io/pause:3.2 임.
    stats_collect_period = 10
    systemd_cgroup = true   # systemd_cgroup = true로 변경
    enable_tls_streaming = false
    max_container_log_line_size = 16384
    disable_cgroup = false
    disable_apparmor = false
    restrict_oom_score_adj = false
    max_concurrent_downloads = 3
    disable_proc_mount = false
    unset_seccomp_profile = ""
    tolerate_missing_hugetlb_controller = true
    disable_hugetlb_controller = true
    ignore_image_defined_volumes = false
    [plugins."io.containerd.grpc.v1.cri".containerd]
      snapshotter = "overlayfs"
      default_runtime_name = "runc"
      no_pivot = false
      disable_snapshot_annotations = true
      discard_unpacked_layers = false
      [plugins."io.containerd.grpc.v1.cri".containerd.default_runtime]
        runtime_type = "io.containerd.runtime.v1.linux"   # runtime_type 변경
        runtime_engine = ""
        runtime_root = ""
        privileged_without_host_devices = false
        base_runtime_spec = ""
      [plugins."io.containerd.grpc.v1.cri".containerd.untrusted_workload_runtime]
        runtime_type = ""
        runtime_engine = ""
        runtime_root = ""
        privileged_without_host_devices = false
...

$ systemctl enable containerd
$ systemctl restart containerd
$ systemctl status containerd
```

 * crictl 설치
```bash
# 로컬 repo
curl -LO http://192.168.77.128:8080/crictl-v1.20.0-Linux-amd64.tar.gz
# 온라인 설정
VERSION="v1.21.0"
curl -L https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-${VERSION}-linux-amd64.tar.gz --output crictl-${VERSION}-linux-amd64.tar.gz


sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz

```

 * crictl.yaml 파일 설정
  > 침고: 이미지 엔드 포인트가 설정되지 않은 경우 crictl 기본적으로 런타임 엔드 포인트 설정을 사용합니다
     
```bash
$ cat > /etc/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
EOF

또는 crictl 명령어 사용 (crictl config --help )

$ crictl config \
    --set runtime-endpoint=unix:///run/containerd/containerd.sock \
    --set image-endpoint=unix:///run/containerd/containerd.sock \
    --set timeout=10

# image list 확인 
$ crictl images 
```

----
# 참조
> [Container Runtime Interface (CRI) CLI](https://github.com/kubernetes-sigs/cri-tools/blob/master/docs/crictl.md)
> [Debugging Kubernetes nodes with crictl](https://kubernetes.io/docs/tasks/debug-application-cluster/crictl/)
