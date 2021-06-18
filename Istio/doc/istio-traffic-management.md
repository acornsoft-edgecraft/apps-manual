# Istio Traffic Management

Istio의 트래픽 라우팅 규칙을 사용하면 서비스 간의 트래픽 흐름과 API 호출을 쉽게 제어 할 수 있다

Istio는 회로 차단기(circuit breakers), 시간 초과 및 재시도와 같은 서비스 수준 속성의 구성을 단순화하고 백분율 기반 트래픽 분할을 사용하여 **A / B 테스트, 카나리아 롤아웃 및 단계적 롤아웃**과 같은 중요한 작업을 쉽게 설정할 수 있도록합니다

또한 종속 서비스 또는 네트워크의 장애에 대해 애플리케이션을 더욱 강력하게 만드는 데 도움이되는 기본 제공 장애 복구 기능을 제공합니다.


## 구조
- Virtual services
  - 가상 서비스는 트래픽을 해당 워크로드로 전송하기위한 다양한 트래픽 라우팅 규칙을 지정하는 다양한 방법을 제공한다
- Destination rules
  - 대상 규칙을 사용 하여 해당 대상의 트래픽 에 발생하는 작업을 구성 할 수 있다.
- Gateways
  - Istio 게이트웨이를 사용하면 Istio 트래픽 라우팅의 모든 기능과 유연성을 사용할 수 있습니다
- Service entries
  - [서비스 항목](https://istio.io/latest/docs/reference/config/networking/service-entry/#ServiceEntry) 을 사용하여 Istio가 내부적으로 유지 관리하는 서비스 레지스트리에 항목 을 추가한다
- Sidecars
  - 기본적으로 Istio는 연결된 워크로드의 모든 포트에서 트래픽을 허용하고 트래픽을 전달할 때 메시의 모든 워크로드에 도달하도록 모든 Envoy 프록시를 구성한다.

## 

# 참조
> [Istio Gateway](https://istio.io/latest/docs/reference/config/networking/gateway/)
> [Istio Traffic Management](https://istio.io/latest/docs/concepts/traffic-management/)
> [Istio Service Entry](https://istio.io/latest/docs/reference/config/networking/service-entry/)