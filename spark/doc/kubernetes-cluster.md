# K8S cluster 모드로 배포하기

> Spark application을 kubernetes상테 driver+executor pod 행태로 배포할 수 있으며,
> Spark operator를 사용하여 좀 더 편하게 배포할 수 있다.

#1. kubernetes 상에 apiserver 주소를 이용한 배포 
##1.1 Spark jump pod 실행
```bash
$ kubectl create ns spark-work
$ kubectl create sa sparkjumppod -n spark-work
$ kubectl create clusterrolebinding sparkjumppod-role --clusterrole=admin --serviceaccount=spark-work:sparkjumppod --namespace=spark-work

$ kubectl create sa spark -n spark-work
$ kubectl create rolebinding spark-sa --clusterrole=edit --serviceaccount=spark-work:spark -n spark-work
```

##1.2 Spark jump pod에서 pi 구하는 spark application 배포하기
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

##1.3 결과 확인하기.
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

#2. K8S cluster에 Operator 방식으로 배포하기
Spark operator 방식의 chart 설치
CRD를 기반으로 Spark application을 편하게 deploy할 수 있다.

```bash
// repository 추가하기
> helm repo add spark-operator https://googlecloudplatform.github.io/spark-on-k8s-operator

// spark-operator namespace에 my-spark-operator 이름으로 deploy하기
> helm upgrade -i -n spark-operator --create-namespace my-spark-operator spark-operator/spark-operator 

아래와 같이 SparkApplication workload에 spark driver와 executor의 instance 개수, resource, image를 설정하여 deploy하면 된다.
// Sample download
> git clone https://github.com/GoogleCloudPlatform/spark-on-k8s-operator.git
> cd spark-on-k8s-operator/
> kubectl apply -f spark-py-pi.yaml

--- spark-py-pi.yaml 내용 --------------------
apiVersion: "sparkoperator.k8s.io/v1beta2"
kind: SparkApplication
metadata:
  name: pyspark-pi
  namespace: default
spec:
  type: Python
  pythonVersion: "2"
  mode: cluster
  image: "gcr.io/spark-operator/spark-py:v3.0.0"
  imagePullPolicy: Always
  mainApplicationFile: local:///opt/spark/examples/src/main/python/pi.py
  sparkVersion: "3.0.0"
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
      version: 3.0.0
    serviceAccount: spark
  executor:
    cores: 1
    instances: 1
    memory: "512m"
    labels:
      version: 3.0.0

// 실행후 상태 조회.

$ kubectl get sparkapplication
$ kubectl logs -f yms-spark-spark-operator-79dc778db4-hvhbf -n spark-operator
```

## 참고사이트
https://github.com/GoogleCloudPlatform/spark-on-k8s-operator
