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
<img src="https://github.com/user-attachments/assets/4a7252dc-948c-4c44-999d-d168a5e67960" width="400" alt="STE architecture"/>
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

To install and use STE, a document is provided in the `ste/docs` directory. You can follow the document to run the cluster in your environment.
