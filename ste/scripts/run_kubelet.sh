#!/bin/bash

# Build the kubelet using this command inside the ali-a-a/ste-kubernetes.git repository.
# go build -o /etc/ste-kubernetes/bin/kubelet \
#  -ldflags="-X k8s.io/component-base/version.gitVersion=v1.32.0" ./cmd/kubelet

# If the session exists, exit
if tmux has-session -t kubelet 2>/dev/null; then
  echo "Session kubelet exists. Exiting..."
  exit 0
fi

# Create the tmux session
tmux new -s kubelet

# Create the kubelet config
bash -c "cat > /etc/ste-kubernetes/pki/kubelet-config.yaml <<EOF
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: \"ca.crt\"
authorization:
  mode: Webhook
clusterDomain: cluster.local
clusterDNS:
- 10.96.0.10
resolvConf: /run/systemd/resolve/resolv.conf
runtimeRequestTimeout: \"15m\"
cgroupDriver: systemd
cpuCFSQuota: false
maxPods: 60
memoryThrottlingFactor: 0.999
EOF"

# Run the kubelet
tmux send-keys -t kubelet "/etc/ste-kubernetes/bin/kubelet \
--config=/etc/ste-kubernetes/pki/kubelet-config.yaml \
--kubeconfig=/etc/ste-kubernetes/.kube/"$(hostname -s)".kubeconfig \
--tls-cert-file=/etc/ste-kubernetes/node/pki/"$(hostname -s)".crt \
--tls-private-key-file=/etc/ste-kubernetes/node/pki/"$(hostname -s)".key \
--register-node=true \
--runtime-cgroups=/systemd/system.slice \
--kubelet-cgroups=/systemd/system.slice \
--cpu-cfs-quota=false" ENTER
