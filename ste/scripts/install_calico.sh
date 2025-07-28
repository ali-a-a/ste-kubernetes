#!/bin/bash

# Create the tigera operator
kubeste create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml

# Download custom resources for the calico project
curl https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml -O

# Create calico CRs
kubeste apply -f custom-resources.yaml

# Remove the custom-resources.yaml file
rm -rf custom-resources.yaml