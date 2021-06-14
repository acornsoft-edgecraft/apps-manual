# SSH 설정 관련

| 패스워드를 입력하던 시스템                     | 접속 대상 시스템                                  |
| ----------------------------------------| ----------------------------------------------|
| rsa 혹은 dsa 암호화 방식 key를 생성           |                                              |
| 생성된 키의 .pub 파일을 접속 대상 시스템으로 전송  |                                              |
|                                          | pub 파일 내용을 authorized_keys 파일에 추가       |
| sh 등의 명령어로 암호 없이 접속 되는지 확인       |                                              |


## SSH key 생성 및 대상 장비에 복사하기
```bash
$ ssh-keygen -t rsa -N '' -f /Users/cloud/cert/onassis/id_rsa
$ ssh-copy-id -i /Users/cloud/cert/onassis/id_rsa.pub ubuntu@192.168.77.130
$ ssh-copy-id -i /Users/cloud/cert/onassis/id_rsa.pub ubuntu@192.168.77.131
$ ssh-copy-id -i /Users/cloud/cert/onassis/id_rsa.pub ubuntu@192.168.77.132
$ ssh-copy-id -i /Users/cloud/cert/onassis/id_rsa.pub ubuntu@192.168.77.133
$ ssh-copy-id -i /Users/cloud/cert/onassis/id_rsa.pub ubuntu@192.168.77.135
```

## root로 직접 로그인하는 것을 제한, 패스워드로 로그인 방지
```bash
$ vi /etc/ssh/sshd_config
...
#PermitRootLogin no
PasswordAuthentication no
...

$ systemctl restart sshd
```

## 일반 계정 패스워드 없이 sudo 권한 부여
```bash
$ cat > /etc/sudoers.d/ubuntu<<EOF
ubuntu ALL=(ALL) NOPASSWD:ALL
EOF
```

## 일반 user password 삭제
```bash
$ passwd -D ubuntu
```
