# Documentation Index

## Overview

Prometheus는 시스템 및 서비스의 모니터링 및 경고를 위한 오픈 소스 솔루션으로, CNCF(Cloud Native Computing Foundation)의 일부 프로젝트 중 하나입니다. Prometheus는 특히 컨테이너 오케스트레이션 시스템인 Kubernetes와 함께 사용되어 클라우드 네이티브 환경에서의 모니터링을 지원합니다.

- Prometheus의 주요 특징과 기능은 다음과 같습니다:

1. 다차원 데이터 모델: Prometheus는 시계열 데이터를 다차원 데이터 모델로 저장합니다. 각 데이터 포인트는 여러 레이블을 가지며, 이를 통해 데이터를 쿼리하고 집계하는 유연성을 제공합니다.

2. 플러그형 컴포넌트: Exporter를 통해 다양한 시스템 및 서비스에서 메트릭을 수집할 수 있습니다. Exporter는 특정 시스템의 상태를 Prometheus가 이해할 수 있는 형태로 변환하는 역할을 합니다.

3. 스크래핑 (Scraping) 방식의 수집: Prometheus는 지정된 주기로 각각의 타깃에서 메트릭을 수집하는 스크래핑 방식을 사용합니다.

4. 알림 (Alerting) 및 경고: Prometheus는 특정 조건에 따라 경고를 생성하고 알림을 보낼 수 있는 기능을 제공합니다.

5. 시각화 및 대시보드: Prometheus 데이터를 시각적으로 표현하고 대시보드로 모니터링할 수 있는 도구들과 통합이 쉽습니다.

6. 지속적으로 증가하는 생태계: 다양한 Exporter, 클라이언트 라이브러리, 그래프 및 대시보드 도구 등 다양한 확장성을 제공하고 있는 생태계를 가지고 있습니다.

7. PromQL: Prometheus Query Language (PromQL)은 Prometheus에서 데이터를 쿼리하고 표현하는 데 사용되는 강력하고 표현력이 뛰어난 언어입니다.

Prometheus는 가벼우면서도 확장성이 뛰어나며, 클라우드 네이티브 환경에서 동작하는 여러 시스템 및 서비스의 모니터링을 간편하게 수행할 수 있도록 설계되었습니다. 많은 조직에서 Prometheus를 사용하여 시스템 및 서비스의 상태를 실시간으로 관찰하고 문제를 신속하게 식별하고 해결합니다.

## Usage
- [Prometheus Getting Start](./prometheus-getting-start.md)
- [Prometheus Installation with Helm](./prometheus-install-cli.md)