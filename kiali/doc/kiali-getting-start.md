# Kiali Getting Start

Follow these steps to get started with Istio:
- 1. 사전 준비 helm3
- 2. Kiali 리소스를 이미 설치 한 경우 먼저 제거해야 한다
  
## Kiali Operator Helm 차트 설치
- Helm 차트를 사용하여 Kiali CR (istio 네임 스페이스에 Kiali 서버가 설치되도록 트리거)과 함께 최신 Kiali Operator를 설치하려면 다음을 실행한다.
```sh
helm upgrade kiali-operator -i \
  -n monitoring \
  --create-namespace \
  --cleanup-on-fail \
  --set cr.create=true \
  --set cr.namespace=monitoring \
  --set auth.strategy="token" \
  --repo https://kiali.org/helm-charts \
  kiali-operator
  
```
- To install a specific version X.Y.Z, simply pass --version X.Y.Z to the helm command


## Kiali Operator 및 Kiali 제거
- Kiali CR을 먼저 삭제하지 못하면 클러스터에서 CR이 배포 된 네임 스페이스를 삭제할 수 없으며 Kiali 서버의 나머지는 삭제되지 않는다
  - Kiali CR을 성공적으로 삭제 한 후 Helm을 사용하여 Kiali Operator를 제거 할 수 있다
  - Helm은 CRD를 삭제하지 않기 때문에 모든 것을 정리하려면 아래 명령어를 수행해야 한다.
```sh
helm uninstall --namespace monitoring kiali-operator
kubectl delete crd monitoringdashboards.monitoring.kiali.io
kubectl delete crd kialis.kiali.io
```

# 참조
> [참조명](참조링크)