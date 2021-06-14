[TOC]

### Haproxy 설정
 * haproxy는 k8s apiserver를 위한 internal LB로 사용할 수 있다.(옵션)
 * haproxy는 static pod형태로 /etc/kubernetes/manifests 에 POD yaml를 위치시켜 kubelet이 기동할 떄 자동으로 실행되게 된다.
 * haproxy의 설정파일은 /etc/haproxy/haproxy.cfg에 있
 
```bash
$ mkdir /etc/kubernetes/manifests

$ mkdir /etc/haproxy
$ mkdir /var/lib/etcd

$ cat > /etc/kubernetes/manifests/haproxy.yaml <<EOF 
apiVersion: v1
kind: Pod
metadata:
  name: haproxy
  namespace: kube-system
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
    k8s-app: kube-haproxy
spec:
  hostNetwork: true
  nodeSelector:
    beta.kubernetes.io/os: linux
  priorityClassName: system-node-critical
  containers:
  - name: haproxy
{% if closed_network %}
    image: "{{ registry_domain }}/addons/haproxy:2.2.0"
{% else %}
    image: "haproxy:2.2.0"
{% endif %}
    imagePullPolicy: IfNotPresent
    resources:
      requests:
        cpu: 25m
        memory: 32M
    securityContext:
      privileged: true
    volumeMounts:
    - mountPath: /usr/local/etc/haproxy/haproxy.cfg
      name: etc-haproxy
      readOnly: true
  volumes:
  - name: etc-haproxy
    hostPath:
      path: /etc/haproxy/haproxy.cfg
EOF

$ cat > /etc/haproxy/haproxy.cfg <<EOF 
global
  log 127.0.0.1 local0
  log 127.0.0.1 local1 notice
  tune.ssl.default-dh-param 2048

defaults
  log global
  mode http
  #option httplog
  option dontlognull
  timeout connect 5000ms
  timeout client 50000ms
  timeout server 50000ms

frontend api-https
   mode tcp
   bind :{{ haproxy_port }}
   default_backend api-backend

backend api-backend
    mode tcp
{% for host in groups['masters'] %}
    server  api{{ loop.index }}  {{ hostvars[host]['ip'] }}:{{ api_secure_port }}  check
{% if not loop.last -%}{%- endif -%}
{% endfor %}
EOF
```      