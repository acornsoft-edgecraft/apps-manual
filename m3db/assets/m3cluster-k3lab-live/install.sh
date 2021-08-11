#!/bin/bash

####################################################################
# Setup M3DB Operator and ETCD Cluster
####################################################################

kubectl apply -f ./manifests/setup

until kubectl get crd m3dbclusters.operator.m3db.io ; do date; sleep 3; echo "waiting to create operator"; done 
until kubectl -n m3db wait --for=condition=ready pod/etcd-2 ; do date; sleep 3; echo "waiting to ready state of etcd cluster"; done

####################################################################
# Setup M3DB Cluster
####################################################################

kubectl apply -f ./manifests/cluster

until kubectl -n m3db get pod m3-cluster-rep0-2 ; do date; sleep 3; echo "waiting to craete m3cb cluster"; done
until kubectl -n m3db wait --for=condition=ready pod/m3-cluster-rep0-2 ; do date; sleep 3; echo "waiting to ready state of m3dbnode"; done

####################################################################
# Setup Placement for Coordinator and Aggregator
####################################################################

kubectl -n m3db exec m3-cluster-rep0-0 -- curl -vvvsSf -H "Cluster-Environment-Name: m3db/m3-cluster" -X POST http://localhost:7201/api/v1/services/m3aggregator/placement/init -d '{
    "num_shards": 12,
    "replication_factor": 2,
    "instances": [
        {
            "id": "m3aggregator-0",
            "isolation_group": "group1",
            "zone": "embedded",
            "weight": 100,
            "endpoint": "m3aggregator.m3db:6000",
            "hostname": "m3aggregator-0",
            "port": 6000
        },
        {
            "id": "m3aggregator-1",
            "isolation_group": "group2",
            "zone": "embedded",
            "weight": 100,
            "endpoint": "m3aggregator.m3db:6000",
            "hostname": "m3aggregator-1",
            "port": 6000
        }
    ]
}' | jq .

# kubectl -n m3db exec m3-cluster-rep0-0 -- curl http://localhost:7201/api/v1/services/m3aggregator/placement | jq .

# Initialize m3msg topic for m3aggregator to receive from m3coordinator to aggregate metrics
kubectl -n m3db exec m3-cluster-rep0-0 -- curl -vvvsSf -H "Cluster-Environment-Name: m3db/m3-cluster" -H "Topic-Name: aggregator_ingest" -X POST http://localhost:7201/api/v1/topic/init -d '{
    "numberOfShards": 12
}' | jq .

# Add m3aggregator consumer group to ingest topic
kubectl -n m3db exec m3-cluster-rep0-0 -- curl -vvvsSf -H "Cluster-Environment-Name: m3db/m3-cluster" -H "Topic-Name: aggregator_ingest" -X POST http://localhost:7201/api/v1/topic -d '{
  "consumerService": {
    "serviceId": {
      "name": "m3aggregator",
      "environment": "m3db/m3-cluster",
      "zone": "embedded"
    },
    "consumptionType": "REPLICATED",
    "messageTtlNanos": "300000000000"
  }
}' | jq .

# kubectl -n m3db exec m3-cluster-rep0-0 -- curl -vvvsSf -H "Cluster-Environment-Name: m3db/m3-cluster" -H "Topic-Name: aggregator_ingest" http://localhost:7201/api/v1/topic | jq .

# Initializing m3msg topic for m3coordinator to receive from m3aggregator to write m3db
kubectl -n m3db exec m3-cluster-rep0-0 -- curl -vvvsSf -H "Cluster-Environment-Name: m3db/m3-cluster" -H "Topic-Name: aggregated_metrics" -X POST http://localhost:7201/api/v1/topic/init -d '{
    "numberOfShards": 12
}' | jq .

# Initializing m3coordinator topology
kubectl -n m3db exec m3-cluster-rep0-0 -- curl -vvvsSf -H "Cluster-Environment-Name: m3db/m3-cluster" -X POST http://localhost:7201/api/v1/services/m3coordinator/placement/init -d '{
    "instances": [
        {
            "id": "m3coordinator-0",
            "zone": "embedded",
            "endpoint": "m3coordinator.m3db:7507",
            "hostname": "m3coordinator-0",
            "port": 7507
        },
        {
            "id": "m3coordinator-1",
            "zone": "embedded",
            "endpoint": "m3coordinator.m3db:7507",
            "hostname": "m3coordinator-1",
            "port": 7507
        }
    ]
}' | jq .

# kubectl -n m3db exec m3-cluster-rep2-0 -- curl -vvvsSf -H "Cluster-Environment-Name: m3db/m3-cluster" http://localhost:7201/api/v1/services/m3coordinator/placement | jq .

# Add m3coordinator consumer group to outbound topic
kubectl -n m3db exec m3-cluster-rep0-0 -- curl -vvvsSf -H "Cluster-Environment-Name: m3db/m3-cluster" -H "Topic-Name: aggregated_metrics" -X POST http://localhost:7201/api/v1/topic -d '{
  "consumerService": {
    "serviceId": {
      "name": "m3coordinator",
      "environment": "m3db/m3-cluster",
      "zone": "embedded"
    },
    "consumptionType": "SHARED",
    "messageTtlNanos": "300000000000"
  }
}' | jq .

# kubectl -n m3db exec m3-cluster-rep0-0 -- curl -vvvsSf -H "Cluster-Environment-Name: m3db/m3-cluster" -H "Topic-Name: aggregated_metrics" http://localhost:7201/api/v1/topic | jq .

####################################################################
# Setup Namespaces to Ready
####################################################################

# kubectl -n m3db exec m3-cluster-rep0-0 -- curl -X POST http://localhost:7201/api/v1/services/m3db/namespace/ready -d '{
#   "name": "default"
# }' | jq .

# kubectl -n m3db exec m3-cluster-rep0-0 -- curl -X POST http://localhost:7201/api/v1/services/m3db/namespace/ready -d '{
#   "name": "metrics-10s_2d"
# }' | jq .

####################################################################
# Setup Coordinator, Aggregator, Qeury
####################################################################

kubectl apply -f ./manifests

####################################################################
# Delete Embedded Coordinator on M3DB
####################################################################

kubectl -n m3db delete service/m3coordinator-m3-cluster 