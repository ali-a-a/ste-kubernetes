#!/bin/bash

kubeste version || { echo "kubeste is not configured" >&2; exit 1; }

bash -c "cat > /etc/ste-kubernetes/node/pki/openssl-$(hostname -s).cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $(hostname -s)
IP.1 = $(hostname -i)
EOF"

openssl genrsa -out /etc/ste-kubernetes/node/pki/"$(hostname -s)".key 2048
openssl req -new -key /etc/ste-kubernetes/node/pki/"$(hostname -s)".key -subj "/CN=system:node:'$(hostname -s)'/O=system:nodes" -out /etc/ste-kubernetes/node/pki/"$(hostname -s)".csr -config /etc/ste-kubernetes/node/pki/openssl-"$(hostname -s)".cnf
openssl x509 -req -in /etc/ste-kubernetes/node/pki/"$(hostname -s)".csr -CA /etc/ste-kubernetes/pki/ca.crt -CAkey /etc/ste-kubernetes/pki/ca.key -CAcreateserial  -out /etc/ste-kubernetes/node/pki/"$(hostname -s)".crt -extensions v3_req -extfile /etc/ste-kubernetes/node/pki/openssl-"$(hostname -s)".cnf -days 1000

API_SERVER_IP_ADDRESS=$1

if [ -z "$API_SERVER_IP_ADDRESS" ]; then
  echo "API_SERVER_IP_ADDRESS is not set"
  exit 1
fi

kubectl config set-cluster ste-kubernetes \
    --certificate-authority=/etc/ste-kubernetes/pki/ca.crt \
    --server=https://"$API_SERVER_IP_ADDRESS":6443 \
    --kubeconfig=/etc/ste-kubernetes/.kube/"$(hostname -s)".kubeconfig

kubectl config set-credentials system:node:"$(hostname -s)" \
  --client-certificate=/etc/ste-kubernetes/node/pki/"$(hostname -s)".crt \
  --client-key=/etc/ste-kubernetes/node/pki/"$(hostname -s)".key \
  --kubeconfig=/etc/ste-kubernetes/.kube/"$(hostname -s)".kubeconfig

kubectl config set-context default \
  --cluster=ste-kubernetes \
  --user=system:node:"$(hostname -s)" \
  --kubeconfig=/etc/ste-kubernetes/.kube/"$(hostname -s)".kubeconfig

kubectl config use-context default --kubeconfig=/etc/ste-kubernetes/.kube/"$(hostname -s)".kubeconfig
