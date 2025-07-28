#!/bin/bash

# Build the kube proxy using this command inside the ali-a-a/ste-kubernetes.git repository.
# go build -o /etc/ste-kubernetes/bin/kube-proxy \
#  -ldflags="-X k8s.io/component-base/version.gitVersion=v1.32.0" ./cmd/kube-proxy

kubectl --kubeconfig=/etc/ste-kubernetes/.kube/admin.kubeconfig patch clusterrole system:node --type='json' -p='[
  {
    "op": "add",
    "path": "/rules/-",
    "value": {
      "apiGroups": ["discovery.k8s.io"],
      "resources": ["endpointslices"],
      "verbs": ["get", "list", "watch"]
    }
  }
]'

kubectl --kubeconfig=/etc/ste-kubernetes/.kube/admin.kubeconfig apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:node
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:node
subjects:
- kind: Group
  name: system:nodes
  apiGroup: rbac.authorization.k8s.io
EOF

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