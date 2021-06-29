# 네임스페이스에 대한 메모리 및 CPU 쿼터 구성

## 리소스쿼터 생성
- 다음은 리소스쿼터 오브젝트의 구성 파일이다.
```sh
cat <<EOF | kubectl -n m3db apply - 
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mem-cpu
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 25Gi
    limits.cpu: "2"
    limits.memory: 25Gi
EOF
```
- 리소스쿼터를 생성한다.
```sh
$ kubectl apply -f https://k8s.io/examples/admin/resource/quota-mem-cpu.yaml --namespace=quota-mem-cpu-example
```

- 리소스쿼터에 대한 자세한 정보를 본다.
```sh
$ kubectl get resourcequota mem-cpu-demo --namespace=quota-mem-cpu-example --output=yaml
```

리소스쿼터는 이러한 요구 사항을 quota-mem-cpu-example 네임스페이스에 배치한다.

모든 컨테이너에는 메모리 요청량(request), 메모리 상한(limit), CPU 요청량 및 CPU 상한이 있어야 한다.
모든 컨테이너에 대한 총 메모리 요청량은 25GiB를 초과하지 않아야 한다.
모든 컨테이너에 대한 총 메모리 상한은 25GiB를 초과하지 않아야 한다.
모든 컨테이너에 대한 총 CPU 요청량은 2 cpu를 초과해서는 안된다.
모든 컨테이너에 대한 총 CPU 상한은 2 cpu를 초과해서는 안된다.


-----
# 참조
> [네임스페이스에 대한 메모리 및 CPU 쿼터 구성](https://kubernetes.io/ko/docs/tasks/administer-cluster/manage-resources/quota-memory-cpu-namespace/)