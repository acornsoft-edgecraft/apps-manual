# Metrics Server
Metrics Server 는 리소스 사용량 데이터의 클러스터 전체 집계 도구입니다. Metrics Server는 각 노드에서 Kubelet에 의해 노출된 요약 API에서 메트릭을 수집합니다.

## Prerequisites
1. Kubernetes 1.12+
2. Helm 3.1.0
  
## Architecture

## Metrics-server를 master node에 배포하기 위해서 values 값을 설정 해준다. - to values.yaml
- metrics-server-controller.yaml 내용을 아래와 같이 수정 한다.
  - 모든 노드에 스케줄 될수 있도록 tolerations 설정을 한다.
  - nodeSelector 또는 nodeAffinity 를 사용 해서 master node를 지정 한다.
  - replicaset을 증가시켜리면 master 노드는 ha 구성 되어 있어야 한다.
```yaml
# vi values.yaml
## develop 환경 에서는 편의상 kubelet-insecure-tls=true 로 설정 한다.
extraArgs:
  kubelet-insecure-tls: true
  kubelet-preferred-address-types: InternalIP

## image 를 <Air-gap registry>에 업로드 한 이미지로 설정 한다.
image:
  registry: k8s.gcr.io
  repository: metrics-server/metrics-server
  tag: v0.5.0

## Metrics-server를 master node에 배포하기 위해서 podAntiAffinity 설정을 해준다. - replicas: 2 개 일경우를 위해서 설정
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchLabels:
          k8s-app: metrics-server
      topologyKey: kubernetes.io/hostname

## Metrics-server를 master node에 배포하기 위해서 nodeSelector 및 tolerations 설정을 해준다.
nodeSelector:
  node-role.kubernetes.io/master: ''

tolerations:
  # Make sure metrics-server gets scheduled on all nodes.
  - effect: NoSchedule
    operator: Exists
```


## Installation With Helm
```sh
## Helm is set up properly, add the repo as follows:
helm repo add metrics-server https://charts.bitnami.com/bitnami/metrics-server

## values.yaml을 환경에 맞게 수정후 설치 
helm upgrade metrics-server -i \
  -n kube-system \
  --create-namespace \
  --cleanup-on-fail \
  metrics-server \
  -f values.yaml
```

## Merics Server Installation in Air-gap

- helm package 생성
  - Chart.yaml에서 dependencies 확인 하여 charts directory에 준비 되어 있어야 한다.
```sh
helm package .
```

- 생성된 package를 레지스트리에(Harbor) charts 업로드 한다.

- Metrics-server installation in Air-gap
```sh
## Helm is set up properly, add the <Air-gap repository> as follows:
## helm repo add metrics-server <Air-gap repository>
## https://x.x.x.x/chartrepo/k3lab-charts

## values.yaml을 환경에 맞게 수정후 설치
## <Air-gap repository>의 ca.crt를 다운로드 한다.
helm upgrade metrics-server -i \
  -n kube-system \
  --create-namespace \
  --cleanup-on-fail \
  --ca-file ./ca.crt \
  --repo https://<Air-gap repository> \
  metrics-server \
  -f values.yaml
```

---
# 참조
> [Metrics Server - Installing the Chart ](https://github.com/bitnami/charts/tree/master/bitnami/metrics-server)