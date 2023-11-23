
# Change POD CIDR and Encapsulation types

```bash
$ curl -O -L  https://github.com/projectcalico/calicoctl/releases/download/v3.16.0/calicoctl
$ chmod +x calicoctl

$ export DATASTORE_TYPE=kubernetes
$ export KUBECONFIG=/etc/kubernetes/admin.conf

$ calicoctl node status
Calico process is running.

IPv4 BGP status
+--------------+-------------------+-------+----------+-------------+
| PEER ADDRESS |     PEER TYPE     | STATE |  SINCE   |    INFO     |
+--------------+-------------------+-------+----------+-------------+
| 172.16.0.122 | node-to-node mesh | up    | 10:40:21 | Established |
| 172.16.0.123 | node-to-node mesh | up    | 10:40:21 | Established |
| 172.16.0.124 | node-to-node mesh | up    | 10:42:32 | Established |
| 172.16.0.125 | node-to-node mesh | up    | 10:42:44 | Established |
| 172.16.0.126 | node-to-node mesh | up    | 10:42:49 | Established |
| 172.16.0.127 | node-to-node mesh | up    | 10:43:07 | Established |
+--------------+-------------------+-------+----------+-------------+

IPv6 BGP status
No IPv6 peers found.

$ calicoctl get ippool -o wide
NAME                  CIDR           NAT    IPIPMODE   VXLANMODE   DISABLED   SELECTOR   
default-ipv4-ippool   10.32.0.0/12   true   Always     Never       false      all()   

$ calicoctl get wep --all-namespaces
NAMESPACE     WORKLOAD                                   NODE            NETWORKS        INTERFACE
kube-system   calico-kube-controllers-78c96fcb6b-wkzbx   vm-onassis-03   10.0.13.66/32   cali49d71772c3d
kube-system   coredns-6dbf96857c-226k6                   vm-onassis-01   10.0.110.1/32   cali0cdb70f30b6
kube-system   coredns-6dbf96857c-m488b                   vm-onassis-03   10.0.13.65/32   cali5c8462beef4
kube-system   metrics-server-55868868d4-g7wt4            vm-onassis-01   10.0.110.3/32   cali6fcfbc54078
kube-system   metrics-server-55868868d4-mfckz            vm-onassis-03   10.0.13.67/32   calie113fcca718

$ calicoctl get ippool default-ipv4-pool -o yaml > ipv4-pool.yaml

$ vi ipv4-pool.yaml
apiVersion: projectcalico.org/v3
kind: IPPool
metadata:
  name: ipv4-ippool
spec:
  cidr: 192.168.0.0/16
  ipipMode: Never
  natOutgoing: true
  nodeSelector: all()
  vxlanMode: Always

$ calicoctl apply -f ipv4-pool.yaml

$ calicoctl delete ippool default-ipv4-pool

$ calicoctl get ippool -o wide


$ kubectl get nodes node1 -o yam1 > node1.yaml
$ kubectl get nodes node2 -o yam1 > node2.yaml
$ kubectl get nodes node3 -o yam1 > node3.yaml

$ vi node1.yaml (node2.yaml, node3.yaml)
apiVersion: v1
kind: Node
metadata:
  name: node1
spec:
  podCIDR: 192.168.0.0/16
  podCIDRs:
  - 192.168.0.0/16

$ kubectl delete node node1; k apply -f node1.yaml
$ kubectl delete node node2; k apply -f node1.yaml
$ kubectl delete node node3; k apply -f node1.yaml
```


# Change Service CIDR

 * 참고 https://www.devops.buzz/public/kubeadm/change-servicesubnet-cidr

## 전체 노드에서 백업
```bash
$ cp -R /etc/kubernetes /etc/kubernetes_bak
$ cd /prod/cri/work

$ mkdir work
$ cd work
$ kubectl get cm -o yaml -n kube-system kubeadm-config > kubeadm.yaml
$ vi kubeadm.yaml
...
serviceSubnet: 172.20.0.0/16
...
```

## master1,2,3에서에서 10.96.0.1 -> 172.20.0.1로 변경한 후 kube-apiserver 인증서 재생성
```bash
vi /opt/kubernetes/pki/common-openssl.conf
...
IP.3 = 172.20.0.1
...

openssl req -new -key /etc/kubernetes/pki/apiserver.key -subj '/CN=kube-apiserver' |
openssl x509 -req -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out ./apiserver.crt -days 29012 -extensions v3_req_apiserver -extfile /opt/kubernetes/pki/common-openssl.conf

cp ./apiserver.crt /etc/kubernetes/pki/apiserver.crt

ps -ef | grep kube-apiserver
kill {pid}
```

## 전체 노드에서 kubelet 재시작
```bash
systemctl daemon-reload; systemctl restart kubelet

kubectl -n kube-system delete service kube-dns
kubeadm upgrade apply --config ./kubeadm.yaml --certificate-renewal=false
```

## kubernetes 서비스 삭제
```bash
kubectl -n default delete service kubernetes

$ kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   172.20.0.1   <none>        443/TCP   2s

전체 노드에서 /etc/sysconfig/kubelet에 —cluster-dns=172.20.0.10 항목 추가 후 restart
systemctl restart kubelet
```

## 이후 각 service에서 uid, clusterIP 삭제 저장 후 재생성
```bash
kubectl get svc -n cocktail-system -o yaml > cocktail-service.yaml
kubectl delete svc -n cocktail-system
kubectl apply -f cocktail-service.yaml
```
