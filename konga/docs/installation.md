## Konga 설치 방법

### 사전 준비

- 소스 다운로드 : git clone https://github.com/pantsel/konga.git
  - 다운로드 후 차트 구성 : helm package konga
- 직접 다운로드 : https://github.com/pantsel/konga/blob/master/charts/konga/konga-1.0.0.tgz
  - 다운로드 후 harbor를 통해 직접 업로드

### 1. Repository 등록
> ca.crt  다운로드 URL : https://regi.k3.acornsoft.io/ca.crt
```sh
helm repo add --ca-file ./ca.crt k3lab https://192.168.77.30/chartrepo/k3lab-charts
```

### 2. konga-values.yaml 정의
```yaml

............................

# Konga default configuration
config:
  port: 1337
  node_env: development
  # ssl_key_path: "/"
  # ssl_crt_path: "/"
  konga_hook_timeout: 60000
  db_adapter: postgres
  db_uri: kong-pgsql
  db_host: kong
  db_port: 5432
  db_user: konga
  db_password: konga
  db_database: kong
  db_pg_schema: public
  log_level: debug
  token_secret:

............................

# Ingress Configuration for Konga
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: 50000m
  hosts:
    - host: konga.k3.acornsoft.io
      paths: ["/"]
  tls:
    - secretName: tls-acornsoft-star
      hosts:
        - konga.k3.acornsoft.io

............................

```

### 3. konga 설치
```
$ helm upgrade -i konga k3lab/konga --cleanup-on-fail -f konga-values.yaml -n namespaces
```

