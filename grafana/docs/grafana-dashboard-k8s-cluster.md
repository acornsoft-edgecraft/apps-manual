# Grafana Dashboard 생성

Follow these steps to get started with Grafana:
- 1. Grafana Installed
- 2. Prometheus Installed

## kubernetes-for-prometheus-dashboard
k8s cluster의 CPU / MEMORY / NETWORK 리소스 dashboard 이다.

## Persistance Volume metric 수식
I confirmed that Kubernetes 1.8 expose metrics for prometheus.

kubelet_volume_stats_available_bytes
kubelet_volume_stats_capacity_bytes
kubelet_volume_stats_inodes
kubelet_volume_stats_inodes_free
kubelet_volume_stats_inodes_used
kubelet_volume_stats_used_bytes

```sh
## 수식 

## pod/container ready 
kube_pod_container_status_ready{origin_prometheus=~".*",pod=~".*",container =~".*",namespace=~".*"} == 1



sum(irate(container_cpu_usage_seconds_total{origin_prometheus=~".*",pod=~".*",container =~".*",container !="",container!="POD",namespace=~".*"}[2m])) by (container, pod) / (sum(container_spec_cpu_quota{origin_prometheus=~".*",pod=~".*",container =~".*",container !="",container!="POD",namespace=~".*"}/100000) by (container, pod)) * 100

sum(irate(container_cpu_usage_seconds_total{origin_prometheus=~".*",pod=~".*",container =~".*",container !="",container!="POD",namespace=~".*"}[2m])) by (container, pod)

sum(kube_pod_container_resource_requests_cpu_cores{origin_prometheus=~".*",pod=~".*",container =~".*",namespace=~".*"}) by (container,pod)


sum(kube_pod_container_resource_limits_cpu_cores{origin_prometheus=~".*",pod=~".*",container =~".*",namespace=~".*"}) by (container,pod)


sum(container_memory_working_set_bytes{origin_prometheus=~".*",pod=~".*",container =~".*",container !="",container!="POD",namespace=~".*"}) by (container, pod)/ sum(container_spec_memory_limit_bytes{origin_prometheus=~".*",pod=~".*",container =~".*",container !="",container!="POD",namespace=~".*"}) by (container, pod) * 100

sum(container_memory_working_set_bytes{origin_prometheus=~".*",pod=~".*",container =~".*",container !="",container!="POD",namespace=~".*"}) by (container, pod)

sum (container_memory_rss{origin_prometheus=~".*",pod=~".*",container =~".*",container !="",container!="POD",namespace=~".*"}) by (container, pod)/ sum(container_spec_memory_limit_bytes{origin_prometheus=~".*",pod=~".*",container =~".*",container !="",container!="POD",namespace=~".*"}) by (container, pod) * 100

sum (container_memory_rss{origin_prometheus=~".*",pod=~".*",container =~".*",container !="",container!="POD",namespace=~".*"}) by (container, pod)

sum(kube_pod_container_resource_requests_memory_bytes{origin_prometheus=~".*",pod=~".*",container =~".*",namespace=~".*"}) by (container,pod)

sum(kube_pod_container_resource_limits_memory_bytes{origin_prometheus=~".*",pod=~".*",container =~".*",namespace=~".*"}) by (container,pod)


## persistance volume 수식
sum(container_fs_usage_bytes{origin_prometheus=~".*",pod=~".*",container =~".*",container !="",container!="POD",namespace=~".*"}) by (container,pod)

## 아래 수식과 병합 해서 pod 정보를 가져 온다.
kube_pod_spec_volumes_persistentvolumeclaims_info


kube_pod_container_status_restarts_total{origin_prometheus=~".*",pod=~".*",container =~".*",namespace=~".*"} - 0
```


# 참조
> [Istio Workload Dashboard](https://grafana.com/grafana/dashboards/7630)