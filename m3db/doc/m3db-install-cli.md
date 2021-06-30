# M3db Install Cli

## 소제목

##

- m3db db write / read test
```sh
curl -X "POST" -G "http://192.168.77.34:32558/api/v1/query_range" \
  -d "query=query_fetch_success" \
  -d "start=$(date "+%s" -d "10 minutes ago")" \
  -d "end=$( date "+%s" -d "1 minutes ago" )" \
  -d "step=1m" 


curl -X POST http://192.168.77.34:32555/api/v1/json/write -d '{
  "tags": {
    "__name__": "third_avenue",
    "city": "new_york",
    "checkout": "1"
  },
  "timestamp": '\"$(date "+%s")\"',
  "value": 3347.26
}' | jq .
curl -X POST http://192.168.77.34:32555/api/v1/json/write -d '{
  "tags": {
    "__name__": "third_avenue",
    "city": "new_york",
    "checkout": "2"
  },
  "timestamp": '\"$(date "+%s")\"',
  "value": 3347.44
}' | jq .
curl -X POST http://192.168.77.34:32555/api/v1/json/write -d '{
  "tags": {
    "__name__": "dongmook--dm",
    "city": "new_york",
    "checkout": "3"
  },
  "timestamp": '\"$(date "+%s")\"',
  "value": 3347.55
}' | jq .

```

# 참조
> [참조명](참조링크)