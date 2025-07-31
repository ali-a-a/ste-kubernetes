<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="https://github.com/user-attachments/assets/a48ed306-01e9-416d-9362-a08448896ae9" alt="Logo" width="189" height="160">
  </a>

  <h1 align="center">Sharded Transient Etcd: Accelerating Kubernetes for Serverless and Ephemeral Workloads</h1>
  <p align="center">
    STE: A new control plane architecture for Kubernetes
  </p>

---
<p>Sharded Transient Etcd (STE) is a new design for the Kubernetes control plane and aims to reduce the Pod startup latency in this orchestration platform. It utilizes RAM-disk-backed etcd instances to eliminate the overhead of persistent etcd (e.g., fsync calls and Raft operations) for ephemeral resources, such as stateless Pods. To maintain the same level of fault tolerance as native Kubernetes, STE employs sharding for in-memory etcd instances and deploys them on worker nodes. It uses consistent hashing to dynamically add and remove shards located on worker nodes in the cluster. The architecture of STE is shown in the picture below. Performance results of the new design reveal that, compared to native Kubernetes, STE reduces the Pod startup latency by 80% and doubles the throughput of deploying Pods. Moreover, the new architecture is tested with one of the well-known Kubernetes-based serverless orchestration platforms, Knative, and it is shown that STE reduces the function cold start time by 60%.</p>
<img src="https://github.com/user-attachments/assets/616f3980-ce7b-4bcf-91c8-0038321205c9" width="400" alt="STE architecture"/>
</div>

<div align="center">

  ### Built By Modifying
  <a href="https://github.com/kubernetes/kubernetes">
    <img src="https://github.com/kubernetes/kubernetes/blob/master/logo/name_blue.png" alt="Logo" width="100" height="100">
  </a>
</div>

## Software implementation

Main modifications are made in these commits:

* <a href="https://github.com/ali-a-a/ste-kubernetes/commit/72d086e53f8090a8318eaf21ff4499350fd57e12">72d086e</a> - Add the second storage
* <a href="https://github.com/ali-a-a/ste-kubernetes/commit/eaab8a75bfa52d2dc35dfad31b901d84fec142a6">eaab8a7</a> - Forward pods to the second storage
* <a href="https://github.com/ali-a-a/ste-kubernetes/commit/327f421140e26cb1a0b92eb472a2c0cc083dcb72">327f421</a> - Add sharding
* <a href="https://github.com/ali-a-a/ste-kubernetes/commit/fbfa1558d5a1aa8f3be68ee4c5b98f4ad6dd1039">fbfa155</a> - Add dynamic shard provisioning
* <a href="https://github.com/ali-a-a/ste-kubernetes/commit/9b11bb58a9fbe2f71abb846e41cdd059b36814b2">9b11bb5</a> - Add consistent hashing
* <a href="https://github.com/ali-a-a/ste-kubernetes/commit/452659fe70f2ac8c5e06afb2bce65f63fad10698">452659f</a> - Support deletion from the ring

## Getting the code

The code can be downloaded by cloning the repository:
```bash
git clone https://github.com/ali-a-a/ste-kubernetes.git
```

## Installation

To install and use STE, scripts are provided in the `ste/scripts` directory. You can follow the instructions here to use
these scripts.

Create all the certificates used by STE. These certificates will be stored in the `/etc/ste-kubernetes/pki/` directory.
You need to pass the IP address of the worker nodes to this script.

```bash
./ste/scripts/create_certificates.sh worker_node_1_ip_address worker_node_2_ip_address
```

Download and install kubelet and kubectl v1.32.0.

```bash
./ste/scripts/install_kubelet_kubectl.sh
```

Create kubeconfig for kubernetes components. These files will be stored in the `etc/ste-kubernetes/.kube/` directory.

```bash
./ste/scripts/configure_kubectl.sh
```

Download and install etcd v3.5.21.

```bash
./ste/scripts/install_etcd.sh
```

Run the persistent etcd instance. It will run the storage on the `/var/lib/etcd-ste` data directory.

```bash
./ste/scripts/run_etcd.sh
```

You can verify the process is running by checking its tmux session.

```bash
tmux attach -t etcd-shard
```

Run the etcd shard on the initial worker node. It will run the storage on the `etcd-ste-ram-disk` data directory (which is a RAM disk).

```bash
./ste/scripts/run_etcd_shard.sh
```

Compile the API Server, Scheduler, and Controller Manager and run them as a process. Ensure that your current directory is the root of `ali-a-a/ste-kubernetes`.

```bash
go build -o /etc/ste-kubernetes/bin/kube-apiserver \
  -ldflags="-X k8s.io/component-base/version.gitVersion=v1.32.0" ./cmd/kube-apiserver
go build -o /etc/ste-kubernetes/bin/kube-scheduler \
-ldflags="-X k8s.io/component-base/version.gitVersion=v1.32.0" ./cmd/kube-scheduler
go build -o /etc/ste-kubernetes/bin/kube-controller-manager \
-ldflags="-X k8s.io/component-base/version.gitVersion=v1.32.0" ./cmd/kube-controller-manager

./ste/scripts/run_kube_apiserver.sh
./ste/scripts/run_kube_scheduler.sh
./ste/scripts/run_kube_controller_manager.sh
```

Configure the worker node machine and run containerd. This script should be run on all the worker nodes.

```bash
./ste/scripts/configure_worker_node_machine.sh
```

Create kubeconfig files for the worker node. If the script is run on a worker node other than the control plane,
ensure that ca certificates files are copied to the `/etc/ste-kubernetes/pki/` path. This script accepts the IP address
of the control plane node as an argument.

```bash
./ste/scripts/configure_kubectl_worker_node.sh control_plane_ip_address
```

Compile and run kubelet.

```bash
go build -o /etc/ste-kubernetes/bin/kubelet \
  -ldflags="-X k8s.io/component-base/version.gitVersion=v1.32.0" ./cmd/kubelet

./ste/scripts/run_kubelet.sh
```

Compile and run kubelet.

```bash
go build -o /etc/ste-kubernetes/bin/kubelet \
-ldflags="-X k8s.io/component-base/version.gitVersion=v1.32.0" ./cmd/kubelet

./ste/scripts/run_kubelet.sh
```

Compile and run kube proxy.

```bash
go build -o /etc/ste-kubernetes/bin/kube-proxy \
  -ldflags="-X k8s.io/component-base/version.gitVersion=v1.32.0" ./cmd/kube-proxy

./ste/scripts/run_kube_proxy.sh
```

Set up a cluster role binding so that kube proxy can access endpoint slices.

```bash
./ste/scripts/patch_system_node_rbac.sh
```

Install and run coredns and calico in the cluster. Check the config file of coredns and adjust it according to your environment.

```bash
./ste/scripts/install_coredns.sh
./ste/scripts/install_calico.sh
```

Configure kubeste so that you can access the cluster.

```bash
./ste/scripts/configure_kubeste.sh

# Verify all the resources are created and pods are running.
kubeste get all -A
```

## Contact

Ali Abbasi Alaei - aabbasia@uwaterloo.ca
