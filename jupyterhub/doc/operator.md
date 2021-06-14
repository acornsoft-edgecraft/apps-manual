https://github.com/GoogleCloudPlatform/spark-on-k8s-operator



```
helm install yms-spark spark-operator/spark-operator --namespace spark-operator --create-namespace --set sparkJobNamespace=default --set serviceAccounts.spark.name=spark

helm upgrade yms-spark spark-operator/spark-operator --namespace spark-operator --create-namespace --set sparkJobNamespace=default --set serviceAccounts.spark.name=spark


```



```
[root@centos-241 examples]# vi spark-py-pi.yaml
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
```



```
/opt/spark/bin/spark-submit 
--class org.apache.spark.examples.SparkPi 
--master k8s://https://172.20.0.1:443 
--deploy-mode cluster 
--conf spark.kubernetes.namespace=default 
--conf spark.app.name=spark-pi 
--conf spark.kubernetes.driver.pod.name=spark-pi-driver 
--conf spark.kubernetes.container.image=gcr.io/spark-operator/spark:v3.0.0 
--conf spark.kubernetes.container.image.pullPolicy=Always 
--conf spark.kubernetes.submission.waitAppCompletion=false 
--conf spark.kubernetes.driver.label.sparkoperator.k8s.io/app-name=spark-pi 
--conf spark.kubernetes.driver.label.sparkoperator.k8s.io/launched-by-spark-operator=true 
--conf spark.kubernetes.driver.label.sparkoperator.k8s.io/submission-id=0907b7aa-3049-4149-81e8-0d1135b0bc5f --conf spark.driver.cores=1 
--conf spark.kubernetes.driver.limit.cores=1200m 
--conf spark.driver.memory=512m 
--conf spark.kubernetes.authenticate.driver.serviceAccountName=spark 
--conf spark.kubernetes.driver.label.version=3.0.0 
--conf spark.kubernetes.executor.label.sparkoperator.k8s.io/app-name=spark-pi 
--conf spark.kubernetes.executor.label.sparkoperator.k8s.io/launched-by-spark-operator=true 
--conf spark.kubernetes.executor.label.sparkoperator.k8s.io/submission-id=0907b7aa-3049-4149-81e8-0d1135b0bc5f --conf spark.executor.instances=1 
--conf spark.executor.cores=1 
--conf spark.executor.memory=512m 
--conf spark.kubernetes.executor.label.version=3.0.0 
local:///opt/spark/examples/jars/spark-examples_2.12-3.0.0.jar
```

