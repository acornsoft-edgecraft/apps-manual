

## CoreDNS version
 * k8s v1.19, v1.20: Coredns v1.7.0
 * k8s v1.21: Coredns v1.8.0 
 * https://github.com/coredns/deployment/blob/master/kubernetes/CoreDNS-k8s_version.md

## Coredns images
```bash
$ yum install skopeo

$ skopeo list-tags docker://k8s.gcr.io/coredns
{
    "Repository": "k8s.gcr.io/coredns",
    "Tags": [
        "1.0.1",
        "1.0.1__amd64_linux",
        "1.0.1__arm64_linux",
        "1.0.1__arm_linux",
        "1.0.1__ppc64le_linux",
        "1.0.1__s390x_linux",
        "1.0.6",
        "1.0.6__amd64_linux",
        "1.0.6__arm64_linux",
        "1.0.6__arm_linux",
        "1.0.6__ppc64le_linux",
        "1.0.6__s390x_linux",
        "1.1.3",
        "1.1.3__amd64_linux",
        "1.1.3__arm64_linux",
        "1.1.3__arm_linux",
        "1.1.3__ppc64le_linux",
        "1.1.3__s390x_linux",
        "1.2.2",
        "1.2.3",
        "1.2.4",
        "1.2.6",
        "1.3.0",
        "1.3.1",
        "1.5.0",
        "1.6.2",
        "1.6.5",
        "1.6.6",
        "1.6.7",
        "1.7.0"
    ]
} 

$ skopeo list-tags docker://k8s.gcr.io/coredns/coredns
{
    "Repository": "k8s.gcr.io/coredns/coredns",
    "Tags": [
        "v1.6.6",
        "v1.6.7",
        "v1.6.9",
        "v1.7.0",
        "v1.7.1",
        "v1.8.0",
        "v1.8.3",
        "v1.8.4"
    ]
}
``` 

```bash
$ kubeadm upgrade apply -y v1.21.0 --config=/etc/kubernetes/kubeadm.yaml --ignore-preflight-errors=all --allow-experimental-upgrades --allow-release-candidate-upgrades --etcd-upgrade=false --certificate-renewal=false --force
```
