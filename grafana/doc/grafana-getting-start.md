# Grafana Getting Start

Follow these steps to get started with Grafana:
- 1. Helm3 준비
- 2. Elasticsearch 설정 값 확인
- 3. 
## Architecture

## Installing the Helm-Chart
- Helm 차트를 사용하여 최신 Grafana를 설치하려면 다음을 실행한다.
```sh
helm upgrade grafana -i \
  -n monitoring \
  --create-namespace \
  --cleanup-on-fail \
  --repo https://grafana.github.io/helm-charts \
  grafana \
  -f values.yaml
```

## Values 설정
```yaml
rbac:
  create: true
  ## Use an existing ClusterRole/Role (depending on rbac.namespaced false/true)
  # useExistingRole: name-of-some-(cluster)role
  ### true -> false : # PodSecurityPolicy는 Kubernetes v1.21부터 더 이상 사용되지 않으며 v1.25에서 제거됩니다.
  pspEnabled: false
  pspUseAppArmor: false
  namespaced: false

...

resources:
 limits:
   cpu: 100m
   memory: 128Mi
 requests:
   cpu: 100m
   memory: 128Mi

...

## storageclass 사용
persistence:
  type: pvc
  enabled: true
  storageClassName: nfs-storageclass

...

## prometheus datasources 등록
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - access: proxy
      editable: true
      isDefault: true
      jsonData:
        timeInterval: 5s
      name: Prometheus
      orgId: 1
      type: prometheus
      url: http://prometheus-server.monitoring.svc.cluster.local:9090

...

## Kiali 화면과 연동 하기 위해서 ANONYMOUS 권한을 Viewer로 설정 한다.
env:
  - name: "GF_AUTH_ANONYMOUS_ENABLED"
    value: "true"
  - name: "GF_AUTH_ANONYMOUS_ORG_ROLE"
    value: "Viewer"
```

## Grafana Ingress 설정
- tls secret을 생성후 적용 한다.
```sh
cat <<EOF | kubectl -n monitoring apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana
spec:
  rules:
  - host: grafana.k3.acornsoft.io
    http:
      paths:
      - backend:
          service:
            name: grafana
            port:
              number: 3000
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - grafana.k3.acornsoft.io
    secretName: tls-acornsoft-star
EOF
```

## Grafana admin password 확인
```sh
kubectl -n monitoring get secret grafana -o go-template='{{range $k,$v := .data}}{{"### "}}{{$k}}{{"\n"}}{{$v|base64decode}}{{"\n\n"}}{{end}}'
```

## Grafana Dashboard 등록
- Istio Workload Dashboard 등록
  - Download JSON : https://grafana.com/grafana/dashboards/7630
- 

# 참조
> [Istio Workload Dashboard](https://grafana.com/grafana/dashboards/7630)