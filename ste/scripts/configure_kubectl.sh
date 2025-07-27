kubectl version --client || { echo "kubectl is not installed" >&2; exit 1; }

# Create the kube proxy configuration
kubectl config set-cluster ste-kubernetes \
--certificate-authority=/etc/ste-kubernetes/pki/ca.crt \
--server=https://127.0.0.1:6443 \
--kubeconfig=/etc/ste-kubernetes/.kube/kube-proxy.kubeconfig

kubectl config set-credentials system:kube-proxy \
--client-certificate=/etc/ste-kubernetes/pki/kube-proxy.crt \
--client-key=/etc/ste-kubernetes/pki/kube-proxy.key \
--kubeconfig=/etc/ste-kubernetes/.kube/kube-proxy.kubeconfig

kubectl config set-context default \
--cluster=ste-kubernetes \
--user=system:kube-proxy \
--kubeconfig=/etc/ste-kubernetes/.kube/kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=/etc/ste-kubernetes/.kube/kube-proxy.kubeconfig

# Create the controller manager configuration
kubectl config set-cluster ste-kubernetes \
--certificate-authority=/etc/ste-kubernetes/pki/kubernetes/pki/ca.crt \
--server=https://127.0.0.1:6443 \
--kubeconfig=/etc/ste-kubernetes/.kube/kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
--client-certificate=/etc/ste-kubernetes/pki/kube-controller-manager.crt \
--client-key=/etc/ste-kubernetes/pki/kube-controller-manager.key \
--kubeconfig=/etc/ste-kubernetes/.kube/kube-controller-manager.kubeconfig

kubectl config set-context default \
--cluster=ste-kubernetes \
--user=system:kube-controller-manager \
--kubeconfig=/etc/ste-kubernetes/.kube/kube-controller-manager.kubeconfig

kubectl config use-context default --kubeconfig=/etc/ste-kubernetes/.kube/kube-controller-manager.kubeconfig

# Create the scheduler configuration
kubectl config set-cluster ste-kubernetes \
--certificate-authority=/etc/ste-kubernetes/pki/ca.crt \
--server=https://127.0.0.1:6443 \
--kubeconfig=/etc/ste-kubernetes/.kube/kube-scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
--client-certificate=/etc/ste-kubernetes/pki/kube-scheduler.crt \
--client-key=/etc/ste-kubernetes/pki/kube-scheduler.key \
--kubeconfig=/etc/ste-kubernetes/.kube/kube-scheduler.kubeconfig

kubectl config set-context default \
--cluster=ste-kubernetes \
--user=system:kube-scheduler \
--kubeconfig=/etc/ste-kubernetes/.kube/kube-scheduler.kubeconfig

kubectl config use-context default --kubeconfig=/etc/ste-kubernetes/.kube/kube-scheduler.kubeconfig

# Create the admin configuration
kubectl config set-cluster ste-kubernetes \
--certificate-authority=/etc/ste-kubernetes/pki/ca.crt \
--embed-certs=true \
--server=https://127.0.0.1:6443 \
--kubeconfig=/etc/ste-kubernetes/.kube/admin.kubeconfig

kubectl config set-credentials admin \
--client-certificate=/etc/ste-kubernetes/pki/admin.crt \
--client-key=/etc/ste-kubernetes/pki/admin.key \
--embed-certs=true \
--kubeconfig=/etc/ste-kubernetes/.kube/admin.kubeconfig

kubectl config set-context default \
--cluster=ste-kubernetes \
--user=admin \
--kubeconfig=/etc/ste-kubernetes/.kube/admin.kubeconfig

kubectl config use-context default --kubeconfig=/etc/ste-kubernetes/.kube/admin.kubeconfig
