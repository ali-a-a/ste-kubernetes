#!/bin/bash

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