#!/bin/bash

# curl --cacert /data/harbor/cert/ca.crt -u admin:@c0rns0ft -X GET https://192.168.77.128/api/projects
# https://console.cloud.google.com/gcr/images/k8s-artifacts-prod

K8S_VERIONS="${1}"
REGISTRY_IP="${2}"

# k8s images
images=(
    "k8s.gcr.io/kube-apiserver-amd64:v${K8S_VERIONS}"
    "k8s.gcr.io/kube-controller-manager-amd64:v${K8S_VERIONS}"
    "k8s.gcr.io/kube-scheduler-amd64:v${K8S_VERIONS}"
    "k8s.gcr.io/kube-proxy-amd64:v${K8S_VERIONS}"
    "k8s.gcr.io/pause:3.3"
    "k8s.gcr.io/coredns:1.7.0"
    "k8s.gcr.io/metrics-server-amd64:v0.3.6"

    "docker.io/calico/typha:v3.15.1"
    "docker.io/calico/node:v3.15.1"
    "docker.io/calico/cni:v3.15.1"
    "docker.io/calico/apiserver:v3.15.1"
    "docker.io/calico/kube-controllers:v3.15.1"
    "docker.io/calico/pod2daemon-flexvol:v3.15.1"

    "docker.io/fluent/fluent-bit:1.5.3"
    "docker.io/haproxy:2.0.0"
)

error_exit() {
    echo "error: ${1:-"unknown error"}" 1>&2
    exit 1
}


main() {
    if (( "$#" < 2 )); then
        echo "Usage: $0 k8s-version registry-ip"
        error_exit "Illegal number of parameters. You must specify k8s version and registry ip to upload images"
    fi

    for image in "${images[@]}"; do
        local tagged_image=""

        if [[ "${image}" =~  "k8s.gcr.io" ]]; then
            tagged_image=$(echo ${image/k8s.gcr.io/$REGISTRY_IP/google_containers})
        elif [[ "${image}" =~  "docker.io" ]]; then
            tagged_image=$(echo ${image/docker.io/$REGISTRY_IP})
        fi

        docker pull ${image}
        docker tag ${image} ${tagged_image}
        docker push ${tagged_image}
    done

    echo "Completed"
}

main "${@}"