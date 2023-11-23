## 그라파나 admin 계정 패스워드 분실 시 (grafana admin password reset)

그라파나가 설치되어있는 서버에서 아래 명령어를 입력하여 admin 계정 패스워드를 재설정할 수 있습니다.

- grafana pod로 접속 한 후 아래 명령 실행
```sh
# grafana-cli admin reset-admin-password [사용할 패스워드]
grafana-cli admin reset-admin-password admin
```