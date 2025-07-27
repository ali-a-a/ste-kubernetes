#!/bin/bash

which kubelet && which kubectl && echo "Kubelet and Kubectl are already installed" && exit 0

ARCH=$(uname -m)

# Only support two architectures
if [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
else
    ARCH="arm64"
fi

# STE works with v1.32
curl -LO "https://dl.k8s.io/release/v1.32.0/bin/linux/${ARCH}/kubectl"
curl -LO "https://dl.k8s.io/release/v1.32.0/bin/linux/${ARCH}/kubelet"

# Move binary files to the bin directory
chmod +x kubectl && mv -f kubectl /usr/bin/kubectl 2>/dev/null
chmod +x kubelet && mv -f kubelet /usr/bin/kubelet 2>/dev/null

# Verify the installation is complete
kubectl version --client
kubelet --version
