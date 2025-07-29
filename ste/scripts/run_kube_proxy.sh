#!/bin/bash

# Build the kube proxy using this command inside the ali-a-a/ste-kubernetes.git repository.
# go build -o /etc/ste-kubernetes/bin/kube-proxy \
#  -ldflags="-X k8s.io/component-base/version.gitVersion=v1.32.0" ./cmd/kube-proxy

# If the session exists, exit
if tmux has-session -t kube-proxy 2>/dev/null; then
  echo "Session kube-proxy exists. Exiting..."
  exit 0
fi

# Create the tmux session
tmux new -s kube-proxy

# Run the kube proxy
tmux send-keys -t kube-proxy "/etc/ste-kubernetes/bin/kube-proxy \
--kubeconfig=/etc/ste-kubernetes/.kube/"$(hostname -s)".kubeconfig \
--proxy-mode=iptables" ENTER
