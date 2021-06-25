## EFK 설치 방법

### 1. 인증서 생성 및 secret 설정
```sh
# work path : onassis/opendistro EK/certification

# openssl.cnf 변경
  alt_names_kb: Ingress에 사용할 domainname, 해당 domainname에 매치되는 IP 등록
  alt_names_es: Ingress에 사용할 domainname, 해당 domainname에 매치되는 IP 등록

# 인증서 생성

  # Root CA
  openssl genrsa -out ca.key 2048
  openssl req -x509 -new -sha256 -nodes -key ca.key -days 36500 -subj "/CN=RootCA" -out ca.crt -extensions v3_ca -config ./openssl.cnf

  # Admin Cert
  openssl genrsa -out admin.key.temp 2048
  openssl pkcs8 -inform PEM -outform PEM -in admin.key.temp -topk8 -nocrypt -v1 PBE-SHA1-3DES -out admin.key

  openssl req -new -key admin.key -out admin.csr -subj "/CN=admin" -config ./openssl.cnf
  openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -CAcreateserial -sha256 -out admin.crt -days 36500 -extensions v3_req_client -extfile ./openssl.cnf

  # Node Cert
  openssl genrsa -out node.key.temp 2048
  openssl pkcs8 -inform PEM -outform PEM -in node.key.temp -topk8 -nocrypt -v1 PBE-SHA1-3DES -out node.key

  openssl req -new -key node.key -out node.csr -subj "/CN=node" -config ./openssl.cnf
  openssl x509 -req -in node.csr -CA ca.crt -CAkey ca.key -CAcreateserial -sha256 -out node.crt -days 36500 -extensions v3_req_es -extfile ./openssl.cnf

  # Kibana Cert
  openssl genrsa -out kibana.key.temp 2048
  openssl pkcs8 -inform PEM -outform PEM -in kibana.key.temp -topk8 -nocrypt -v1 PBE-SHA1-3DES -out kibana.key

  openssl req -new -key kibana.key -out kibana.csr -subj "/CN=kibana" -config ./openssl.cnf
  openssl x509 -req -in kibana.csr -CA ca.crt -CAkey ca.key -CAcreateserial -sha256 -out kibana.crt -days 36500 -extensions v3_req_kb -extfile ./openssl.cnf


# secret 설정

  # Elasticsearch cert
    ca.crt:     CA 인증서
    node.crt:   ES 노드용 인증서
    node.key:   ES 노드용 개인키
    admin.crt:  Admin용 인증서
    admin.key:  Admin용 개인키
    tls.crt:    Web용 인증서(node.crt와 동일)
    tls.key:    Web용 개인키(node.key와 동일)

    sed -i "" "s/ca.crt:/ca.crt: $(cat ca.crt | base64)/g" ../install-yaml/elasticsearch.yaml
    sed -i "" "s/node.crt:/node.crt: $(cat node.crt ca.crt | base64)/g" ../install-yaml/elasticsearch.yaml
    sed -i "" "s/node.key:/node.key: $(cat node.key | base64)/g" ../install-yaml/elasticsearch.yaml
    sed -i "" "s/admin.crt:/admin.crt: $(cat admin.crt ca.crt | base64)/g" ../install-yaml/elasticsearch.yaml
    sed -i "" "s/admin.key:/admin.key: $(cat admin.key | base64)/g" ../install-yaml/elasticsearch.yaml
    sed -i "" "s/tls.crt:/tls.crt: $(cat node.crt ca.crt | base64)/g" ../install-yaml/elasticsearch.yaml
    sed -i "" "s/tls.key:/tls.key: $(cat node.key | base64)/g" ../install-yaml/elasticsearch.yaml

  # Kibana cert
    ca.crt:     CA 인증서
    kibana.crt: ES 접속용 인증서
    kibana.key: ES 접속용 개인키
    tls.crt:    Web용 인증서(공인 인증서 이용)
    tls.key:    Web용 개인키(공인 인증서 이용)

    sed -i "" "s/ca.crt:/ca.crt: $(cat ca.crt | base64)/g" ../install-yaml/kibana.yaml
    sed -i "" "s/kibana.crt:/kibana.crt: $(cat kibana.crt ca.crt | base64)/g" ../install-yaml/kibana.yaml
    sed -i "" "s/kibana.key:/kibana.key: $(cat kibana.key | base64)/g" ../install-yaml/kibana.yaml
    sed -i "" "s/tls.crt:/tls.crt: $(cat k3lab-star-tls.crt | base64)/g" ../install-yaml/kibana.yaml
    sed -i "" "s/tls.key:/tls.key: $(cat k3lab-star-tls.key | base64)/g" ../install-yaml/kibana.yaml

  # Fluentbit cert
    ca.crt:     CA 인증서
    sed -i "" "s/ca.crt:/ca.crt: $(cat ca.crt | base64)/g" ../install-yaml/fluentbit.yaml

# auto script
$ ./certification.sh

```


### 2. kibana ingress 설정
```yaml

# work file : install-yaml/kibana.yaml

...........

  apiVersion: networking.k8s.io/v1beta1
  kind: Ingress
  metadata:
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    labels:
      app: kibana
    name: kibana
    namespace: monitoring
  spec:
    rules:
    - host: "kb.k3.acornsoft.io"
      http:
        paths:
        - backend:
            serviceName: kibana
            servicePort: https
          path: /
    tls:
    - hosts:
      - "kb.k3.acornsoft.io"
      secretName: kibana

...........

```

### 3. efk 설치
```sh
  $ kubectl apply -f elasticsearch.yaml

  $ kubectl apply -f kibana.yaml

  $ kubectl apply -f fluentbit.yaml

```