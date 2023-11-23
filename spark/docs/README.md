# Documentation Index

## Overview

Apache Spark는 분산 처리를 위한 오픈 소스 클러스터 컴퓨팅 프레임워크로, 빅데이터 처리 및 분석을 위해 설계되었습니다. Spark는 대규모 데이터 세트를 처리하고 여러 머신에서 병렬로 작업을 수행할 수 있는 높은 성능과 유연성을 제공합니다. 아파치 소프트웨어 재단에서 개발되었으며, 많은 기업 및 프로젝트에서 사용되고 있습니다.

- Spark의 주요 특징과 기능:

1. 다양한 언어 지원: Spark는 Scala, Java, Python 및 R과 같은 다양한 언어를 지원하므로 다양한 프로그래밍 언어로 작성된 애플리케이션을 효율적으로 실행할 수 있습니다.

2. 분산 데이터 처리: 데이터를 클러스터에서 분산하여 처리하므로 대규모 데이터 세트의 처리가 가능하며, 높은 성능을 제공합니다.

3. Resilient Distributed Datasets (RDDs): Spark는 RDDs라는 불변성을 가진 분산 데이터 컬렉션을 사용하여 데이터 처리를 구현합니다. RDDs는 여러 단계에서의 장애 복구를 제공하므로 데이터 손실을 방지합니다.

4. 다양한 라이브러리 및 프레임워크 지원: Spark는 머신 러닝 라이브러리인 MLlib, 그래프 처리 프레임워크인 GraphX, 스트림 처리를 위한 Spark Streaming 등 다양한 라이브러리와 프레임워크를 제공합니다.

5. 인메모리 처리: Spark는 데이터를 메모리에 저장하고 빠르게 액세스함으로써 디스크에 대한 입출력을 줄여 성능을 향상시킵니다.

6. 클러스터 관리: Spark는 스탠드얼론 모드나 Apache Mesos, Hadoop YARN과 같은 클러스터 관리 시스템을 통해 클러스터를 효과적으로 관리합니다.

7. SQL 쿼리 지원: Spark는 SQL 쿼리를 통해 구조화된 데이터를 처리할 수 있습니다. Spark SQL을 사용하여 데이터프레임을 이용한 SQL 쿼리를 수행할 수 있습니다.

8. 커뮤니티 및 생태계: Spark는 활발한 커뮤니티와 다양한 생태계를 가지고 있어, 다양한 문제에 대한 솔루션을 찾을 수 있습니다.

Apache Spark는 데이터 처리 및 분석의 다양한 요구에 대응하며, 빅데이터 환경에서 효과적으로 사용되는 강력한 프레임워크입니다.

## Usage
- [Spark Architecture](./spark-architecture.md)
- [Spark Getting Start](./stand-alone-cluster.md)
- [Spark on kubernetes](./kubernetes-cluster.md)