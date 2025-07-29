#!/bin/bash

# Check if etcd is installed
etcd --version && echo "etcd is already installed" && exit 0

ARCH=$(uname -m)

# Only support two architectures
if [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
else
    ARCH="arm64"
fi

# Download etcd binary
wget -q --show-progress --https-only --timestamping \
"https://github.com/coreos/etcd/releases/download/v3.5.21/etcd-v3.5.21-linux-${ARCH}.tar.gz"

tar -xvf etcd-v3.5.21-linux-${ARCH}.tar.gz

mv etcd-v3.5.21-linux-${ARCH}/etcd* /usr/bin/ 2>/dev/null

# Verify the installation
etcd --version
