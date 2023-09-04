# Edgecraft Openstack (77 to 88) Migration Guidelines

# 기능별 구성 및 Migration 대상 처리

## Management Cluster 기능

### CAPI Addon Provider for Helm (CAAPH) 구성

- CAPI 기능을 확장해 클러스터에 Helm을 기반으로 추가 기능을 설치/구성/업그레이드 및 삭제를 관리하는 솔루션이다.
- [Repository](https://github.com/kubernetes-sigs/cluster-api-addon-provider-helm)
- CAPI 의 CLI 와 통합되어 설치가 가능하다.

CAAPH 오퍼레이터는 아래의 명령을 통해서 설치할 수 있다.

[`clusterctl`](https://cluster-api.sigs.k8s.io/clusterctl/overview.html) 버전 `1.5` 이상에서 통합된 명령을 통해 CAAPH를 구성할 수 있다.

```bash
$ clusterctl init --addon helm
```

실제 라벨을 통해서 동작하게될 Addon 은 [edgecraft-caaph](https://github.com/acornsoft-edgecraft/edgecraft-caaph) 에서 `manifests/addons` 에 포맷에 맞는 YAML 파일로 구성한다.

구성된 Addon 들을 매니지먼트 클러스터에 설치하는 방법은 `minifests/1.install_addon_22apps.sh` 스크립트를 통해서 CR로 배포한다.


## Backup & Restore 기능

### MinIO 설처 (Standalone)

- Size : m1.medium, 20G Disk
- IP : 192.168.88.74
- Domain: minio.edgecraft.acornsoft.io
- OS : ubuntu 20.04


#### STEP 1: MinIO 서버 다운로드 및 설치

MinIO 서버는 바이너리 파일 또는 `.deb`패키지에서 설치할 수 있다. 이 문서에서는 패키지를 사용하여 설치합니다.

서버에 `ssh`로 연결해서 패키지 데이터베이스 및 시스템을 업그레이드 한다.

```bash
# 연결된 서버에서 패키지 데이터베이스 업데이트
$ sudo apt update
$ sudo apt upgrade
```

[MinIO 다운로드 페이지](https://min.io/download#/linux) 에서 `.deb` 최신 패키지를 다운로드 한다. 에서 MinIO 서버의 최신 패키지를 다운로드한다.

```bash
$ wget https://dl.min.io/server/minio/release/linux-amd64/minio_20230816201730.0.0_amd64.deb
```

다운로드한 파일을 아래의 명령으로 설치한다.

```bash
$ sudo dpkg -i minio_20230816201730.0.0_amd64.deb
```

`minio` 명령을 통하거나 서비스를 통해서 MinIO 서버를 시작할 수 있다. 이 문서에서는 패키지를 통해서 서비스까지 설치한 것이다.

#### STEP 2: MInIO 사용자, 그룹, 데이터 디렉토리 및 환경 파일 생성

아래의 명령으로 MinIO 서버에 대한 시스템 그룹을 생성한다.

```bash
# -r 옵션을 이용해서 시스템 그룹으로 생성
$ sudo groupadd -r minio-user
```

아래의 명령으로 MinIO 서버에 대한 사용자를 생성한다.

```bash
# -M 옵션으로 사용자 홉 디렉터리 작성 생략
# -r 옵션으로 시스템 사용자 처리
# -g 기본 사용자 그룹에 할당 (위에서 만든 minio-user 그룹)
$ sudo useradd -M -r -g minio-user minio-user
```

아래의 명령으로 MinIO 가 사용할 데이터 디렉터리 생성

```bash
$ sudo mkdir /mnt/data
```

아래의 명령으로 생성한 디렉터리에 대한 소유권 설정

```bash
$ sudo chown minio-user:minio-user /mnt/data
```

MinIO 구동에 필욯한 기본 환경 파일 구성

```
sudo nano /etc/default/minio
```

이 파일은 서버와 콘솔에 필요한 변수들을 정의한 것으로 아래와 같이 구성한다.

```
# MinIO 데이터 디렉터리 
MINIO_VOLUMES="/mnt/data"

# 디지털 인증서 디렉터리 (이후 생성), 콘솔 수신 주소 및 포트
MINIO_OPTS="--certs-dir /home/<user>/.minio/certs --console-address :9001"

# 콘솔 사용자 
MINIO_ROOT_USER=minioadmin

# 콘솔 사용자 비밀번호
MINIO_ROOT_PASSWORD=minioadmin
```

#### STEP 3: 방화벽 설정

MinIO 서버 및 MinIO 콘솔에 액세스하는 포트로 트래픽을 허용하도록 방화벽을 구성한다.

-   `9000`MinIO 서버가 수신 대기하는 기본 포트입니다.
-   `9001`MinIO 콘솔에 액세스하기 위한 권장 포트입니다.

아래의 명령으로 방화벽에 포트를 허용한다.

```bash
$ sudo ufw allow 9000:9001/tcp
Rule updated
Rule updated (v6)
```

#### STEP 4: 자체 서명된 인증서로 MinIO 서버에 대한 액세스 보안

MinIO 엣 제공하는 `certgen`을 사용해서 자체 서명된 인증서를 생성한다. (작성 시점의 최신 버전은 [1.2.1](https://github.com/minio/certgen/releases/tag/v1.2.0))

아래의 명령으로 최신 버전을 다운로드 한다.

```bash
$ wget https://github.com/minio/certgen/releases/download/v1.2.1/certgen_1.2.1_linux_amd64.deb
```

아래의 명령으로 설치한다.

```bash
$ sudo dpkg -i certgen_1.2.1_linux_amd64.deb
```

이제 시스템에서 `certgen` 명형을 사용할 수 있고, `certgen -h` 명령을 통해 정보를 확인할 수 있다.

MinIO 서버가 구동되는 서버에 대한 IP 와 도메인 주소를 지정해서 인증서를 생성한다.

```bash
$ sudo certgen -host example.com,your-server-ip
```

`certgen`이제 시스템에서 명령을 사용할 수 있으며 사용 `certgen -h`정보가 출력됩니다.

서버에 대한 도메인 이름을 가리키고 해당 도메인 이름 및 IP 주소로 MinIO 서버를 참조하려면 다음 명령을 사용하여 MinIO 서버에 대한 인증서를 생성하십시오.

```
sudo certgen -host example.com,your-server-ip
```

서버의 IP 주소만으로 액세스를 허용할 경우는 아래와 같이 인증서를 생성하면 된다.

```bash
$ sudo certgen -host your-server-ip
```

정상적으로 인증서가 생성된 경우는 아래와 같이 출력된다.

```bash
Created a new certificate 'public.crt', 'private.key' valid for the following names
 - "example.com"
 - "your-server-ip"
```

만일 도메인 주소 없이 IP 만 사용한 경우는 출력이 서버의 IP만 나열된다.

생성된 파일을 명령을 수행한 디렉터리에 `public.crt, private.key` 파일로 존재한다. 따라서 위에서 기본 환경 정보로 구성했던 `/home/<user>/.minio/certs` 경로를 생성하고 파일을 이동한다.

```bash
$ sudo mkdir -p /home/<user>/.minio/certs
$ sudo mv private.key public.crt /home/<user>/.minio/certs
```

이동된 파일들에 대한 소유권을 MinIO 사용자와 그룹에 설정한다.

```bash
$ sudo chown minio-user:minio-user /home/<user>/.minio/certs/private.key
$ sudo chown minio-user:minio-user /home/<user>/.minio/certs/public.crt
```
#### STEP 5: MinIO 서버 시작

아래의 명령으로 `systemd`를 이용한 서비스로 MinIO를 구동한다.

```bash
$ sudo systemctl start minio
```

아래의 명령으로 실행된 MinIO 상태를 확인한다.

```bash
$ sudo systemctl status minio
minio.service - MinIO
     Loaded: loaded (/etc/systemd/system/minio.service; disabled; vendor preset: enabled)
     Active: active (running) since Mon 2022-05-23 02:55:03 UTC; 2s ago
       Docs: https://docs.min.io
    Process: 21978 ExecStartPre=/bin/bash -c if [ -z "${MINIO_VOLUMES}" ]; then echo "Variable MINIO_VOLUMES not set in /etc/default>
   Main PID: 21989 (minio)
      Tasks: 7
     Memory: 49.5M
     CGroup: /system.slice/minio.service
             └─21989 /usr/local/bin/minio server --certs-dir /home/finid/.minio/certs --console-address :9001 /mnt/data

May 23 02:55:03 minio-buntu systemd[1]: Starting MinIO...
May 23 02:55:03 minio-buntu systemd[1]: Started MinIO.
May 23 02:55:03 minio-buntu minio[21989]: WARNING: Detected default credentials 'minioadmin:minioadmin', we recommend that you chang>
May 23 02:55:03 minio-buntu minio[21989]: API: https://161.35.115.223:9000  https://10.10.0.6:9000  https://10.116.0.3:9000  https:/>
May 23 02:55:03 minio-buntu minio[21989]: Console: https://161.35.115.223:9001 https://10.10.0.6:9001 https://10.116.0.3:9001 https:>
May 23 02:55:03 minio-buntu minio[21989]: Documentation: https://docs.min.io
May 23 02:55:03 minio-buntu minio[21989]: Finished loading IAM sub-system (took 0.0s of 0.0s to load data).
```

출력된 내용과 같이 API 및 콘솔이 `https`로 작동하고 있는 것을 볼 수 있다.

만일 `http`로 구동되었거나 다른 오류가 발생한 상황이라면 `sudo journalctl -u minio` 또는 `sudo grep minio /var/log/syslog` 파일의 내용을 확인해 봐야 한다.

#### STEP 6: MinIO 콘솔을 통해 MinIO 서버에 연결

[MinIO 콘솔은](https://docs.min.io/minio/baremetal/console/minio-console.html) 액세스 로그 모니터링 및 서버 구성과 같은 관리 작업을 수행하기 위한 그래픽 인터페이스이므로 콘솔을 통해 MinIO 서버에 연결한다.

브라우저를 열고 `https://your-server-ip:9001`로 접근한다. 인증서가 자체 서명된 것이기 때문에 아래와 같은 표시가 발생한다.

[브라우저 보안 예외](https://assets.digitalocean.com/articles/68195/eiK912n2.png)

Firefox 브라우저를 사용하는 경우는 **Advanced… 를** 클릭한 다음 **Accept the Risk and Continue 를** 클릭하고 진행하면 된다. 다른 브라우저의 경우에도 유사한 과정을 거치면 된다.

정상적이라면 아래와 같이 MinIO 콘솔 로그인 화면이 나타난다.

![MinIO 콘솔의 로그인 화면](https://assets.digitalocean.com/articles/68195/TPusAUf.png)

2단계에서 생성한 MinIO의 환경 파일에 구성된 자격 증명으로 로그인한다. 로그인에 성공하면 기본 인터페이스가 다음과 같이 로드된다.

![MinIO 콘솔의 메인 인터페이스](https://assets.digitalocean.com/articles/68195/v4M7DMU.png)

콘솔 인터페이스에서 로그 보기와 같은 관리 작업을 수행할 수 있으며, 버킷, 사용자 및 그룹 생성 및 관리 및 기타 서버 구성 작업을 할 수 있다.

#### STEP 7: 로컬 컴퓨터에 MinIO 클라이언트 설치 및 사용 (이부분은 개별 테스트용)

MinIO 클라이언트는 로컬 컴퓨터에 설치하고 MinIO 서버를 관리하는 데 사용하는 MinIO의 구성 요소다. 모든 명령은 로컬 컴퓨터의 명령줄에서 수행한다. MinIO 서버와 마찬가지로 클라이언트는 바이너리 파일 또는 `.deb`패키지에서 설치할 수 있습니다. 여기서는 패키지를 사용하여 설치한다.

[로컬 시스템의 새 터미널 세션에서 MinIO 다운로드 페이지](https://min.io/download#/linux) 에서 최신 MinIO 클라이언트를 다운로드 한다.

##### Binary

```bash
# binary download
$ wget https://dl.min.io/client/mc/release/linux-amd64/mc 

# 권한 설정
$ chmod +x mc 

# 실행 별칭 선언
$ mc alias set <alias name>/ http://<minio server ip or domain> <user> <password>
```

##### Dep 패키지

```bash
# package download
$ wget https://dl.min.io/client/mc/release/linux-amd64/mcli_20230323200304.0.0_amd64.deb 

# package 설치
$ dpkg -i mcli_20230323200304.0.0_amd64.deb 

# 실행 별칭 선언
$ mcli alias set <alias name>/ http://<minio server ip or domain> <user> <password>

# 자동 완성 설정
$ mcli --autocompletion
mcli: Configuration written to `/home/sammy/.mcli/config.json`. Please update your access credentials.
mcli: Successfully created `/home/sammy/.mcli/share`.
mcli: Initialized share uploads `/home/sammy/.mcli/share/uploads.json` file.
mcli: Initialized share downloads `/home/sammy/.mcli/share/downloads.json` file.
mcli: Your shell is set to 'bash', by env var 'SHELL'.
mcli: enabled autocompletion in your 'bash' rc file. Please restart your shell.
```

출력을 통해서 숨겨진 구성 폴더와 하위 폴더 및 구성 파일의 위치를 알 수 있다.

재 시작 없이 자동 완성을 활성화하기 위해서 아래의 명령을 수행한다.

```bash
$ source .profile
```

기본 구성 파일에는 MinIO 클라이언트를 사용하여 관리할 수 있는 MinIO 서버의 액세스 자격 증명이 포함되어 있으며, 터미널 편집기에서 파일을 편집하거나 를 사용하여 항목을 추가할 수 있습니다

구성 파일에 MinIO 서버에 대한 항목을 추가하려면 2단계에서 서버에 대해 설정한 자격 증명과 함께 아래의 명령을 사용한다.

```bash
mcli --insecure alias set <aliaas name>/ https://your-server-ip:9000 minioadmin minioadmin
```

자체 서명된 인증서를 사용하기 있기 때문에 `--insecure` 옵션을 지정해야 한다. 즉, 인증서의 진위 여부를 확인하려고 시도하는 것을 방지하기 위한 것이다.

변경된 내용은 `~/.mcli/config.json` 파일에 존재한다.

```bash
$ sudo nano ~/.mcli/config.json
{
  "version": "10",
  "aliases": {
    ...
    "<alias name>": {
      "url": "https://your_server_ip:9000",
      "accessKey": "minioadmin",
      "secretKey": "minioadmin",
      "api": "S3v4",
      "path": "auto"
    },
    ...
  }
```

명령에 대한 자세한 정보는 아래의 명령을 통해 확인할 수 있다.

```bash
$ mcli -h

```

이제 클라이언트와 함께 제공되는 명령을 탐색할 준비가 되었습니다. `-h`도움말 페이지를 인쇄하려면 플래그 와 함께 실행하십시오 .

```
mcli -h 
OutputCOMMANDS:
  alias      manage server credentials in configuration file
  ls         list buckets and objects
  mb         make a bucket
  rb         remove a bucket
  cp         copy objects
  mv         move objects
  rm         remove object(s)
  mirror     synchronize object(s) to a remote site
  cat        display object contents
  head       display first 'n' lines of an object
...
...

GLOBAL FLAGS:
  --autocompletion              install auto-completion for your shell
  --config-dir value, -C value  path to configuration folder (default: "/home/finid/.mcli")
  --quiet, -q                   disable progress bar display
  --no-color                    disable color theme
  --json                        enable JSON lines formatted output
  --debug                       enable debug output
  --insecure                    disable SSL certificate verification
  --help, -h                    show help
  --version, -v                 print the version
```

MinIO 서버에 대한 정보를 수집하려면 다음을 명령을 사용한다.

```bash
$ mcli --insecure admin info <alias name>
●  your-server-ip:9000
   Uptime: 8 hours 
   Version: 2022-05-19T18:20:59Z
```

MinIO 서버가 실행 중인 상태에서 아래의 명령을 통해 다시 시작시킬 수 있다.

```bash
$ mcli --insecure admin service restart <alias name>
```

또한 이미 중지 상태인 MinIO 서버를 시작시킬 수는 없기 때문에 서버에 로그인해서 5단계처럼 시작해야 한다. 단, 구동 중인 MinIO 서버를 종료시킬 수는 있다.

```bash
mcli --insecure admin service stop <alias name>
```