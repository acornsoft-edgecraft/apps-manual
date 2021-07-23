# Kiali OIDC

## Set-up with RBAC support
- create secret
```sh
## $NAMESPACE는 Kiali를 설치한 네임스페이스
## $CLIENT_SECRET는 OpenId 서버에서 구성하거나 제공한 secret

kubectl create secret generic kiali --from-literal="oidc-secret=$CLIENT_SECRET" -n $NAMESPACE
```

- OpenID Connect 전략을 활성화하기 위해 Kiali CR에서 설정
```yaml
spec:
  auth:
    strategy: openid
    openid:
      client_id: "kiali-client"
      issuer_uri: "https://openid.issuer.com"
```
> 참고:
> 여기에서는 Kubernetes 클러스터가 OpenID Connect 통합으로 구성되어 있다고 가정합니다. 
> 이 경우 client-id및 issuer_uri속성은 클러스터 API 서버를 시작하는 데 사용되는--oidc-client-id 및 --oidc-issuer-url플래그 와 일치해야 합니다. 
> 이 값이 일치하지 않으면 사용자가 Kiali에 로그인하지 못합니다.



-----
# 참조
> [OpenID Connect strategy](https://kiali.io/documentation/latest/configuration/authentication/openid/)
