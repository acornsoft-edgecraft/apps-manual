## Zabbix 설치 방법

### 1. Repository 등록
> ca.crt  다운로드 URL : https://regi.k3.acornsoft.io/ca.crt
```sh
helm repo add --ca-file ./ca.crt k3lab https://192.168.77.30/chartrepo/k3lab-charts
```

### 2. zabbix-values.yaml 정의
```yaml
# Default values for zabbix.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

# **Zabbix server** configurations
zabbixServer:
...........

  service:
    # -- Type of service in Kubernetes cluster
    type: NodePort
    # -- Port of service in Kubernetes cluster
    port: 10051

  # -- cachesize -> 장비 수량에 비례
  ZBX_CACHESIZE: 5G

...........

# Ingress configurations
ingress:
  # -- Enables Ingress
  enabled: true
  # -- Ingress annotations
  annotations: {}
  # -- Ingress hosts
  hosts:
    - host: zbx.k3.acornsoft.io
      paths: [/]
  # -- Ingress TLS configuration
  tls:
    - secretName: tls-acornsoft-star
      hosts:
        - zbx.k3.acornsoft.io

...........

```

### 3. zabbix Server 설치
```sh
$ helm upgrade -i zabbix k3lab/zabbix --cleanup-on-fail -f zabbix-values.yaml -n namespaces
```

### 4. zabbix Agent 설치
```sh
$ yum install zabbix-agent

============================================================
 Package                   Architecture           Version           Repository           Size
============================================================
Installing:
 zabbix-agent               x86_64               5.0.1-1.el8         zabbix              454 k

Transaction Summary
============================================================
```

### 5. zabbix Agent 설정
```sh
$ vi /etc/zabbix/zabbix_agentd.conf

Server=192.168.232.128                             [Zabbix Server의 IP 또는 호스트 이름]
ServerActive=127.0.0.1                             [Zabbix Server IP, PORT]
Hostname=127.0.0.1                                 [Agent 설치 서버의 IP 또는 호스트 이름]

```

### 6. zabbix Agent 서비스 구동
```sh
$ systemctl enable zabbix-agent                          [부팅 시 자동 활성화]

$ systemctl start zabbix-agent                           [서비스 구동]

$ systemctl status zabbix-agent                          [서비스 상태 확인]

```

### 7. Zabbix 접속
- URL : https://zbx.k3.acornsoft.io/index.php
- ID :
- PWD :

