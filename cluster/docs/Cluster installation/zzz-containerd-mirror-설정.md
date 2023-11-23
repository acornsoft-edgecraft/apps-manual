# Containerd mirrors 설정

## 컨테이너 런타임 인터페이스 (CRI) CLI
crictl은 CRI 호환 컨테이너 런타임을위한 CLI를 제공합니다. 이를 통해 CRI 런타임 개발자는 Kubernetes 구성 요소를 설정할 필요없이 런타임을 디버깅 할 수 있습니다.

crictl은 현재 베타 버전이며 아직 빠르게 반복되고 있습니다. [cri-tools](https://github.com/kubernetes-sigs/cri-tools) 저장소 에서 호스팅됩니다 . CRI 개발자가 버그를보고하거나 더 많은 기능을 추가하여 적용 범위를 확장하도록 권장합니다.


## containerd에 private 레지스트리 추가
CTR은 /etc/containerd/config.toml 설정 파일을 사용 하지 않는다.
이 설정은 CRI에 의해 사용되는 수단 으로  kubectl또는 crictl 명령을 사용합니다.

> 오류 로그 http: server gave HTTP response to HTTPS client는 레지스트리가 http를 사용하고 있음을 나타내지 만 ctr은 https를 사용하여 연결을 시도합니다.
> 따라서 http에서 이미지를 가져 오려면 다음 --plain-http과 같이 ctr과 함께 매개 변수 를 추가해야합니다 .
> 
> ctr i pull --plain-http <image>
> 레지스트리 구성 문서는 다음과 같습니다. https://github.com/containerd/containerd/blob/master/docs/cri/registry.md


- crictl로 구성한 후 이미지를 가져올 수 있어야합니다. 
- containerd를 다시 시작해야합니다.
```sh
sudo crictl -r /run/containerd/containerd.sock pull <image>

# or config runntime once for all - 다음 명령어로 /etc/crictl.yaml 파일을 생성 한다.
# crictl 명령어 사용 (crictl config --help )
$ crictl config \
    --set runtime-endpoint=unix:///run/containerd/containerd.sock \
    --set image-endpoint=unix:///run/containerd/containerd.sock \
    --set timeout=10

# 또는 cat EOF 사용
$ cat <<EOF > /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
EOF

## 확인 
sudo crictl <image>

## 구성 예 :

# /etc/containerd/config.toml
# change <IP>:5000 to your registry url

[plugins."io.containerd.grpc.v1.cri".registry]
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."<IP>:5000"]
      endpoint = ["http://<IP>:5000"]
  [plugins."io.containerd.grpc.v1.cri".registry.configs]
    [plugins."io.containerd.grpc.v1.cri".registry.configs."<IP>:5000".tls]
      insecure_skip_verify = true

```

##

# 참조
> [containerd에 private 레지스트리 추가](https://stackoverflow.com/questions/65681045/adding-insecure-registry-in-containerd)
> [Container Runtime Interface (CRI) CLI](https://github.com/kubernetes-sigs/cri-tools/blob/master/docs/crictl.md)
> [Debugging Kubernetes nodes with crictl](https://kubernetes.io/docs/tasks/debug-application-cluster/crictl/)