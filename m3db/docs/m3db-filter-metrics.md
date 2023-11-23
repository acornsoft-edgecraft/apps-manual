# Filter Metrics

일반 구성에서 모든 메트릭은 기본적으로 Prometheus 원격 쓰기에 원격으로 기록됩니다. 수집하고 M3db에 보내는 메트릭을 제어할 수 있습니다. 수집, 삭제 또는 교체할 시리즈 및 레이블을 선택하고 M3db로 전송되는 활성 시리즈 수를 줄이기 위해  섹션 write_relabel_configs 내 블록  을 사용하여 레이블 재지정 구성을 설정할 수 있습니다 
**write_relabel_configs** 샘플을 원격 엔드포인트로 보내기 전에 레이블을 다시 지정합니다. 쓰기 재레이블링은 외부 레이블 다음에 적용됩니다. 이것은 전송되는 샘플을 제한하는 데 사용할 수 있습니다.

- 샘플들

For example, you can send metrics from one specific namespace called myapp-ns as give below:
```yaml
remote_write:
- url: https://<region-url>/prometheus/remote/write
  write_relabel_configs:
  - source_labels: [__meta_kubernetes_namespace]
    regex: ‘myapp-ns’
    action: keep
```

샘플
```
- url: https://metric-api.newrelic.com/prometheus/v1/write?X-License-Key=...
  write_relabel_configs:
  - source_labels: [__name__]
    regex: ^my_counter$
    target_label: newrelic_metric_type
    replacement: "counter"
    action: replace
```
-----
# 참고
> [remote_write - 필터 메트릭](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#remote_write)
> [sysdig - 필터 메트릭](https://docs.sysdig.com/en/-beta--prometheus-remote-write.html)