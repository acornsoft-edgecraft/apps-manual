# Kiali Install Cli

## 소제목

## dex kiali cr
```yaml
spec:
  auth:
    openid:
      client_id: example-app
      issuer_uri: https://dex.k3.acornsoft.io/dex
      scopes:
      - openid
      - profile
      - email
      - groups
      username_claim: email
    strategy: openid

```


## keclock kiali cr
```yaml
spec:
  auth:
    openid:
      client_id: kiali-client
      disable_rbac: true
      issuer_uri: http://192.168.77.149/auth/realms/k3lab
      scopes:
      - openid
      username_claim: sub
    strategy: openid
```

```yaml
connectors:
- config:
    baseURL: https://git.k3.acornsoft.io
    clientID: abc9d9061db64a77a8c45ecf315ac92557f6faf03248cb3995cd9232b72749ce
    clientSecret: b076c80e5a1b6a15ecc2f174a963cdc9acd23a5b986ce3ee8f2a3587a21bc6f2
    redirectURI: https://dex.k3.acornsoft.io/dex/callback
    useLoginAsID: false
  id: gitlab
  name: GitLab
  type: gitlab
enablePasswordDB: true
issuer: https://dex.k3.acornsoft.io/dex
oauth2:
  skipApprovalScreen: true
staticClients:
- id: example-app
  name: Example App
  redirectURIs:
  - https://dex.k3.acornsoft.io/callback
  - https://kiali.k3.acornsoft.io/kiali
  secret: ZXhhbXBsZS1hcHAtc2VjcmV0
staticPasswords:
- email: admin@example.com
  hash: $2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W
  userID: 08a8684b-db88-4b73-90a9-3cd1661f5466
  username: admin
- email: dongmook@acornsoft.io
  hash: $2b$10$LQmcTIkX/KgXb5oJHJIyVeWPqYdSARkucPDp9RirymxAVr07u04kq
  userID: 08a8684b-db68-4b73-90a9-3cd1672f5466
  username: dongmook
storage:
  config:
    inCluster: true
  type: kubernetes
web:
  http: 0.0.0.0:5556
```


# 참조
> [참조명](참조링크)