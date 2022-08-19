# etcd-viewer

```sh
cat <<EOF | kubectl -n m3db apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
EOF
```

## etcd client
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: etcd
  labels:
    app: etcd
  namespace: m3db
spec:
  ports:
    - port: 2379
      name: client
    - port: 2380
      name: peer
  clusterIP: None
  selector:
    app: etcd
EOF

-----
# 참조
> [etcd-viewer](https://github.com/nikfoundas/etcd-viewer)
