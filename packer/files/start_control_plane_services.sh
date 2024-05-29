systemctl daemon-reload
systemctl enable etcd
systemctl start etcd
sleep 10
systemctl enable kube-apiserver \
    kube-controller-manager kube-scheduler
systemctl start kube-apiserver \
    kube-controller-manager kube-scheduler
sleep 10

# RBAC for Kubelet Authorization
kubectl apply -f /tmp/kube-apiserver-to-kubelet.yaml \
  --kubeconfig /tmp/admin.kubeconfig