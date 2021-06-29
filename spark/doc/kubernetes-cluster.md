# K8S cluster 모드로 배포하기

> Spark application을 kubernetes상테 driver+executor pod 행태로 배포할 수 있으며,
> Spark operator를 사용하여 좀 더 편하게 배포할 수 있다.

# 1. kubernetes 상에 apiserver 주소를 이용한 배포 
## 1.1 Spark jump pod 실행
```bash
$ kubectl create ns spark-work
$ kubectl create sa sparkjumppod -n spark-work
$ kubectl create clusterrolebinding sparkjumppod-role --clusterrole=admin --serviceaccount=spark-work:sparkjumppod --namespace=spark-work

$ kubectl create sa spark -n spark-work
$ kubectl create rolebinding spark-sa --clusterrole=edit --serviceaccount=spark-work:spark -n spark-work
```

## 1.2 Spark jump pod에서 pi 구하는 spark application 배포하기
```bash
$ kubectl run sparkjumppod -it -n spark-work --image=192.168.77.30/spark/spark:3.1.2-debian-10-r17 --serviceaccount='sparkjumppod'

$ spark-submit \
 --master "k8s://https://192.168.77.31:6443" \
 --deploy-mode cluster \
 --name spark-py-pi \
 --conf spark.executor.instances=2 \
 --conf spark.kubernetes.namespace=spark-work \
 --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
 --conf spark.kubernetes.container.image=gcr.io/spark-operator/spark-py:v3.0.0 \
 local:///opt/spark/examples/src/main/python/pi.py
```

## 1.3 결과 확인하기.
```bash
// driver, executor pod 상태 확인 
$ kubectl -n spark-work get pods 
NAME                                  READY   STATUS    RESTARTS   AGE
pythonpi-be201b7a51cbe5d0-exec-1      1/1     Running   0          3s
pythonpi-be201b7a51cbe5d0-exec-2      0/1     Pending   0          3s
spark-py-pi-5474e37a51cbcbf3-driver   1/1     Running   0          10s
sparkjumppod-6fbf7f9cf6-trqqc         1/1     Running   0          32m

// driver log에서 pi 값 결과 확인 
$ kubectl -n spark-work logs spark-py-pi-5474e37a51cbcbf3-driver
```
 * 참고사이트

[Getting Startd with Spark on Kubernetes](blog.brainlounge.de/memoryleaks/getting-started-with-spark-on-kubernetes)

# 2. K8S cluster에 Operator 방식으로 배포하기
Spark operator 방식의 chart 설치
CRD를 기반으로 Spark application을 편하게 deploy할 수 있다.

```bash
// repository 추가하기
$ helm repo add spark-operator https://googlecloudplatform.github.io/spark-on-k8s-operator
$ helm pull --untar -d ./assets spark-operator/spark-operator
```

 * spark sparkJobNamespace 를 spark-work2 로 하여 chart 배포하기
```bash
$ helm upgrade --cleanup-on-fail -i --create-namespace -n spark-operator spark-operator spark-operator/spark-operator -f values.yaml
$ kubectl get pods -n spark-operator 
```

 * Python으로 pi 값을 구하는 sample application 배포
```bash
$ git clone https://github.com/GoogleCloudPlatform/spark-on-k8s-operator.git
$ cd spark-on-k8s-operator/

$ vi spark-py-pi.yaml
apiVersion: "sparkoperator.k8s.io/v1beta2"
kind: SparkApplication
metadata:
  name: pyspark-pi
  namespace: spark-work2          // 지정된 namespace로 변경
spec:
  type: Python
  pythonVersion: "3"              // 수정해야 함.
  mode: cluster
  image: "gcr.io/spark-operator/spark-py:v3.1.1"
  imagePullPolicy: Always
  mainApplicationFile: local:///opt/spark/examples/src/main/python/pi.py
  sparkVersion: "3.1.1"
  restartPolicy:
    type: OnFailure
    onFailureRetries: 3
    onFailureRetryInterval: 10
    onSubmissionFailureRetries: 5
    onSubmissionFailureRetryInterval: 20
  driver:
    cores: 1
    coreLimit: "1200m"
    memory: "512m"
    labels:
      version: 3.1.1
    serviceAccount: spark-operator-spark       // 지정된 namespace에 sa 명 기입
  executor:
    cores: 1
    instances: 1
    memory: "512m"
    labels:
      version: 3.1.1


$ kubectl apply -f spark-py-pi.yaml
``` 

 * Driver, Executor pod 상태 확인 및 driver pod에서 결과 로그 확인
```bash
$ kubectl get sparkapplication -n spark-work2
$ kubectl -n spark-work2 logs pyspark-pi-driver
```

## 참고사이트
https://github.com/GoogleCloudPlatform/spark-on-k8s-operator
