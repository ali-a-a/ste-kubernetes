#!/bin/bash

# Build the kube scheduler using this command inside the ali-a-a/ste-kubernetes.git repository.
# go build -o /etc/ste-kubernetes/bin/kube-scheduler \
#  -ldflags="-X k8s.io/component-base/version.gitVersion=v1.32.0" ./cmd/kube-scheduler

# If the session exists, exit
if tmux has-session -t kube-scheduler 2>/dev/null; then
  echo "Session kube-scheduler exists. Exiting..."
  exit 0
fi

# Create the tmux session
tmux new -s kube-scheduler

# Run the kube scheduler
tmux send-keys -t kube-scheduler "/etc/ste-kubernetes/bin/kube-scheduler \
--kubeconfig=/etc/ste-kubernetes/.kube/kube-scheduler.kubeconfig \
--requestheader-client-ca-file=/etc/ste-kubernetes/pki/ca.crt \
--leader-elect=false" ENTER