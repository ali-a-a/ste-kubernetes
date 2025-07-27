# If the session exists, exit
if tmux has-session -t persistent-etcd 2>/dev/null; then
  echo "Session persistent-etcd exists. Exiting..."
  exit 0
fi

# Check whether the the data directory is clean
if [ -d /var/lib/etcd-ste ]; then
  read -p "This will remove /var/lib/etcd-ste. Do you want to continue? [y/N] " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    exit 1
  fi
  rm -rf /var/lib/etcd-ste
else
  mkdir -p /var/lib/etcd-ste
fi

# Create the tmux session
tmux new -s persistent-etcd

# Run etcd
tmux send-keys -t persistent-etcd "etcd \
--name $(hostname -s) \
--cert-file=/etc/ste-kubernetes/pki/etcd-server.crt \
--key-file=/etc/ste-kubernetes/pki/etcd-server.key \
--peer-cert-file=/etc/ste-kubernetes/pki/etcd-server.crt \
--peer-key-file=/etc/ste-kubernetes/pki/etcd-server.key \
--trusted-ca-file=/etc/ste-kubernetes/pki/ca.crt \
--peer-trusted-ca-file=/etc/ste-kubernetes/pki/ca.crt \
--peer-client-cert-auth \
--client-cert-auth \
--initial-advertise-peer-urls https://127.0.0.1:2380 \
--listen-peer-urls https://127.0.0.1:2380 \
--listen-client-urls https://127.0.0.1:2379 \
--advertise-client-urls https://127.0.0.1:2380 \
--initial-cluster-token etcd-cluster-0 \
--initial-cluster $(hostname -s)=https://127.0.0.1:2380 \
--initial-cluster-state new \
--data-dir=/var/lib/etcd-ste" ENTER
