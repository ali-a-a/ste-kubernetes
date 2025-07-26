<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="https://github.com/user-attachments/assets/a48ed306-01e9-416d-9362-a08448896ae9" alt="Logo" width="189" height="160">
  </a>

  <h1 align="center">Sharded Transient Etcd in Kubernetes</h1>
  <p align="center">
    STE: A new control plane architecture for Kubernetes
  </p>

---
<p>Sharded Transient Etcd (STE) is a new design for the Kubernetes control plane and aims to reduce the Pod startup latency in this orchestration platform. It utilizes RAM-disk-backed etcd instances to eliminate the overhead of persistent etcd (e.g., `fsync` calls and Raft operations) for ephemeral resources, such as stateless Pods. To maintain the same level of fault tolerance as native Kubernetes, STE employs sharding for in-memory etcd instances and deploys them on worker nodes. It uses consistent hashing to dynamically add and remove shards located on worker nodes in the cluster. The architecture of STE is shown in the picture below. Performance results of the new design reveal that, compared to native Kubernetes, STE reduces the Pod startup latency by 80% and doubles the throughput of deploying Pods. Moreover, the new architecture is tested with one of the well-known Kubernetes-based serverless orchestration platforms, Knative, and it is shown that STE reduces the function cold start time by 60%.</p>
<img src="https://github.com/user-attachments/assets/4a7252dc-948c-4c44-999d-d168a5e67960" width="400" alt="STE architecture"/>
</div>