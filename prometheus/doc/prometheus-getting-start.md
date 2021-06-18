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
  - pushgateway 설치 안한다.
  - persistentVolume 테스트시 emptyDir 사용.
  - 프로메테우스 환경설정 추가 
    - storage.tsdb.no-lockfile (db locking 해제)
    - storage.tsdb.wal-compression (WAL 압축)
  - 메트릭 수집 주기 설정 (15초)
  - server:
    - service port를 9090으로 지정한다. (kiali에서 프로메테우스 url로 사용 된다.)
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
server:
  ## Prometheus server container name
  ##
  enabled: true

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

...

  service:
    annotations: {}
    labels: {}
    clusterIP: ""

    ## List of IP addresses at which the Prometheus server service is available
    ## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
    ##
    externalIPs: []

    loadBalancerIP: ""
    loadBalancerSourceRanges: []
    servicePort: 9090

```

## Prometheus Metrics configmap 설정
- values의 아래 위치에 추가 한다. 
  - serverFiles: > prometheus.yml: > scrape_configs: 
```yaml
## kube-state-metrics 설정
## service 주소를 targets 주소로 지정한다.
- job_name: 'kube-state-metrics'
        static_configs:
          - targets: ['kube-state-metrics.kube-system.svc.cluster.local:8080']
```


## Prometheus AlertManager Configuration
- value 설정
  - alerting_rules.yml:
```yaml
serverFiles:

  ## Alerts configuration
  ## Ref: https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/
  alerting_rules.yml:
  # groups:
  #   - name: Instances
  #     rules:
  #       - alert: InstanceDown
  #         expr: up == 0
  #         for: 5m
  #         labels:
  #           severity: page
  #         annotations:
  #           description: '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes.'
  #           summary: 'Instance {{ $labels.instance }} down'
  ## DEPRECATED DEFAULT VALUE, unless explicitly naming your files, please use alerting_rules.yml
  groups:
    - name: container memory alert
      rules:
      - alert: container memory usage rate is very high( > 55%)
        expr: sum(container_memory_working_set_bytes{pod!="", name=""})/ sum (kube_node_status_allocatable_memory_bytes) * 100 > 55
        for: 1m
        labels:
          severity: fatal
        annotations:
          summary: High Memory Usage on 
          identifier: ""
          description: " Memory Usage: "
    - name: container CPU alert
      rules:
      - alert: container CPU usage rate is very high( > 10%)
        expr: sum (rate (container_cpu_usage_seconds_total{pod!=""}[1m])) / sum (machine_cpu_cores) * 100 > 10
        for: 1m
        labels:
          severity: fatal
        annotations:
          summary: High Cpu Usage
  alerts: {}
```

## Dependencies 
- By default this chart installs additional, dependent charts:
  - [stable/kube-state-metrics](https://github.com/helm/charts/tree/master/stable/kube-state-metrics)

# 참조
> [Prometheus Monitoring Community]([참조링크](https://github.com/prometheus-community/helm-charts))