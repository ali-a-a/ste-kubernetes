#!/bin/bash

# If the session exists, exit
if tmux has-session -t etcd-shard 2>/dev/null; then
  echo "Session etcd-shard exists. Exiting..."
  exit 0
fi

# Check whether the the data directory is clean
if [ -d /var/lib/etcd-ste-ram-disk ]; then
  echo "Removing /var/lib/etcd-ste-ram-disk"

  umount -l /var/lib/etcd-ste-ram-disk
  rm -rf /var/lib/etcd-ste-ram-disk
  mkdir /var/lib/etcd-ste-ram-disk
  mount -o size=1G -t tmpfs none /var/lib/etcd-ste-ram-disk
else
  mkdir /var/lib/etcd-ste-ram-disk
  mount -o size=1G -t tmpfs none /var/lib/etcd-ste-ram-disk
fi

# Create the tmux session
tmux new -d -s etcd-shard

# Run etcd shard
tmux send-keys -t etcd-shard "etcd \
--name $(hostname -s)-ram-disk \
--cert-file=/etc/ste-kubernetes/pki/etcd-server.crt \
--key-file=/etc/ste-kubernetes/pki/etcd-server.key \
--peer-cert-file=/etc/ste-kubernetes/pki/etcd-server.crt \
--peer-key-file=/etc/ste-kubernetes/pki/etcd-server.key \
--trusted-ca-file=/etc/ste-kubernetes/pki/ca.crt \
--peer-trusted-ca-file=/etc/ste-kubernetes/pki/ca.crt \
--peer-client-cert-auth \
--client-cert-auth \
--advertise-client-urls=https://$(hostname -i):2279 \
--initial-advertise-peer-urls=https://$(hostname -i):2280 \
--initial-cluster=$(hostname -s)-ram-disk=https://$(hostname -i):2280 \
--listen-client-urls=https://127.0.0.1:2279,https://$(hostname -i):2279 \
--listen-peer-urls=https://$(hostname -i):2280 \
--initial-cluster-token etcd-cluster-ram-disk \
--initial-cluster-state new \
--data-dir=/var/lib/etcd-ste-ram-disk" ENTER
