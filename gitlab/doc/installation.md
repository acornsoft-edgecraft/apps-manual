## gitlab 설치 방법

### 1. 설치
- gitlab > assets 디렉토리 하위에 yaml 파일들을 순차적으로 실행 한다.
```sh
kubectl apply -f /install-yaml/01-gitlab-rback.yaml -n gitlab
```

### 2. gitlab.rb 파일 수정
- gitlat 설치 이후 컨테이너 접속 후 gitlat.rb 수정
```sh
$ kubectl get po -n gitlab

[root@vm-live-01 kong]# k get po -n gitlab
NAME                         READY   STATUS    RESTARTS   AGE
gitlab-ce-7b9fd55566-8qw52   1/1     Running   1          93m
plantuml-7956bcb764-g7h6x    1/1     Running   0          93m


$ kubectl exec -it gitlab-ce-7b9fd55566-8qw52 -n gitlab bash

root@gitlab-ce-7b9fd55566-8qw52:/# cd /etc/gitlab/
root@gitlab-ce-7b9fd55566-8qw52:/etc/gitlab# ls

gitlab-secrets.json  nginx_conf_20210430  ssh_host_ecdsa_key.pub  ssh_host_ed25519_key.pub  ssh_host_rsa_key.pub
gitlab.rb            ssh_host_ecdsa_key   ssh_host_ed25519_key    ssh_host_rsa_key          trusted-certs

$ vi gitlab.rb

Line : 33
external_url 'https://git.k3.acornsoft.io'

Line : 92
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.gmail.com"
gitlab_rails['smtp_port'] = 587
gitlab_rails['smtp_user_name'] = "asdfqwer14235@gmail.com"
gitlab_rails['smtp_password'] = "1a2s3d4f!$"
gitlab_rails['smtp_domain'] = "smtp.gmail.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = false
gitlab_rails['smtp_openssl_verify_mode'] = 'peer'

Line : 922
unicorn['worker_processes'] = 2

Line : 960
puma['worker_processes'] = 2

Line : 1307
nginx['listen_port'] = 80
nginx['listen_https'] = false
nginx['custom_gitlab_server_config'] = "location /-/plantuml/ { \n    proxy_cache off; \n    proxy_pass  http://plantuml:8080/; \n}\n"
nginx['client_max_body_size'] = '500000m'


```

