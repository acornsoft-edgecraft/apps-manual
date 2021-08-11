# M3db 안정화

## chek list

- [x] ETCD 안정화 확인
  - [x] 동기화 시간 체크 : 1s 미만


- [x] m3db-cluster 안정화 확인
  - [x] kernel 관련 에러 확인 : quay.io/m3/sysctl-setter 가 노드 설정을 변경 하는 daemenset 이다.
  ```sh
  $ kubeclt -n m3db logs sysctl-setter-ds-bxrkp
  fs.file-max = 3000000
  fs.nr_open = 3000000
  ```

  

- [ ] 노드 Not ready 상태 원인 분석
  - [ ] 파드의 메모리 사용량이 노드 메모리 가용량을 넘었을때 발생 하는가 확인 필요.


## 변경 사항

- ETCD : container 볼륨 사용(임시): product 환경에선 비권장
  - [ ] master nodes 의 etcd를 사용 하는 것 으로 변경중
  

## 확인 해야 할 사항
- placement init 에서 endpoint 값을 확인 해 보자.
  - m3-cluster의 etcd endpoint는 pod명.ep명.포트번호로 설정 되어 있다.
  - m3aggregator 에서는 다르게 설정 되어 있음 확인 필요
  ```yaml
  "endpoint": "m3aggregator.m3db:6000"
  
  ## 변경 확인 할 것
  "m3aggregator-0.m3aggregator:6000",
  ```
