# Openstack Orchestration 개용

## Openstack-heat 설치와 설정

### 선행조건
Orchestration 서비스를 설치하고 구성하기 전에, 데이터베이스, 서비스 credential, 그리고 API 엔드포인트를 생성해야 합니다. Orchestration은 또한 Identity 서비스에서 부가적인 정보를 필요로합니다.

1. 데이터베이스를 생성하기 위하여, 다음 과정을 완료해야 합니다:
  - 데이터베이스 액세스 클라이언트를 사용하여 데이터베이스 서버에 root 사용자로 연결합니다:
    ```sh
    ## default password: root
    $ mysql -u root -p
    ```
  - heat 데이터베이스를 생성합니다:
    ```mysql
    CREATE DATABASE heat;
    ```
  - heat 데이터베이스에 대해 적합한 액세스를 부여합니다:
    ```mysql
    ## HEAT_DBPASS 를 적절한 암호로 변경합니다.
    GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'localhost' \
      IDENTIFIED BY 'HEAT_DBPASS';
    GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'%' \
      IDENTIFIED BY 'HEAT_DBPASS';
    ```
  - 데이터베이스 접속 클라이언트를 종료합니다.

2. admin credential을 소스로 사용하여 관리자 전용 CLI 명령어에 대한 액세스를 갖습니다:
```
$ source admin-openrc.sh
```

3. 서비스 credential을 생성하기 위해, 다음 스텝들을 완료합니다:
  - heat 사용자를 생성합니다:
    ```sh
    ## default password: heat
    $ openstack user create --domain default --password-prompt heat
    User Password:
    Repeat User Password:
    +---------------------+----------------------------------+
    | Field               | Value                            |
    +---------------------+----------------------------------+
    | domain_id           | default                          |
    | enabled             | True                             |
    | id                  | 8d6b2274e55549f8b1c0568c8bb6cf26 |
    | name                | heat                             |
    | options             | {}                               |
    | password_expires_at | None                             |
    +---------------------+----------------------------------+
    ```
  - admin 역할을 heat 사용자에 추가합니다:
    ```sh
    ## 이 명령어는 출력이 없습니다.
    $ openstack role add --project service --user heat admin
    ```
  - heat 과 heat-cfn 서비스 엔티티를 생성합니다:
    ```sh
    ## create service: orchestration
    $ openstack service create --name heat \
      --description "Orchestration" orchestration
    +-------------+----------------------------------+
    | Field       | Value                            |
    +-------------+----------------------------------+
    | description | Orchestration                    |
    | enabled     | True                             |
    | id          | 1a9a5e865ce9409c879f192714871819 |
    | name        | heat                             |
    | type        | orchestration                    |
    +-------------+----------------------------------+

    ## create service: cloudformation
    $ openstack service create --name heat-cfn \
      --description "Orchestration"  cloudformation
    +-------------+----------------------------------+
    | Field       | Value                            |
    +-------------+----------------------------------+
    | description | Orchestration                    |
    | enabled     | True                             |
    | id          | 9c6585b85a9f4c20ae7aa9e841f96752 |
    | name        | heat-cfn                         |
    | type        | cloudformation                   |
    +-------------+----------------------------------+
    ```

4. Orchestration 서비스 API 엔드 포인트를 생성합니다:

```sh
## service: orchestration
$ openstack endpoint create --region RegionOne \
  orchestration public http://controller:8004/v1/%\(tenant_id\)s
+--------------+-----------------------------------------+
| Field        | Value                                   |
+--------------+-----------------------------------------+
| enabled      | True                                    |
| id           | 26fdafde135e4605b23c1dac284a07c5        |
| interface    | public                                  |
| region       | RegionOne                               |
| region_id    | RegionOne                               |
| service_id   | 1a9a5e865ce9409c879f192714871819        |
| service_name | heat                                    |
| service_type | orchestration                           |
| url          | http://controller:8004/v1/%(tenant_id)s |
+--------------+-----------------------------------------+

## service: orchestration
$ openstack endpoint create --region RegionOne \
  orchestration internal http://controller:8004/v1/%\(tenant_id\)s
+--------------+-----------------------------------------+
| Field        | Value                                   |
+--------------+-----------------------------------------+
| enabled      | True                                    |
| id           | a12f3d4fa600435bbeaddf8423cd96ad        |
| interface    | internal                                |
| region       | RegionOne                               |
| region_id    | RegionOne                               |
| service_id   | 1a9a5e865ce9409c879f192714871819        |
| service_name | heat                                    |
| service_type | orchestration                           |
| url          | http://controller:8004/v1/%(tenant_id)s |
+--------------+-----------------------------------------+

## service: orchestration
$ openstack endpoint create --region RegionOne \
  orchestration admin http://controller:8004/v1/%\(tenant_id\)s
+--------------+-----------------------------------------+
| Field        | Value                                   |
+--------------+-----------------------------------------+
| enabled      | True                                    |
| id           | a3c6aa43d5d44ab59bdf675410212874        |
| interface    | admin                                   |
| region       | RegionOne                               |
| region_id    | RegionOne                               |
| service_id   | 1a9a5e865ce9409c879f192714871819        |
| service_name | heat                                    |
| service_type | orchestration                           |
| url          | http://controller:8004/v1/%(tenant_id)s |
+--------------+-----------------------------------------+

## service: cloudformation
$ openstack endpoint create --region RegionOne \
  cloudformation public http://controller:8000/v1
+--------------+----------------------------------+
| Field        | Value                            |
+--------------+----------------------------------+
| enabled      | True                             |
| id           | f36d855c611a4c179cd45448d3c2cea8 |
| interface    | public                           |
| region       | RegionOne                        |
| region_id    | RegionOne                        |
| service_id   | 9c6585b85a9f4c20ae7aa9e841f96752 |
| service_name | heat-cfn                         |
| service_type | cloudformation                   |
| url          | http://controller:8000/v1        |
+--------------+----------------------------------+

## service: cloudformation
$ openstack endpoint create --region RegionOne \
  cloudformation internal http://controller:8000/v1
+--------------+----------------------------------+
| Field        | Value                            |
+--------------+----------------------------------+
| enabled      | True                             |
| id           | 6c1d0ecd1d44472e99105e5048f36110 |
| interface    | internal                         |
| region       | RegionOne                        |
| region_id    | RegionOne                        |
| service_id   | 9c6585b85a9f4c20ae7aa9e841f96752 |
| service_name | heat-cfn                         |
| service_type | cloudformation                   |
| url          | http://controller:8000/v1        |
+--------------+----------------------------------+

## service: cloudformation
$ openstack endpoint create --region RegionOne \
  cloudformation admin http://controller:8000/v1
+--------------+----------------------------------+
| Field        | Value                            |
+--------------+----------------------------------+
| enabled      | True                             |
| id           | 516d6e2232bc4c58bd3773adbb9d8954 |
| interface    | admin                            |
| region       | RegionOne                        |
| region_id    | RegionOne                        |
| service_id   | 9c6585b85a9f4c20ae7aa9e841f96752 |
| service_name | heat-cfn                         |
| service_type | cloudformation                   |
| url          | http://controller:8000/v1        |
+--------------+----------------------------------+
```

5. Orchestration은 stack을 관리하기 위해 Identity 서비스 내 부가적인 정보를 필요로합니다. 해당 정보를 추가하기 위해 다음 단계를 완료합니다:

- stack을 위한 프로젝트와 사용자를 포함하는 heat 도메인을 추가합니다:
```
$ openstack domain create --description "Stack projects and users" heat
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | Stack projects and users         |
| enabled     | True                             |
| id          | fc425f42066e4d99833becff0eb6a719 |
| name        | heat                             |
| options     | {}                               |
| tags        | []                               |
+-------------+----------------------------------+
```

- heat 도메인에서 프로젝트와 사용자를 관리하기 위해 heat_domain_admin 사용자를 생성합니다:
```sh
## default password: heat_domain_admin
$ openstack user create --domain heat --password-prompt heat_domain_admin
User Password:
Repeat User Password:
+---------------------+----------------------------------+
| Field               | Value                            |
+---------------------+----------------------------------+
| domain_id           | fc425f42066e4d99833becff0eb6a719 |
| enabled             | True                             |
| id                  | 7dda32797a804bfaa97c1a8bd7b2700e |
| name                | heat_domain_admin                |
| options             | {}                               |
| password_expires_at | None                             |
+---------------------+----------------------------------+
```

- heat 도메인 내 heat_domain_admin 사용자에 admin 역할을 추가하여 heat_domain_admin 사용자에게 stack 관리 작업 권한을 활성화합니다:
```sh
## 이 명령어는 출력이 없습니다.
$ openstack role add --domain heat --user-domain heat --user heat_domain_admin admin
```

- heat_stack_owner 역할을 생성합니다:
```sh
$ openstack role create heat_stack_owner
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | None                             |
| domain_id   | None                             |
| id          | 1b8baa24519c47ab9a1ad58df32813ac |
| name        | heat_stack_owner                 |
| options     | {}                               |
+-------------+----------------------------------+
```

- heat_stack_owner 역할을 onassis 프로젝트 및 사용자에 추가하여 dongmook 사용자에 대한 stack 관리를 활성화합니다:
```sh
## heat_stack_owner 역할을 stack을 관리하는 각 사용자에 추가해야 합니다.
## 이 명령어는 출력이 없습니다.
$ openstack role add --project onassis --user dongmook heat_stack_owner
```

- heat_stack_user 역할을 생성합니다:
```sh
## Orchestration 서비스는 heat_stack_user 역할을 stack 배포중에 생성되는 사용자에게 자동으로 할당합니다. 기본으로 해당 역할은 API 작업을 제한합니다. 충돌을 피하기 위해 해당 역할을 heat_stack_owner 역할을 가진 사용자에 추가하지 마십시오.
$ openstack role create heat_stack_user
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | None                             |
| domain_id   | None                             |
| id          | d31e9fa95da7416789139529df28702c |
| name        | heat_stack_user                  |
| options     | {}                               |
+-------------+----------------------------------+
```

### 구성요소 설치 및 구성
> 주석:
> 디폴트 구성 파일을 배포판에 따라 달라집니다. 기존 섹션 및 옵션을 변경하는 것 보다는 해당 섹션과 옵션을 추가해야 할 수도 있습니다. 또한 구성 내용 조각 중 생략 (...) 부분은 유지될 필요성이 있는 디폴트 구성 옵션을 가리킵니다.

1. 패키지를 설치하십시오:
    ```sh
    $ yum install openstack-heat-api openstack-heat-api-cfn \
      openstack-heat-engine
    ```

2. /etc/heat/heat.conf 파일을 편집하여 다음 작업을 완료합니다:
   - [database] 섹션에서, 데이터베이스 액세스를 구성합니다:
      ```
      [database]
      ...
      connection = mysql+pymysql://heat:HEAT_DBPASS@controller/heat
      ```