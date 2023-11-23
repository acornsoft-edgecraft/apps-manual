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

## kiali-cabundle아래에 루트 CA 인증서(공개 구성 요소)를 포함하는 이름의 ConfigMap을 만든다.
```yaml
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: kiali-cabundle
  namespace: monitoring # This is Kiali's install namespace
data:
  openid-server-ca.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCekNDQWUrZ0F3SUJBZ0lVSUc0VE5YdFdYVXkwcmswdC80SStUV3Z1N1RJd0RRWUpLb1pJaHZjTkFRRUwKQlFBd0VqRVFNQTRHQTFVRUF3d0hhM1ZpWlMxallUQWdGdzB5TVRBM01Ua3dOakkzTkRaYUdBOHlNVEl4TURZeQpOVEEyTWpjME5sb3dFakVRTUE0R0ExVUVBd3dIYTNWaVpTMWpZVENDQVNJd0RRWUpLb1pJaHZjTkFRRUJCUUFECmdnRVBBRENDQVFvQ2dnRUJBS1RhWkk3WDExQVJHQTVWc2c4M2txY3RmZG1qODlQbitYVkdWeFR0R3diWFZQOUsKdVgzM1RHZEQwMUVIenRSNjBSN0xhemtHNXplVWY2VHV5Ky8yVnpOeFVRNDZDcCttTEVxdTZWZ3NsKzFoUEp4awp5ekVSQk52K1I1dnRRRnU3aURycGlzMUFCb3BlYTUxT24xUnB0NjNtMkZ1VDBVUHhjMGFMRU5uMFp5TmZlK0lhCkoyRGNocmQ5MXFmZi9OKys5WXJubUJKZStNT3QyWnlIMklpNEI1dnBSU3BaNVNVbDRtUlhBaXloeU1pZEpmQzMKVnl1U1ZKd3haNmZZUlZxWkpoSmJLblFCaVA5Mmc0ZlFlRVc1QkszUzFqL3VwWTA5eTlnNDRjWGhFZG5CbTk0Swo0cjRXSkJMK1doOXBZb1FFRDdnb3FaUXpUVGN6K2hUTWhJWGtFbTBDQXdFQUFhTlRNRkV3SFFZRFZSME9CQllFCkZPdmowaHIwV25BbG05dU9oRURDNUEwZk9SR09NQjhHQTFVZEl3UVlNQmFBRk92ajBocjBXbkFsbTl1T2hFREMKNUEwZk9SR09NQThHQTFVZEV3RUIvd1FGTUFNQkFmOHdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBSlpsbmY0QgpZQllwMmtrcGVGaUF5QW1CVkpyaXJDamhUcE9JM2t4MDBLSDVsT3d4NUE0eDJYWGJ1MVNmNDBuVmNEWU1HbC9oCm81bHZVNytCU2JXTUQzNU81N0pTc3BHZWI4R0VKVmRJREM4WVFlUVhIYy9wT0FzVkJRZ04zMVFJVVpKUFpVUkYKZDFmR2F3R3ljWFBsa09DQjErZVJlN1djQ0lCNkpBSFJlcllDTzZJVnl4NHJHQ1dhRkRHREdmZlRsTld3OEpZbwpBWVhWU0V6ZGNtRDZIYnhxbjRYK3UydTFjZzFLejY5RmZrSm9lbWNHWmUySThMZ1ZDcjY4Y1JPeFF2dGNsQ3JSCnExNll5Sm5wTHJhN0tnNHVTZkt3SWNxSGhhZ09EdHNrZVVKeEkyOU1NYUVja09Lb0FZc3VaSDJlbVBES010S1EKdmFwemIreWRrTE5mVVowPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
EOF
```


-----
# 참조
> [OpenID Connect strategy](https://kiali.io/documentation/latest/configuration/authentication/openid/)
