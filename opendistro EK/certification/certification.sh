

# Root CA
openssl genrsa -out ca.key 2048
openssl req -x509 -new -sha256 -nodes -key ca.key -days 36500 -subj "/CN=RootCA" -out ca.crt -extensions v3_ca -config ./openssl.cnf

# Admin Cert
openssl genrsa -out admin.key.temp 2048
openssl pkcs8 -inform PEM -outform PEM -in admin.key.temp -topk8 -nocrypt -v1 PBE-SHA1-3DES -out admin.key

openssl req -new -key admin.key -out admin.csr -subj "/CN=admin" -config ./openssl.cnf
openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -CAcreateserial -sha256 -out admin.crt -days 36500 -extensions v3_req_client -extfile ./openssl.cnf

# Node Cert
openssl genrsa -out node.key.temp 2048
openssl pkcs8 -inform PEM -outform PEM -in node.key.temp -topk8 -nocrypt -v1 PBE-SHA1-3DES -out node.key

openssl req -new -key node.key -out node.csr -subj "/CN=node" -config ./openssl.cnf
openssl x509 -req -in node.csr -CA ca.crt -CAkey ca.key -CAcreateserial -sha256 -out node.crt -days 36500 -extensions v3_req_es -extfile ./openssl.cnf

# Kibana Cert
openssl genrsa -out kibana.key.temp 2048
openssl pkcs8 -inform PEM -outform PEM -in kibana.key.temp -topk8 -nocrypt -v1 PBE-SHA1-3DES -out kibana.key

openssl req -new -key kibana.key -out kibana.csr -subj "/CN=kibana" -config ./openssl.cnf
openssl x509 -req -in kibana.csr -CA ca.crt -CAkey ca.key -CAcreateserial -sha256 -out kibana.crt -days 36500 -extensions v3_req_kb -extfile ./openssl.cnf

# Elasticsearch cert
sed -i "" "s/ca.crt:/ca.crt: $(cat ca.crt | base64)/g" ../elasticsearch.yaml
sed -i "" "s/node.crt:/node.crt: $(cat node.crt ca.crt | base64)/g" ../elasticsearch.yaml
sed -i "" "s/node.key:/node.key: $(cat node.key | base64)/g" ../elasticsearch.yaml
sed -i "" "s/admin.crt:/admin.crt: $(cat admin.crt ca.crt | base64)/g" ../elasticsearch.yaml
sed -i "" "s/admin.key:/admin.key: $(cat admin.key | base64)/g" ../elasticsearch.yaml
sed -i "" "s/tls.crt:/tls.crt: $(cat node.crt ca.crt | base64)/g" ../elasticsearch.yaml
sed -i "" "s/tls.key:/tls.key: $(cat node.key | base64)/g" ../elasticsearch.yaml

# Kibana cert
sed -i "" "s/ca.crt:/ca.crt: $(cat ca.crt | base64)/g" ../kibana.yaml
sed -i "" "s/kibana.crt:/kibana.crt: $(cat kibana.crt ca.crt | base64)/g" ../kibana.yaml
sed -i "" "s/kibana.key:/kibana.key: $(cat kibana.key | base64)/g" ../kibana.yaml
sed -i "" "s/tls.crt:/tls.crt: $(cat k3lab-star-tls.crt | base64)/g" ../kibana.yaml
sed -i "" "s/tls.key:/tls.key: $(cat k3lab-star-tls.key | base64)/g" ../kibana.yaml

# Fluentbit cert
sed -i "" "s/ca.crt:/ca.crt: $(cat ca.crt | base64)/g" ../fluentbit.yaml