## Nexus 설치 방법

### 1. Repository 등록
> ca.crt  다운로드 URL : https://regi.k3.acornsoft.io/ca.crt
```sh
helm repo add --ca-file ./ca.crt k3lab https://192.168.77.30/chartrepo/k3lab-charts
```

### 2. nexus-values.yaml 정의
```yaml

.......................

ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/proxy-body-size: "5G"
  hostPath: /
  hostRepo: nexus.k3.acornsoft.io
  tls:
    - secretName: tls-acornsoft-star
      hosts:
        - nexus.k3.acornsoft.io

.......................

```

### 3. nexus 설치
```
$ helm upgrade -i nexus k3lab/nexus-repository-manager --cleanup-on-fail -f nexus-values.yaml -n namespaces
```

### 4. nexus 접속
```

```

### 5. 사용자 생성
```

```

### 6. Repository 생성
```

```