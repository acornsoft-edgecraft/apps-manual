# Containerd mirrors 설정

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
sudo crictl config runtime-endpoint /run/containerd/containerd.sock
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