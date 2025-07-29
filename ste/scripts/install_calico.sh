#!/bin/bash

# Check whether kubeste is configured or not
kubectl --kubeconfig=/etc/ste-kubernetes/.kube/admin.kubeconfig version || { echo "kubeste is not configured" >&2; exit 1; }

# Create the tigera operator
kubectl --kubeconfig=/etc/ste-kubernetes/.kube/admin.kubeconfig create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml

# Download custom resources for the calico project
curl https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml -O

# Create calico CRs
kubectl --kubeconfig=/etc/ste-kubernetes/.kube/admin.kubeconfig apply -f custom-resources.yaml

# Remove the custom-resources.yaml file
rm -rf custom-resources.yaml
