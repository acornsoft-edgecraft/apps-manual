## Kong 설치 방법

### 1. Repository 등록
> ca.crt  다운로드 URL : https://regi.k3.acornsoft.io/ca.crt
```sh
helm repo add --ca-file ./ca.crt k3lab https://192.168.77.30/chartrepo/k3lab-charts
```

### 2. kong-values.yaml 정의
```yaml

...............................

# -----------------------------------------------------------------------------
# Kong parameters
# -----------------------------------------------------------------------------

# Specify Kong configuration
# This chart takes all entries defined under `.env` and transforms them into into `KONG_*`
# environment variables for Kong containers.
# Their names here should match the names used in https://github.com/Kong/kong/blob/master/kong.conf.default
# See https://docs.konghq.com/latest/configuration also for additional details
# Values here take precedence over values from other sections of values.yaml,
# e.g. setting pg_user here will override the value normally set when postgresql.enabled
# is set below. In general, you should not set values here if they are set elsewhere.
env:
    database: "postgres"
    pg_host : kong-pgsql
    pg_port : 5432
    pg_timeout : 5000
    pg_user : konga
    pg_password : konga
    pg_database : kong
    nginx_worker_processes: "2"
    proxy_access_log: /dev/stdout
    admin_access_log: /dev/stdout
    admin_gui_access_log: /dev/stdout
    portal_api_access_log: /dev/stdout
    proxy_error_log: /dev/stderr
    admin_error_log: /dev/stderr
    admin_gui_error_log: /dev/stderr
    portal_api_error_log: /dev/stderr
    prefix: /kong_prefix/

...............................

# Specify Kong admin API service and listener configuration
admin:
  # Enable creating a Kubernetes service for the admin API
  # Disabling this is recommended for most ingress controller configurations
  # Enterprise users that wish to use Kong Manager with the controller should enable this
  enabled: true

..................................

# -----------------------------------------------------------------------------
# Postgres sub-chart parameters
# -----------------------------------------------------------------------------

# Kong can run without a database or use either Postgres or Cassandra
# as a backend datatstore for it's configuration.
# By default, this chart installs Kong without a database.

# If you would like to use a database, there are two options:
# - (recommended) Deploy and maintain a database and pass the connection
#   details to Kong via the `env` section.
# - You can use the below `postgresql` sub-chart to deploy a database
#   along-with Kong as part of a single Helm release.

# PostgreSQL chart documentation:
# https://github.com/bitnami/charts/blob/master/bitnami/postgresql/README.md

postgresql:
  enabled: true
    postgresqlUsername: konga
    postgresqlPassword: konga
    postgresqlDatabase: kong
    service:
      port: 5432

..................................

```

### 3. kong 설치
```
$ helm upgrade -i kong k3lab/kong --cleanup-on-fail -f kong-values.yaml -n namespaces
```

