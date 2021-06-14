# Istio Install Cli

## 사전 준비
- istioctl 준비
```sh
# step-1. latest release 다운로드 - 1.10.0
curl -L https://istio.io/downloadIstio | sh -

# step-2. Istio package directory로 이동
cd cd istio-1.10.0

# istioctl 사용 하기 - path 지정
export PATH=$PWD/bin:$PATH
```

## Istio 설치
- k8s namespace 생성
```sh
kubectl create ns monitoring
```

- Istio 설치
  - operator 설정
  ```yaml
  apiVersion: install.istio.io/v1alpha1
  kind: IstioOperator
  metadata:
    name: istiocontrolplane
  spec:
    profile: default
    values:
      global:
        # namespqce 변경 - default: istio-system
        istioNamespace: monitoring
    meshConfig:
      accessLogFile: /dev/stdout
      enableTracing: true
      defaultConfig:
        tracing:
          sampling: 100.0
          max_path_tag_length: 256
  ```
  - 설치
  ```sh
  # IstioOperator 사용
  istioctl -n monitoring install -f istio-op.yaml
  ```

## Uninstall Istio
- 클러스터에서 Istio를 완전히 제거 하기
```sh
istioctl x uninstall --purge
```

# 참조
> [istioctl commands]([참조링크](https://istio.io/latest/docs/reference/commands/istioctl/))