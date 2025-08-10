#!/bin/bash

# Build the kube controller manager using this command inside the ali-a-a/ste-kubernetes.git repository.
# go build -o /etc/ste-kubernetes/bin/kube-controller-manager \
#  -ldflags="-X k8s.io/component-base/version.gitVersion=v1.32.0" ./cmd/kube-controller-manager

# If the session exists, exit
if tmux has-session -t kube-controller-manager 2>/dev/null; then
  echo "Session kube-controller-manager exists. Exiting..."
  exit 0
fi

# Create the tmux session
tmux new -d -s kube-controller-manager

# Run the kube controller manager
tmux send-keys -t kube-controller-manager "/etc/ste-kubernetes/bin/kube-controller-manager \
--authentication-kubeconfig=/etc/ste-kubernetes/.kube/kube-controller-manager.kubeconfig \
--authorization-kubeconfig=/etc/ste-kubernetes/.kube/kube-controller-manager.kubeconfig \
--bind-address=127.0.0.1 \
--client-ca-file=/etc/ste-kubernetes/pki/ca.crt \
--cluster-name=ste-kubernetes \
--cluster-signing-cert-file=/etc/ste-kubernetes/pki/ca.crt \
--cluster-signing-key-file=/etc/ste-kubernetes/pki/ca.key \
--controllers=*,bootstrapsigner,tokencleaner \
--kubeconfig=/etc/ste-kubernetes/.kube/kube-controller-manager.kubeconfig \
--leader-elect=false \
--requestheader-client-ca-file=/etc/ste-kubernetes/pki/ca.crt \
--root-ca-file=/etc/ste-kubernetes/pki/ca.crt \
--service-account-private-key-file=/etc/ste-kubernetes/pki/service-account.key \
--use-service-account-credentials=true" ENTER
