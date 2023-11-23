# Helm Chart for Harbor

> [참고] https://1week.tistory.com/36

**Notes:** The master branch is in heavy development, please use the other stable versions instead. A highly available solution for Harbor based on chart can be found [here](docs/High%20Availability.md). And refer to the [guide](docs/Upgrade.md) to upgrade the existing deployment.

## Prerequisites

- Kubernetes cluster 1.20+
- Helm v3.2.0+

## Installation using Helm-chart

### Add Helm repository and Download charts
```sh
## step-1. Add chart repository
$ 
$ helm repo add harbor https://helm.goharbor.io
$ helm repo update
$ helm search repo harbor

# download charts
## Usage:
##  helm pull [chart URL | repo/chartname] [...] [flags]
$ VERSION="1.12.2"
$ helm pull harbor/harbor --untar -d ./assets --version ${VERSION}
```

### Installataion

```sh
## step-1. install using helm
### Usage:
###   helm upgrade [RELEASE] [CHART] [flags]
# helm upgrade harbor kore/harbor \
helm upgrade harbor ./assets/harbor \
    --install \
    --reset-values \
    --atomic \
    --no-hooks \
    --create-namespace \
    --kubeconfig ${KUBECONFIG} \
    --namespace ${NAMESPACE} \
    --values ${CHART_VALUES} \
    --version ${VERSION}
```

### Configuration

- storageClass 설정
```sh
## step-1. storageClass 설정
...
persistence:
  enabled: true
  # Setting it to "keep" to avoid removing PVCs during a helm delete
  # operation. Leaving it empty will delete PVCs after the chart deleted
  # (this does not apply for PVCs that are created for internal database
  # and redis components, i.e. they are never deleted automatically)
  resourcePolicy: "keep"
  persistentVolumeClaim:
    registry:
      # Use the existing PVC which must be created manually before bound,
      # and specify the "subPath" if the PVC is shared with other components
      existingClaim: ""
      # Specify the "storageClass" used to provision the volume. Or the default
      # StorageClass will be used (the default).
      # Set it to "-" to disable dynamic provisioning
      storageClass: "nfs-csi"
      subPath: "registry"
      accessMode: ReadWriteOnce
      size: 5Gi
      annotations: {}
    jobservice:
      jobLog:
        existingClaim: ""
        storageClass: "nfs-csi"
        subPath: "jobservice"
        accessMode: ReadWriteOnce
        size: 1Gi
        annotations: {}
    # If external database is used, the following settings for database will
    # be ignored
    database:
      existingClaim: ""
      storageClass: "nfs-csi"
      subPath: "database"
      accessMode: ReadWriteOnce
      size: 1Gi
      annotations: {}
    # If external Redis is used, the following settings for Redis will
    # be ignored
    redis:
      existingClaim: ""
      storageClass: "nfs-csi"
      subPath: "redis"
      accessMode: ReadWriteOnce
      size: 1Gi
      annotations: {}
    trivy:
      existingClaim: ""
      storageClass: "nfs-csi"
      subPath: "trivy"
      accessMode: ReadWriteOnce
      size: 5Gi
      annotations: {}
```

- Service Configuration for nodePort
```sh
## expose.type을 nodePort로 변경
## tls.auto.commonName 값을 필수로 인증에 주가되는 도메인 또는 IP 값을 넣는다.
## commonName 값은 externalURL 값과 일치해서 사용 된다.
expose:
  # Set how to expose the service. Set the type as "ingress", "clusterIP", "nodePort" or "loadBalancer"
  # and fill the information in the corresponding section
  type: nodePort
    tls:
    # Enable TLS or not.
    # Delete the "ssl-redirect" annotations in "expose.ingress.annotations" when TLS is disabled and "expose.type" is "ingress"
    # Note: if the "expose.type" is "ingress" and TLS is disabled,
    # the port must be included in the command when pulling/pushing images.
    # Refer to https://github.com/goharbor/harbor/issues/5291 for details.
    enabled: true
    # The source of the tls certificate. Set as "auto", "secret"
    # or "none" and fill the information in the corresponding section
    # 1) auto: generate the tls certificate automatically
    # 2) secret: read the tls certificate from the specified secret.
    # The tls certificate can be generated manually or by cert manager
    # 3) none: configure no tls certificate for the ingress. If the default
    # tls certificate is configured in the ingress controller, choose this option
    certSource: auto
    auto:
      # The common name used to generate the certificate, it's necessary
      # when the type isn't "ingress"
      commonName: "core.harbor.domain"
  ...

  ## 서비스 nodePort 설정
  nodePort:
    # The name of NodePort service
    name: harbor
    ports:
      http:
        # The service port Harbor listens on when serving HTTP
        port: 80
        # The node port Harbor listens on when serving HTTP
        nodePort: 31002
      https:
        # The service port Harbor listens on when serving HTTPS
        port: 443
        # The node port Harbor listens on when serving HTTPS
        nodePort: 31003
      # Only needed when notary.enabled is set to true
      notary:
        # The service port Notary listens on
        port: 4443
        # The node port Notary listens on
        nodePort: 31004
  ...

  ## externalURL 값을 변경
  ## nodePort값을 추가해서 넣어준다.
  externalURL: https://core.harbor.domain:31003
```

- Harbor에서 사용할 Certificate가 있는 경우는 아래와 같이 적용한다.
```bash
## step-1. openssl.conf 설정
$ vi openssl.conf
[ req ]
distinguished_name = req_distinguished_name
[req_distinguished_name]

[ v3_ca ]
basicConstraints = critical, CA:TRUE
keyUsage = critical, digitalSignature, keyEncipherment, keyCertSign

[ v3_req_client ]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth

[ v3_req_server ]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names_registry

[ alt_names_registry ]
DNS.1 = localhost
DNS.2 = {{ nodename }}
DNS.3 = {{ registry_domain }}
IP.1 = 127.0.0.1
IP.2 = {{ registry_ip }}

## step-2. 인증서 생성
## 인증기간 36500
$ openssl genrsa -out ./ca.key 2048
$ openssl req -x509 -new -nodes -key ./ca.key -days 36500 -out ./ca.crt -subj '/CN=harbor-ca' -extensions v3_ca -config ./openssl.conf
$ openssl genrsa -out ./harbor.key 2048
$ openssl req -new -key ./harbor.key -subj '/CN=harbor' | openssl x509 -req -CA ./ca.crt -CAkey ./ca.key -CAcreateserial -out ./harbor.crt -days 36500 -extensions v3_req_server -extfile ./openssl.conf

## step-3. 인증서 secret 생성
$ kubectl -n harbor create secret generic edgecraft-certificate \
  --from-file=tls.crt=./harbor.crt \
  --from-file=tls.key=./harbor.key  \
  --from-file=ca.crt=./ca.crt

## step-4. 인증성 적용
## service.tls.existingSecret 값에 생성한 secret 이름을 넣어준다.
helm upgrade harbor ./assets/harbor \
    --install \
    --reset-values \
    --atomic \
    --no-hooks \
    --create-namespace \
    --kubeconfig ${KUBECONFIG} \
    --namespace ${NAMESPACE} \
    --version ${VERSION} \
    --set service.type=NodePort \
    --set service.nodePorts.https=32443 \
    --set harborAdminPassword=admin**** \
    --set service.tls.existingSecret=edgecraft-certificate \
    --set externalURL=https://gsd.kt.co.kr:32443
```