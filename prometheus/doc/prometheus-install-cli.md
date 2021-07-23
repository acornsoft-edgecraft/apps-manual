# Istio Install Cli

## 소제목

## onasis-centos-m3db 설치
```sh
helm upgrade prometheus -i \
  -n monitoring \
  --create-namespace \
  --cleanup-on-fail \
  --ca-file ./ca.crt \
  --repo http://192.168.77.128/chartrepo/k3lab-charts \
  prometheus \
  -f values-k3lab-live-m3db.yaml
```

# 참조
> [참조명](참조링크)