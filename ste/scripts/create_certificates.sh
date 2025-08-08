#!/bin/bash

# Location of STE certificates
mkdir -p /etc/ste-kubernetes/pki

# Create a private key for CA
openssl genrsa -out /etc/ste-kubernetes/pki/ca.key 2048
# Create a new certificate signing request
openssl req -new -key /etc/ste-kubernetes/pki/ca.key -subj "/CN=KUBERNETES-CA/O=Kubernetes" -out /etc/ste-kubernetes/pki/ca.csr
# Generate the certificate using the private key
openssl x509 -req -in /etc/ste-kubernetes/pki/ca.csr -signkey /etc/ste-kubernetes/pki/ca.key -out /etc/ste-kubernetes/pki/ca.crt -days 1000

# Create a private key for the admin
openssl genrsa -out /etc/ste-kubernetes/pki/admin.key 2048
# Create a new certificate signing request
openssl req -new -key /etc/ste-kubernetes/pki/admin.key -subj "/CN=admin/O=system:masters" -out /etc/ste-kubernetes/pki/admin.csr
# Generate the admin certificate using the private key
openssl x509 -req -in /etc/ste-kubernetes/pki/admin.csr -CA /etc/ste-kubernetes/pki/ca.crt -CAkey /etc/ste-kubernetes/pki/ca.key -CAcreateserial -out /etc/ste-kubernetes/pki/admin.crt -days 1000

# Create a private key for the controller manager
openssl genrsa -out /etc/ste-kubernetes/pki/kube-controller-manager.key 2048
# Create a new certificate signing request
openssl req -new -key /etc/ste-kubernetes/pki/kube-controller-manager.key \
-subj "/CN=system:kube-controller-manager/O=system:kube-controller-manager" -out /etc/ste-kubernetes/pki/kube-controller-manager.csr
# Generate the controller manager certificate using the private key
openssl x509 -req -in /etc/ste-kubernetes/pki/kube-controller-manager.csr \
-CA /etc/ste-kubernetes/pki/ca.crt -CAkey /etc/ste-kubernetes/pki/ca.key -CAcreateserial -out /etc/ste-kubernetes/pki/kube-controller-manager.crt -days 1000

# Create a private key for the kube proxy
openssl genrsa -out /etc/ste-kubernetes/pki/kube-proxy.key 2048
# Create a new certificate signing request
openssl req -new -key /etc/ste-kubernetes/pki/kube-proxy.key \
-subj "/CN=system:kube-proxy/O=system:node-proxier" -out /etc/ste-kubernetes/pki/kube-proxy.csr
# Generate the kube proxy certificate using the private key
openssl x509 -req -in /etc/ste-kubernetes/pki/kube-proxy.csr \
-CA /etc/ste-kubernetes/pki/ca.crt -CAkey /etc/ste-kubernetes/pki/ca.key -CAcreateserial -out /etc/ste-kubernetes/pki/kube-proxy.crt -days 1000

# Create a private key for the kube scheduler
openssl genrsa -out /etc/ste-kubernetes/pki/kube-scheduler.key 2048
# Create a new certificate signing request
openssl req -new -key /etc/ste-kubernetes/pki/kube-scheduler.key \
-subj "/CN=system:kube-scheduler/O=system:kube-scheduler" -out /etc/ste-kubernetes/pki/kube-scheduler.csr
# Generate the kube scheduler certificate using the private key
openssl x509 -req -in /etc/ste-kubernetes/pki/kube-scheduler.csr -CA /etc/ste-kubernetes/pki/ca.crt -CAkey /etc/ste-kubernetes/pki/ca.key -CAcreateserial -out /etc/ste-kubernetes/pki/kube-scheduler.crt -days 1000

# Specify all ip addresses, DNS names, and etc that may reach the api server. IP.3 and IP.4 can be provided
# as command-line arguments
bash -c "cat > /etc/ste-kubernetes/pki/openssl.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[v3_req]
basicConstraints = critical, CA:FALSE
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster
DNS.5 = kubernetes.default.svc.cluster.local
IP.1 = 127.0.0.1
IP.2 = $(hostname -i)
IP.3 = ${1:-127.0.0.1}
IP.4 = ${2:-127.0.0.1}
IP.5 = 10.96.0.1
EOF"

# Create a private key for the kube api server
openssl genrsa -out /etc/ste-kubernetes/pki/kube-apiserver.key 2048
# Create a new certificate signing request
openssl req -new -key /etc/ste-kubernetes/pki/kube-apiserver.key \
-subj "/CN=kube-apiserver/O=Kubernetes" -out /etc/ste-kubernetes/pki/kube-apiserver.csr -config /etc/ste-kubernetes/pki/openssl.cnf
# Generate the kube api server certificate using the private key
openssl x509 -req -in /etc/ste-kubernetes/pki/kube-apiserver.csr \
-CA /etc/ste-kubernetes/pki/ca.crt -CAkey /etc/ste-kubernetes/pki/ca.key -CAcreateserial -out /etc/ste-kubernetes/pki/kube-apiserver.crt -extensions v3_req -extfile /etc/ste-kubernetes/pki/openssl.cnf -days 1000

# Kubelet openssl config file
bash -c "cat > /etc/ste-kubernetes/pki/openssl-kubelet.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[v3_req]
basicConstraints = critical, CA:FALSE
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth
EOF"

# Create a private key for the kubelet
openssl genrsa -out /etc/ste-kubernetes/pki/apiserver-kubelet-client.key 2048
# Create a new certificate signing request
openssl req -new -key /etc/ste-kubernetes/pki/apiserver-kubelet-client.key \
-subj "/CN=kube-apiserver-kubelet-client/O=system:masters" -out /etc/ste-kubernetes/pki/apiserver-kubelet-client.csr -config /etc/ste-kubernetes/pki/openssl-kubelet.cnf
# Generate the kubelet certificate using the private key
openssl x509 -req -in /etc/ste-kubernetes/pki/apiserver-kubelet-client.csr \
-CA /etc/ste-kubernetes/pki/ca.crt -CAkey /etc/ste-kubernetes/pki/ca.key -CAcreateserial -out /etc/ste-kubernetes/pki/apiserver-kubelet-client.crt -extensions v3_req -extfile /etc/ste-kubernetes/pki/openssl-kubelet.cnf -days 1000

# Etcd openssl certificate
bash -c "cat > /etc/ste-kubernetes/pki/openssl-etcd.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
IP.1 = 127.0.0.1
IP.2 = $(hostname -i)
IP.3 = ${1:-127.0.0.1}
IP.4 = 10.0.3.9
IP.5 = 10.0.3.10
EOF"

# Create a private key for etcd
openssl genrsa -out /etc/ste-kubernetes/pki/etcd-server.key 2048
# Create a new certificate signing request
openssl req -new -key /etc/ste-kubernetes/pki/etcd-server.key \
-subj "/CN=etcd-server/O=Kubernetes" -out /etc/ste-kubernetes/pki/etcd-server.csr -config /etc/ste-kubernetes/pki/openssl-etcd.cnf
# Generate the etcd certificate using the private key
openssl x509 -req -in /etc/ste-kubernetes/pki/etcd-server.csr \
-CA /etc/ste-kubernetes/pki/ca.crt -CAkey /etc/ste-kubernetes/pki/ca.key -CAcreateserial -out /etc/ste-kubernetes/pki/etcd-server.crt -extensions v3_req -extfile /etc/ste-kubernetes/pki/openssl-etcd.cnf -days 1000

# Create a private key for the service account
openssl genrsa -out /etc/ste-kubernetes/pki/service-account.key 2048
# Create a new certificate signing request
openssl req -new -key /etc/ste-kubernetes/pki/service-account.key \
-subj "/CN=service-accounts/O=Kubernetes" -out /etc/ste-kubernetes/pki/service-account.csr
# Generate the service account certificate using the private key
openssl x509 -req -in /etc/ste-kubernetes/pki/service-account.csr \
-CA /etc/ste-kubernetes/pki/ca.crt -CAkey /etc/ste-kubernetes/pki/ca.key -CAcreateserial -out /etc/ste-kubernetes/pki/service-account.crt -days 1000

# Create a private key for the front proxy CA
openssl genrsa -out /etc/ste-kubernetes/pki/front-proxy-ca.key 2048
# Generate the front proxy CA certificate using the private key
openssl req -x509 -new -nodes -key /etc/ste-kubernetes/pki/front-proxy-ca.key -subj "/CN=front-proxy-ca/O=Kubernetes" -days 10000 -out /etc/ste-kubernetes/pki/front-proxy-ca.crt

bash -c "cat > /etc/ste-kubernetes/pki/openssl-front-proxy.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[v3_req]
basicConstraints = critical, CA:FALSE
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth
EOF"

# Create a private key for the front proxy
openssl genrsa -out /etc/ste-kubernetes/pki/front-proxy-client.key 2048
# Create a new certificate signing request
openssl req -new -key /etc/ste-kubernetes/pki/front-proxy-client.key -subj "/CN=front-proxy-client/O=Kubernetes" -out /etc/ste-kubernetes/pki/front-proxy-client.csr
# Generate the front proxy certificate using the private key
openssl x509 -req -in /etc/ste-kubernetes/pki/front-proxy-client.csr -CA /etc/ste-kubernetes/pki/front-proxy-ca.crt -CAkey /etc/ste-kubernetes/pki/front-proxy-ca.key -CAcreateserial \
  -out /etc/ste-kubernetes/pki/front-proxy-client.crt -days 10000 -extensions v3_req -extfile /etc/ste-kubernetes/pki/openssl-front-proxy.cnf
