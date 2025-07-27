#!/bin/bash

# Check whether the the data directory is clean
if [ -d /etc/ste-kubernetes/source/ste-kubernetes ]; then
  echo "ali-a-a/ste-kubernetes.git is found"
else
  echo "You should clone the ali-a-a/ste-kubernetes.git repository in the /etc/ste-kubernetes/source/ directory"
  exit 1
fi

# Go should be installed
go version || { echo "go is not installed" >&2; exit 1; }

# Build the kube apiserver
go build -o /etc/ste-kubernetes/bin \
  -ldflags="-X k8s.io/component-base/version.gitVersion=v1.32.0" /etc/ste-kubernetes/source/ste-kubernetes/cmd/kube-apiserver

# If the session exists, exit
if tmux has-session -t kube-apiserver 2>/dev/null; then
  echo "Session kube-apiserver exists. Exiting..."
  exit 0
fi

# Create the tmux session
tmux new -s kube-apiserver

# Run the kube apiserver
tmux send-keys -t persistent-etcd "/etc/ste-kubernetes/bin/kube-apiserver \
--advertise-address=$(hostname -i) \
--allow-privileged=true \
--audit-log-maxage=30 \
--audit-log-maxbackup=3 \
--audit-log-maxsize=100 \
--audit-log-path=/etc/ste-kubernetes/logs/kube-apiserver-audit.log \
--authorization-mode=Node,RBAC \
--bind-address=0.0.0.0 \
--client-ca-file=/etc/ste-kubernetes/pki/ca.crt \
--enable-admission-plugins=NodeRestriction,ServiceAccount \
--enable-bootstrap-token-auth=true \
--etcd-cafile=/etc/ste-kubernetes/pki/ca.crt \
--etcd-certfile=/etc/ste-kubernetes/pki/etcd-server.crt \
--etcd-keyfile=/etc/ste-kubernetes/pki/etcd-server.key \
--etcd-servers=https://127.0.0.1:2379 \
--event-ttl=1h \
--proxy-client-cert-file=/etc/ste-kubernetes/pki/front-proxy-client.crt \
--proxy-client-key-file=/etc/ste-kubernetes/pki/front-proxy-client.key \
--requestheader-allowed-names=front-proxy-client \
--requestheader-client-ca-file=/etc/ste-kubernetes/pki/front-proxy-ca.crt \
--requestheader-extra-headers-prefix=X-Remote-Extra- \
--requestheader-group-headers=X-Remote-Group \
--requestheader-username-headers=X-Remote-User \
--kubelet-certificate-authority=/etc/ste-kubernetes/pki/ca.crt \
--kubelet-client-certificate=/etc/ste-kubernetes/pki/apiserver-kubelet-client.crt \
--kubelet-client-key=/etc/ste-kubernetes/pki/apiserver-kubelet-client.key \
--runtime-config=api/all=true \
--service-account-key-file=/etc/ste-kubernetes/pki/service-account.crt \
--service-account-signing-key-file=/etc/ste-kubernetes/pki/service-account.key \
--service-account-issuer=https://127.0.0.1:6443 \
--service-node-port-range=30000-32767 \
--service-cluster-ip-range=10.96.0.0/12 \
--tls-cert-file=/etc/ste-kubernetes/pki/kube-apiserver.crt \
--tls-private-key-file=/etc/ste-kubernetes/pki/kube-apiserver.key \
--max-mutating-requests-inflight 1000000 \
--max-requests-inflight 1000000 \
--enable-priority-and-fairness=false \
--fast-storage-shards https://127.0.0.1:2179 \
--v=0" ENTER