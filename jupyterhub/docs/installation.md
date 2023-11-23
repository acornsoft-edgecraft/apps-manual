
## JupyterHub 설치 방법

### 1. Repository 등록
> ca.crt  다운로드 URL : https://regi.k3.acornsoft.io/ca.crt
```sh
$ helm repo add --ca-file ./ca.crt k3lab https://192.168.77.30/chartrepo/k3lab-charts
```

### 2. proxy secretToken 생성
```sh
$ openssl rand -hex 32

071b792a79cbb9aab32b8952191163bde3917fdc7f66f18c96851ce264303dec
```

### 3. jupyterhub-values.yaml 정의
```yaml
...........

# proxy relates to the proxy pod, the proxy-public service, and the autohttps
# pod and proxy-http service.
proxy:
  secretToken: '071b792a79cbb9aab32b8952191163bde3917fdc7f66f18c96851ce264303dec' # proxy secretToken
  annotations: {}
  deploymentStrategy:

...........

ingress:
  enabled: true
  annotations: {}
  hosts: ["jh.k3.acornsoft.io"]
  pathSuffix: ''
  tls:
    - secretName: tls-acornsoft-star
      hosts:
        - jh.k3.acornsoft.io

...........

```

### 4. jupyterhub 설치
```sh
$ helm upgrade -i jupyterhub k3lab/jupyterhub --cleanup-on-fail -f jupyterhub-values.yaml -n jupyterhub
```

### 5. jupyterhub 접속
- URL : https://jh.k3.acornsoft.io
- ID : admin
- PWD : admin

