# dex - A federated OpenID Connect provider

## Dex 란 ?
- Dex는 OpenID Connect 를 사용 하여 다른 앱에 대한 인증을 구동 하는 ID 서비스입니다 .
- Dex는 "커넥터"를 통해 다른 ID 공급자에 대한 포털 역할을 합니다 .
- Dex는 LDAP 서버, SAML 공급자 또는 GitHub, Google 및 Active Directory와 같은 기존 ID 공급자에 대한 인증을 연기할 수 있습니다.
- 클라이언트는 dex와 통신하기 위해 인증 로직을 한 번 작성하면 dex가 지정된 백엔드에 대한 프로토콜을 처리합니다.

## ID TOKEN
ID 토큰은 OpenID Connect 및 dex의 주요 기능에 의해 도입된 OAuth2 확장입니다. ID 토큰은 dex로 서명된 JSON 웹 토큰 (JWT)이며 최종 사용자의 ID를 증명하는 OAuth2 응답의 일부로 반환됩니다. JWT의 예는 다음과 같습니다.

```sh
eyJhbGciOiJSUzI1NiIsImtpZCI6IjlkNDQ3NDFmNzczYjkzOGNmNjVkZDMyNjY4NWI4NjE4MGMzMjRkOTkifQ.eyJpc3MiOiJodHRwOi8vMTI3LjAuMC4xOjU1NTYvZGV4Iiwic3ViIjoiQ2djeU16UXlOelE1RWdabmFYUm9kV0kiLCJhdWQiOiJleGFtcGxlLWFwcCIsImV4cCI6MTQ5Mjg4MjA0MiwiaWF0IjoxNDkyNzk1NjQyLCJhdF9oYXNoIjoiYmk5NmdPWFpTaHZsV1l0YWw5RXFpdyIsImVtYWlsIjoiZXJpYy5jaGlhbmdAY29yZW9zLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJncm91cHMiOlsiYWRtaW5zIiwiZGV2ZWxvcGVycyJdLCJuYW1lIjoiRXJpYyBDaGlhbmcifQ.OhROPq_0eP-zsQRjg87KZ4wGkjiQGnTi5QuG877AdJDb3R2ZCOk2Vkf5SdP8cPyb3VMqL32G4hLDayniiv8f1_ZXAde0sKrayfQ10XAXFgZl_P1yilkLdknxn6nbhDRVllpWcB12ki9vmAxklAr0B1C4kr5nI3-BZLrFcUR5sQbxwJj4oW1OuG6jJCNGHXGNTBTNEaM28eD-9nhfBeuBTzzO7BKwPsojjj4C9ogU4JQhGvm_l4yfVi0boSx8c0FX3JsiB0yLa1ZdJVWVl9m90XmbWRSD85pNDQHcWZP9hR6CMgbvGkZsgjG32qeRwUL_eNkNowSBNWLrGNPoON1gMg
```

ID 토큰에는 사용자가 로그인한 클라이언트 앱, 토큰 만료 시기 및 사용자 ID를 증명하는 표준 클레임이 포함되어 있습니다.
```sh
# JWT Decoder
{
 alg: "RS256",
 kid: "9d44741f773b938cf65dd326685b86180c324d99"
}.
{
 iss: "http://127.0.0.1:5556/dex",
 sub: "CgcyMzQyNzQ5EgZnaXRodWI",
 aud: "example-app",
 exp: 1492882042,
 iat: 1492795642,
 at_hash: "bi96gOXZShvlWYtal9Eqiw",
 email: "eric.chiang@coreos.com",
 email_verified: true,
 groups: [
  "admins",
  "developers"
 ],
 name: "Eric Chiang"
}.
[signature]

```
이러한 토큰은 dex로 서명되고 표준 기반 클레임을 포함 하므로 다른 서비스에서 서비스 간 자격 증명으로 사용할 수 있습니다. dex에서 발행한 OpenID Connect ID 토큰을 이미 사용할 수 있는 시스템은 다음과 같습니다.
- Kubernetes
- AWS STS

## Kubernetes & Dex
Dex는 사용자 지정 리소스 정의를 사용하여 모든 Kubernetes 클러스터 위에서 기본적으로 실행되며 OpenID Connect 플러그인을 통해 API 서버 인증을 구동할 수 있습니다.

### 참조
> [Dex를 이용한 쿠버네티스 인증](https://dexidp.io/docs/kubernetes/)

## Connectors
"Connector"는 다른 ID 제공자에 대해 사용자를 인증하기 위해 dex에서 사용하는 전략입니다. Dex는 GitHub, LinkedIn, Microsoft와 같은 특정 플랫폼과 LDAP 및 SAML과 같은 기존 프로토콜을 대상으로 하는 커넥터를 구현합니다.

![jaeger-spans-traces](images/dex-flow.png)

![jaeger-spans-traces](images/dex-connectors.png)

# Keycloak

## Keycloak 이란?

Keycloak은 웹 앱 및 RESTful 웹 서비스를 위한 싱글 사인온 솔루션입니다. Keycloak의 목표는 보안을 단순하게 만들어 애플리케이션 개발자가 조직에 배포한 앱과 서비스를 쉽게 보호할 수 있도록 하는 것입니다. 일반적으로 개발자가 스스로 작성해야 하는 보안 기능은 기본적으로 제공되며 조직의 개별 요구 사항에 쉽게 맞출 수 있습니다. Keycloak은 로그인, 등록, 관리 및 계정 관리를 위한 사용자 정의 가능한 사용자 인터페이스를 제공합니다. Keycloak을 통합 플랫폼으로 사용하여 기존 LDAP 및 Active Directory 서버에 연결할 수도 있습니다. Facebook 및 Google과 같은 타사 ID 제공업체에 인증을 위임할 수도 있습니다.

## 아키텍처
![jaeger-spans-traces](images/keycloak.png)

## 주요기능

- 브라우저 애플리케이션용 싱글 사인온 및 싱글 사인아웃.

- OpenID 연결 지원.

- OAuth 2.0 지원.

- SAML 지원.

- ID 중개 - 외부 OpenID Connect 또는 SAML ID 제공자를 통해 인증합니다.

- 소셜 로그인 - Google, GitHub, Facebook, Twitter 및 기타 소셜 네트워크로 로그인할 수 있습니다.

- 사용자 연합 - LDAP 및 Active Directory 서버에서 사용자를 동기화합니다.
    - Dex는 LDAP 서버 인증을 위한 LDAP 커넥터를 지원합니다. Keycloak은 한 단계 더 나아가 LDAP 사용자 및 그룹을 로컬로 동기화하여 인증을 수행할 수 있습니다.

- Kerberos 브리지 - Kerberos 서버에 로그인한 사용자를 자동으로 인증합니다.

- SPI(서비스 제공자 인터페이스) - 서버의 다양한 측면을 사용자 지정할 수 있는 여러 SPI입니다

  - 사용자, 역할, 역할 매핑, 클라이언트 및 구성을 중앙에서 관리하기 위한 관리 콘솔
  - Dex는 몇 가지 비표준 클레임을 제공 하지만 실제로 사용자 지정되지는 않으나,
    Keycloak을 사용하면 사용자 속성에 모든 키/값을 입력하고 사용자 토큰에 사용자 지정 클레임을 포함할 수 있습니다.

  - Keycloak은 로컬에 사용자 데이터베이스를 가지고 있기 때문에 권한 부여를 위한 역할도 설정할 수 있습니다.

- 테마 지원 - 모든 사용자 대면 페이지를 사용자 정의하여 애플리케이션 및 브랜딩과 통합합니다.

- 이중 인증 - Google Authenticator 또는 FreeOTP를 통한 TOTP/HOTP 지원.
  - Keycloak은 TOTP를 지원하여 다양한 OTP 제공업체에 연결합니다.

- 로그인 흐름 - 선택적 사용자 자체 등록, 비밀번호 복구, 이메일 확인, 비밀번호 업데이트 필요 등
  - Keycloak은 OIDC 클라이언트별로 다른 인증 흐름을 설정할 수 있는 사용자 지정 인증 흐름을 지원합니다.

- 세션 관리 - 관리자와 사용자가 직접 사용자 세션을 보고 관리할 수 있습니다.

- 토큰 매퍼 - 사용자 속성, 역할 등을 원하는 방식으로 토큰과 명령문에 매핑합니다.

- 영역, 응용 프로그램 및 사용자에 대한 이전 취소 정책.

- CORS 지원 - 클라이언트 어댑터에는 CORS에 대한 기본 제공 지원이 있습니다.

- JavaScript 애플리케이션용 클라이언트 어댑터, WildFly, JBoss EAP, Fuse, Tomcat, Jetty, Spring 등

- OpenID Connect 신뢰 당사자 라이브러리 또는 SAML 2.0 서비스 공급자 라이브러리가 있는 모든 플랫폼/언어를 지원합니다.

- REST API
  - Dex에는 gRPC API만 있습니다. Keycloak은 문서화된 참조 페이지로 REST API 를지원합니다.

- Web UI
  - Keycloak은 Web UI를 통해 관리됩니다

- 내장 이벤트 로그
  - Keycloak에는 웹 UI에 표시되는 내장 이벤트 로그가 있어 감사 및 문제 해결에 적합 합니다.

- Realm
  - Keycloak의 Realm 기능을 사용하면 관리자가 격리된 OIDC 가상 컨텍스트를 만들 수 있습니다. 다른 백엔드 인증으로 OIDC 서비스를 동시에 제공할 수 있습니다.

- 테마
  - Web UI의 테마는 자신의 페이지로 변경할 수 있습니다.


