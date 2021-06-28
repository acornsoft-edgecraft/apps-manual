#1. Get kubesphere and install

wget https://github.com/kubesphere/ks-installer/releases/download/v3.0.0/kubesphere-installer.yaml
wget https://github.com/kubesphere/ks-installer/releases/download/v3.0.0/cluster-configuration.yaml

kubectl apply -f kubesphere-installer.yaml
kubectl apply -f cluster-configuration.yaml

#2. kubenetes 1.9+ 이상에서 로그인 오류 해결 방법

kubectl apply -f https://raw.githubusercontent.com/kubesphere/ks-installer/2c4b479ec65110f7910f913734b3d069409d72a8/roles/ks-core/prepare/files/ks-init/users.iam.kubesphere.io.yaml
kubectl apply -f https://raw.githubusercontent.com/kubesphere/ks-installer/2c4b479ec65110f7910f913734b3d069409d72a8/roles/ks-core/prepare/files/ks-init/webhook-secret.yaml
kubectl -n kubesphere-system rollout restart deploy ks-controller-manager


* 참고: github.com/kubesphere/kubesphere/issues/2928

```bash
$ kubectl get pods -n kubesphere-system
kubesphere-system              ks-apiserver-b586d6f5d-dg7ks                            1/1     Running   2          84m
kubesphere-system              ks-console-8499d486cd-vdrwh                             1/1     Running   1          3h3m
kubesphere-system              ks-controller-manager-d97b6cc49-vpbhc                   1/1     Running   3          84m
kubesphere-system              ks-installer-58b9cf7c4c-n6tmt                           1/1     Running   0          3h6m
kubesphere-system              openldap-0                                              1/1     Running   1          3h3m
kubesphere-system              redis-658988fc5b-qjfqv                                  1/1     Running   1          3h3m

$ kubectl get pods -n kubesphere-controls-system
kubesphere-controls-system     default-http-backend-76d9fb4bb7-ld9sd                   1/1     Running   0          3h3m
kubesphere-controls-system     kubectl-admin-846b9cc57c-879v7                          1/1     Running   0          3h1m

$ kubectl get pods -n kubesphere-monitoring-system
kubesphere-monitoring-system   alertmanager-main-0                                     2/2     Running   0          3h2m
kubesphere-monitoring-system   alertmanager-main-1                                     2/2     Running   0          3h2m
kubesphere-monitoring-system   alertmanager-main-2                                     2/2     Running   2          3h2m
kubesphere-monitoring-system   kube-state-metrics-5d5497cc86-dkj64                     3/3     Running   0          3h2m
kubesphere-monitoring-system   node-exporter-j5qq8                                     2/2     Running   0          3h2m
kubesphere-monitoring-system   node-exporter-lbxbl                                     2/2     Running   0          3h2m
kubesphere-monitoring-system   node-exporter-xwd7q                                     2/2     Running   2          3h2m
kubesphere-monitoring-system   notification-manager-deployment-5d97567d97-gbgjr        1/1     Running   0          3h1m
kubesphere-monitoring-system   notification-manager-deployment-5d97567d97-k2h4w        1/1     Running   0          3h1m
kubesphere-monitoring-system   notification-manager-operator-5c9fb4bc89-mxfmm          2/2     Running   5          3h2m
kubesphere-monitoring-system   prometheus-k8s-0                                        3/3     Running   1          3h2m
kubesphere-monitoring-system   prometheus-k8s-1                                        3/3     Running   1          3h2m
kubesphere-monitoring-system   prometheus-operator-9c9d4dd96-vwml2                     2/2     Running   0          3h2m

$ kubectl get pods -n kube-system
kube-system                    snapshot-controller-0                                   1/1     Running   0          3h3m
```

#3. kubesphere 로그인

Console: http://192.168.77.30:30880
Account: admin
Password: P@88w0rd