#!/usr/local/bin/python3

import requests, json, os

if __name__ == '__main__':

    # 버전정보 등록(필수)
    k8s_versions = "v1.20.6"
    # Harbor IP 등록(필수)
    registry_ip = "192.168.77.128"

    # Harbor 인증서(필수 => sh 파일 위치에 같이 존재 해야함)
    ca_crt = "ca.crt"

    project_names = []

    # 이미지 정보 등록(필수)
    images = (
        "k8s.gcr.io/kube-apiserver:${K8S_VERIONS}",
        "k8s.gcr.io/kube-controller-manager:${K8S_VERIONS}",
        "k8s.gcr.io/kube-scheduler:${K8S_VERIONS}",
        "k8s.gcr.io/kube-proxy:${K8S_VERIONS}",
        "k8s.gcr.io/pause:3.3",
        "k8s.gcr.io/coredns:1.7.0",
        "k8s.gcr.io/metrics-server:v0.3.6",
        "docker.io/calico/typha:v3.15.1",
        "docker.io/calico/node:v3.15.1",
        "docker.io/calico/cni:v3.15.1",
        "docker.io/calico/kube-controllers:v3.15.1",
        "docker.io/calico/pod2daemon-flexvol:v3.15.1",
        "docker.io/fluent/fluent-bit:1.5.3",
        "docker.io/fluent22/fluent-bit:1.5.3",
        "quay.io/prometheus/prometheus:v2.26.0"
    )

    headers = {
        'accept': 'application/json',
        'Authorization': 'Basic YWRtaW46QGMwcm5zMGZ0',
        'X-Xsrftoken': 'N41eO8TW1xq4Jyhq6jQY0HYd2reF5th2',
        'Content-type': 'application/json',
    }

    # project 명 생성을 위한 param json
    data = {
        'project_name': '',
        'metadata': {'public': 'true'},
        'count_limit': -1,
        'storage_limit': -1
    }

    for image in list(images):
        down_image = ""
        tag_image = ""
        project_name = ""

        if image.startswith("k8s.gcr.io"):
            down_image = image.replace("${K8S_VERIONS}", k8s_versions)
            project_name = "google_containers"
        else:
            down_image = image
            names = image.split("/")
            if len(names) == 2:
                project_name = "library"
            else:
                project_name = names[1]

        image_names = down_image.split("/")
        # docker tag image(registry ip 설정)
        tag_image = registry_ip+"/"+project_name+"/"+image_names[len(image_names)-1]

        # project 생성 여부 확인 flag
        ns_flag = "N"
        # 소스상에서 생성한 프로젝트명의 존재 유무 체크
        if len(project_names) > 0:
            try:
                project_names.index(project_name)
            except ValueError:
                ns_flag = "Y"
        else:
            ns_flag = "Y"

        if ns_flag == "Y":

            # 프로젝트명 검색
            url = 'https://' + registry_ip + '/api/projects?project_name=' + project_name
            response = requests.head(url, headers=headers, verify="ca.crt")

            if response.status_code == 404:
                data["project_name"] = project_name
                project_names.append(project_name)

                # 프로젝트명 생성 처리
                url = 'https://' + registry_ip + '/api/projects'
                response = requests.post(url, headers=headers, data=json.dumps(data), verify=ca_crt)
            else:
                project_names.append(project_name)

        print("Project Name >> " + project_name)
        print("DownLoad Image Name >> " + down_image)
        print("Tag Image Name >> " + tag_image)

        os.system('docker pull {}'.format(down_image))
        os.system('docker tag {} {}'.format(down_image, tag_image))
        os.system('docker push {}'.format(tag_image))

    print("Completed")
