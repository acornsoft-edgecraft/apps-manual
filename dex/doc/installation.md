# dex 설치 및 GitLab 연동

## 1. Repository 등록
> ca.crt  다운로드 URL : https://regi.k3.acornsoft.io/ca.crt
```sh
helm repo add --ca-file ./ca.crt k3lab https://192.168.77.30/chartrepo/k3lab-charts
```

## 2. dex-values.yaml 정의
```yaml

............................

config:
  # Set it to a valid URL
  issuer: https://dex.k3.acornsoft.io/dex

  # See https://dexidp.io/docs/storage/ for more options
  # storage:
  #   type: memory
  storage:
    type: kubernetes
    config:
      inCluster: true

  # Enable at least one connector
  # See https://dexidp.io/docs/connectors/ for more options
  enablePasswordDB: true

  web:
    http: 0.0.0.0:5556

# Third Party Application 설정
  connectors:
    - type: gitlab
      id: gitlab
      name: GitLab
      config:
        baseURL: https://git.k3.acornsoft.io                                            # gitlab url 설정
        clientID: abc9d9061db64a77a8c45ecf315ac92557f6faf03248cb3995cd9232b72749ce      # gitlab applications 생성 후 application ID 등록(하위 이미지 참조)
        clientSecret: b076c80e5a1b6a15ecc2f174a963cdc9acd23a5b986ce3ee8f2a3587a21bc6f2  # gitlab applications 생성 후 secret ID 등록(하위 이미지 참조)
        redirectURI: https://dex.k3.acornsoft.io/dex/callback                           # gitlab applications 생성 후 callback url 등록(하위 이미지 참조)
        #groups:
        #- open
        useLoginAsID: false
    # - type: github
    #   id: github
    #   name: Github
    #   config:
    #     clientID: 12a6d94647d122abf193
    #     clientSecret: 2394e3a732fe4d9ecdc5717286937f9b13f26ef5
    #     redirectURI: https://dex.k3.acornsoft.io/dex/callback
    #     #groups:
    #     #- open
    #     useLoginAsID: false
    # - type: google
    #   id: google
    #   name: Google
    #   config:
    #     clientID: 968321444210-v8sd4e05lhmtdes5livublf2vrd4pr46.apps.googleusercontent.com
    #     clientSecret: X-u_fioJQ0f3tJL_LdAGuI-Q
    #     redirectURI: https://dex.k3.acornsoft.io/dex/callback
    #     #groups:
    #     #- open
    #     useLoginAsID: false

  oauth2:
    skipApprovalScreen: true

  # user & dex interface Clinet app
  staticClients:
  - id: example-app
    redirectURIs:
    - 'https://dex.k3.acornsoft.io/callback'
    name: 'Example App'
    secret: ZXhhbXBsZS1hcHAtc2VjcmV0

  staticPasswords:
  - email: "admin@example.com"
    # bcrypt hash of the string "password"
    hash: "$2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W"
    username: "admin"
    userID: "08a8684b-db88-4b73-90a9-3cd1661f5466"

............................

ingress:
  # -- Enable [ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/).
  enabled: true

  # -- Ingress [class name](https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-class).
  className: ""

  # -- Annotations to be added to the ingress.
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: 50000m

  # -- Ingress host configuration.
  # @default -- See [values.yaml](values.yaml).

  # ===========================Dex Server URL===========================
  # https://dex.k3.acornsoft.io/dex, https://dex.k3.acornsoft.io/dex/callback(gitlab에 정의된 callback url)

    # ===========================Dex Client URL===========================
  # https://dex.k3.acornsoft.io (Dex client login), https://dex.k3.acornsoft.io/callback(Dex Server에서 gitlab 콜백을 받은 후에 Dex client로 콜백해주는 URL)
  hosts:
    - host: dex.k3.acornsoft.io
      paths:
        - path: /dex
          pathType: Prefix
          fullName: dex
          svcPort: 5556
        - path: /
          pathType: Prefix
          fullName: kid
          svcPort: 5555

  # -- Ingress TLS configuration.
  # @default -- See [values.yaml](values.yaml).
  tls:
   - secretName: tls-acornsoft-star
     hosts:
       - dex.k3.acornsoft.io

# -- Container resource [requests and limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/).
# See the [API reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#resources) for details.
# @default -- No requests or limits.
resources:
  # We usually recommend not to specify default resources and to leave this as a conscious
  # choice for the user. This also increases chances charts run on environments with little
  # resources, such as Minikube. If you do want to specify resources, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi

............................

```

## 3. Dex Server 설치
```
$ helm upgrade -i dex k3lab/dex --cleanup-on-fail -f dex-values.yaml -n dex

$ kubectl get po -n dex
NAME                   READY   STATUS    RESTARTS   AGE
dex-5457448646-gsxkl   1/1     Running   0          52m

$ kubectl get svc -n dex
NAME   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
dex    ClusterIP   10.109.152.29   <none>        5556/TCP,5558/TCP   45h

$ kubectl get ing -n dex
NAME   CLASS    HOSTS                 ADDRESS        PORTS     AGE
dex    <none>   dex.k3.acornsoft.io   172.16.77.31   80, 443   45h

$ kubectl get secret -n dex
NAME                        TYPE                                  DATA   AGE
default-token-dxrtk         kubernetes.io/service-account-token   3      47h
dex                         Opaque                                1      45h
dex-token-dsqh6             kubernetes.io/service-account-token   3      45h
sh.helm.release.v1.dex.v1   helm.sh/release.v1                    1      45h
sh.helm.release.v1.dex.v2   helm.sh/release.v1                    1      44h
sh.helm.release.v1.dex.v3   helm.sh/release.v1                    1      43h
sh.helm.release.v1.dex.v4   helm.sh/release.v1                    1      43h
sh.helm.release.v1.dex.v5   helm.sh/release.v1                    1      43h
sh.helm.release.v1.dex.v6   helm.sh/release.v1                    1      25h
tls-acornsoft-star          kubernetes.io/tls                     2      47h


```

## 4. Dex 서버를 통한 GitLab 연동

### 4-1. GitLab 설정
> Dex Connector에서 사용될 GitLab Application 정보(ClientID 및 ClientSecret) 를 생성한다.
> 반듯이 Dex 서버 설치 이전에 미리 준비 한다.
> GitLab 로그인 후 Preferences > Applications > save application (api, openid 체크)

![jaeger-spans-traces](images/gitlabapplications.png)

> Application ID, Secret, Callback URL 정보를 dex-values.yaml connector > gitlab 정보에 등록 한다.

![jaeger-spans-traces](images/applicationsecret.png)

### 4-2. Dex & GitLab oidc 연동
> Dex Client 접속 (예: https://dex.k3.acornsoft.io/) 후 login 클릭
> Dex client 화면은 샘플 페이지 이며 추후 개발 필요함.

![jaeger-spans-traces](images/dexlogin.png)

> 설치 시 connectors 로 등록 된 Third Party Applications 목록 표시
> Log in With GitLab 클릭

![jaeger-spans-traces](images/dexconnectors.png)

> 자신의 Gitlab 계정으로 로그인 처리

![jaeger-spans-traces](images/gitlablogin.png)

> 계정 정보를 통해 승인 인증 처리

![jaeger-spans-traces](images/dexauthorize.png)

> Gitlab 사용 승인을 위한 Token 및 Claims 정보 전달을 통해 인증 처리 완료됨.

```sh
ID Token:

eyJhbGciOiJSUzI1NiIsImtpZCI6IjE0MWUzNTZmNGQ0MjBlZjM3MWJkNjMwZDk2N2JhODQyYzVlNzU5MTAifQ.eyJpc3MiOiJodHRwczovL2RleC5rMy5hY29ybnNvZnQuaW8vZGV4Iiwic3ViIjoiQ2dJeE5oSUdaMmwwYkdGaSIsImF1ZCI6ImV4YW1wbGUtYXBwIiwiZXhwIjoxNjI2NzQ5OTQ4LCJpYXQiOjE2MjY2NjM1NDgsImF0X2hhc2giOiJXM3A2bHZLLVVGb2xsU1FBUFgzaFpRIiwiY19oYXNoIjoiM1c2YUs2MUVWUHR5a3NST0t4WFliUSIsImVtYWlsIjoiampzc2lnNzdAYWNvcm5zb2Z0LmlvIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsIm5hbWUiOiLsoJXsp4DshJ0iLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJqanNzaWc3NyJ9.eLlJs8XQD_Fp851Y9hAd7NkQfEryOsYic7Zp6pflo70IDr5qzk2fvDbBd2X06dm6fCwBNlxRPC6JavT6WKgVlZaN_yJVubhdjanUn2brBy0FntpSKjQIsDgaD_2DHwPAECHyiqeIUjNVkdxyGcnHdj0J4FOIYahxIHUDP_TaPguxHh3ibf7fQLJzaj3VzLRo0D_bWvXW7xlgF7m1ZwUO2YKgSTEBYvGQtaiqBiEwb8F-t0suU8IP8QRE1kQyvJD01cKwHsx8vBvg9BCAoz7V5OCfChlRN22cuTx6Th8OZxdtAXBaW5tR-Q6RLhI_mBMLZMiwDfxU044AOHTRgJ8seg
Access Token:

eyJhbGciOiJSUzI1NiIsImtpZCI6IjE0MWUzNTZmNGQ0MjBlZjM3MWJkNjMwZDk2N2JhODQyYzVlNzU5MTAifQ.eyJpc3MiOiJodHRwczovL2RleC5rMy5hY29ybnNvZnQuaW8vZGV4Iiwic3ViIjoiQ2dJeE5oSUdaMmwwYkdGaSIsImF1ZCI6ImV4YW1wbGUtYXBwIiwiZXhwIjoxNjI2NzQ5OTQ4LCJpYXQiOjE2MjY2NjM1NDgsImF0X2hhc2giOiIxbEdZZU96M08zUlJieUZPVG1hSXJBIiwiZW1haWwiOiJqanNzaWc3N0BhY29ybnNvZnQuaW8iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwibmFtZSI6IuygleyngOyEnSIsInByZWZlcnJlZF91c2VybmFtZSI6Impqc3NpZzc3In0.SRYmSlVTwustayJw3CWjynL8J_pE0wUejenOminh061ENWaxJVL_r8MW0YEXoA_xs1FXyjae00tcpVHPHm550qtX-Qv0NCTD5n3NhRed2cE-QD-gGOyN4r2nFINNdki4RyyATEsac7WGvHay-j2oKGQu4niFWyUX3HSe-4ecfMfjl0bJAgDqRK9jBLmmatQwOjLIln23LkzNn7rr0YSl-Eqpp0OVwGu0NtU-ucMiQcrMCeeajS7JSFPHNZS18Z1ev559tJDMfQ5Dd_07id-bOIrL3gGRC1VZN6d1tAC5HHjcNqOclA1Y1jvPKxg90LM6VmzL1BZwQSOlBj-XkwqMTg
Claims:

{
  "iss": "https://dex.k3.acornsoft.io/dex",
  "sub": "CgIxNhIGZ2l0bGFi",
  "aud": "example-app",
  "exp": 1626749948,
  "iat": 1626663548,
  "at_hash": "W3p6lvK-UFollSQAPX3hZQ",
  "c_hash": "3W6aK61EVPtyksROKxXYbQ",
  "email": "jjssig77@acornsoft.io",
  "email_verified": true,
  "name": "정지석",
  "preferred_username": "jjssig77"
}
Refresh Token:

Chl2d3JsNGxkb2tzNmpzNm53N3g3ZzZwaWZtEhlxdWV1N2VvcnVuczJvdjNnbm5ibzVidnQ0
```

## 5. GitLab Token 및 Claims 정보를 kubernetes 와 연동
### 5-1 인증서 복사
```sh
# ingress 설정에 사용된 공인 인증서를 kube-apiserver 에서 dex 연동시 사용 할수 있도록 인증서를 복사 한다.

$ kubectl get secrk get secret tls-acornsoft-star -n dex -o jsonpath='{.data.tls\.crt}' | base64 --decode > /etc/kubernetes/pki/dex/ca.pem

```
### 5-2 Kubernetes API Server option 설정
> kubeapi-server.yaml oidc 옵션 추가
```sh

$ vi /etc/kubernetes/manifests/kube-apiserver.yaml

apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubeadm.kubernetes.io/kube-apiserver.advertise-address.endpoint: 172.16.77.31:6443
  creationTimestamp: null
  labels:
    component: kube-apiserver
    tier: control-plane
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-apiserver
    - --advertise-address=172.16.77.31

    ................................

    - --oidc-issuer-url=https://dex.k3.acornsoft.io/dex
    - --oidc-client-id=example-app
    - --oidc-ca-file=/etc/kubernetes/pki/dex/ca.pem
    - --oidc-username-claim=email
    - --oidc-groups-claim=groups

    ................................

    $ systemctl restart kubelet

    $ systemctl status kubelet

```

## 6. Dex Client 설치
> 추후에 chart로 개발 필요함.
```
# Dex Client에서 사용될 ca.pem 파일을 secret으로 생성 하기
$ kubectl create secret generic dex-k8s-app --from-file /etc/kubernetes/pki/dex/ca.pem

# dex-client.yaml에 Secret 설정 하기
.............................
      containers:
      - name: kid
        command: ["example-app", "--issuer", "https://dex.k3.acornsoft.io/dex","--listen", "http://0.0.0.0:5555",
        "--redirect-uri", "http://dex.k3.acornsoft.io/callback", "--issuer-root-ca", "/etc/secret/ca.pem"]
        image: 192.168.77.30/library/dex-example-app:latest
        ports:
        - containerPort: 5555
        volumeMounts:
        - name: dex-ca-secret
          mountPath: /etc/secret
      volumes:
      - name: dex-ca-secret
        secret:
          secretName: dex-k8s-app

$ kubectl apply -f dex/assets/dex-client.yaml -n dex

$ kubectl get po -n dex
NAME                   READY   STATUS    RESTARTS   AGE
dex-5457448646-gsxkl   1/1     Running   0          52m
kid-56b4959d75-225gd   1/1     Running   0          50m

$ kubectl get svc -n dex
NAME   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
dex    ClusterIP   10.109.152.29   <none>        5556/TCP,5558/TCP   45h
kid    ClusterIP   10.97.58.154    <none>        443/TCP             24h

```
## 7. Gitlab Token 정보를 통해 Kubernetes 인증 처리

### 7-1 Gitlab 계정 정보를 통해 Role,RoleBinding 적용
```sh
# dex/assets/dex-user-rback.yaml

apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  name: dexUser
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: dexUser
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: dexUser
subjects:
- kind: User
  name: jjssig77@acornsoft.io # Gitlab 계정 정보 입력
  namespace: default

$ kubectl apply -f dex-user-rback.yaml

```
### 7-2 credentials & context 생성
```sh

# gitlab 연동 후 callback 으로 받은 ID Token
$ export token=eyJhbGciOiJSUzI1NiIsImtpZCI6IjE0MWUzNTZmNGQ0MjBlZjM3MWJkNjMwZDk2N2JhODQyYzVlNzU5MTAifQ.eyJpc3MiOiJodHRwczovL2RleC5rMy5hY29ybnNvZnQuaW8vZGV4Iiwic3ViIjoiQ2dJeE5oSUdaMmwwYkdGaSIsImF1ZCI6ImV4YW1wbGUtYXBwIiwiZXhwIjoxNjI2NzQ5OTQ4LCJpYXQiOjE2MjY2NjM1NDgsImF0X2hhc2giOiJXM3A2bHZLLVVGb2xsU1FBUFgzaFpRIiwiY19oYXNoIjoiM1c2YUs2MUVWUHR5a3NST0t4WFliUSIsImVtYWlsIjoiampzc2lnNzdAYWNvcm5zb2Z0LmlvIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsIm5hbWUiOiLsoJXsp4DshJ0iLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJqanNzaWc3NyJ9.eLlJs8XQD_Fp851Y9hAd7NkQfEryOsYic7Zp6pflo70IDr5qzk2fvDbBd2X06dm6fCwBNlxRPC6JavT6WKgVlZaN_yJVubhdjanUn2brBy0FntpSKjQIsDgaD_2DHwPAECHyiqeIUjNVkdxyGcnHdj0J4FOIYahxIHUDP_TaPguxHh3ibf7fQLJzaj3VzLRo0D_bWvXW7xlgF7m1ZwUO2YKgSTEBYvGQtaiqBiEwb8F-t0suU8IP8QRE1kQyvJD01cKwHsx8vBvg9BCAoz7V5OCfChlRN22cuTx6Th8OZxdtAXBaW5tR-Q6RLhI_mBMLZMiwDfxU044AOHTRgJ8seg

$ kubectl config set-credentials dex-user-jjssig77 --auth-provider=oidc --auth-provider-arg=idp-issuer-url=https://dex.k3.acornsoft.io --auth-provider-arg=client-id=example-app --auth-provider-arg=id-token=${token}

$ kubectl config set-context dex-developer --cluster=kubernetes --namespace=default --user=dex-user-jjssig77

$ kubectl config get-contexts
CURRENT   NAME            CLUSTER         AUTHINFO            NAMESPACE
*         acloud-client   acloud-client   acloud-client
          dex-developer   kubernetes      dex-user-jjssig77   default

$ kubectl config use-context dex-developer
Switched to context "dex-developer".

$ k config get-contexts
CURRENT   NAME            CLUSTER         AUTHINFO            NAMESPACE
          acloud-client   acloud-client   acloud-client
*         dex-developer   kubernetes      dex-user-jjssig77   default

$ kubectl get pod
NAME                                READY   STATUS    RESTARTS   AGE
my-app-58cbb9b58d-rl2gr             1/1     Running   2          12d
nginx                               1/1     Running   0          7d1h
nginx-deployment-66b6c48dd5-l6czj   1/1     Running   2          12d
```



