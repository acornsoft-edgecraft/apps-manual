# Prometheus Getting Start

## Prometheus Architecture
![Prometheus Architecture](./images/prometheus-architecture.png)

## 사전준비
- Kubernetes 1.16+
- Helm 3+
- Get Repo Info
```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add kube-state-metrics https://kubernetes.github.io/kube-state-metrics
helm repo update
```

## Install Prometheus
```sh
helm upgrade prometheus -i \
  -n monitoring \
  --create-namespace \
  --cleanup-on-fail \
  --repo https://prometheus-community.github.io/helm-charts \
  prometheus \
  -f values.yaml
```

## Prometheus configuration
- values 수정
```yaml
## Define serviceAccount names for components. Defaults to component's fully qualified name.
##
serviceAccounts:
  ### true -> false
  pushgateway:
    create: false
    name:
    annotations: {}

...

  persistentVolume:
    ## If true, alertmanager will create/use a Persistent Volume Claim
    ## If false, use emptyDir
    ##
    ### true -> false
    enabled: false

...

  extraFlags:
    - web.enable-lifecycle
    ## web.enable-admin-api flag controls access to the administrative HTTP API which includes functionality such as
    ## deleting time series. This is disabled by default.
    # - web.enable-admin-api
    ##
    ## storage.tsdb.no-lockfile flag controls BD locking
    ### 주석 -> 주석 해제
    - storage.tsdb.no-lockfile
    ##
    ## storage.tsdb.wal-compression flag enables compression of the write-ahead log (WAL)
    ### 주석 -> 주석 해제
    - storage.tsdb.wal-compression

  global:
    ## How frequently to scrape targets by default
    ##
    ### 1m -> 15s
    scrape_interval: 15s

```

## Dependencies 
- By default this chart installs additional, dependent charts:
  - [stable/kube-state-metrics](https://github.com/helm/charts/tree/master/stable/kube-state-metrics)

# 참조
> [Prometheus Monitoring Community]([참조링크](https://github.com/prometheus-community/helm-charts))