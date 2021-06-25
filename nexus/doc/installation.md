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
- url : https://nexus.k3.acornsoft.io
- id  : admin
- pwd : @c0rns0ft@@

![jaeger-spans-traces](images/login.png)


### 5. 사용자 생성
- 위치 : Configration > Security > Users > Create local user 
- 계정 정보 입력

![jaeger-spans-traces](images/user.png)

### 6. Repository 생성
- 위치 : Configration > Repository > Repositories > Create repository
- pypi(hosted) repository 구성 정보 입력

![jaeger-spans-traces](images/repository.png)

### 7. package download for pip
- 필요한 패키지명을 requirements.txt 생성한다.

```
$ pip download --dest packages --prefer-binary -r requirements.txt
```
> https://hugovk.github.io/top-pypi-packages/

### 8. Packages Upload

### 9. package download for Nexus