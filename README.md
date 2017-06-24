# k8s-ansible
ansible install k8s1.6 on centos7.3
dependency: 
    ansible 2.2.10
    docker 1.12.6
    centos 7.3.1611(suggest kernel version:3.18+)
note:
   1.because github file capacity limit less than 100M,so roles/node/files/ ,roles/master/files/ left empty,
     and left roles/etcd/files/ ,roles/config/files/ empty too.
   2.so you must make sure list file exists :
      roles/etcd/files/kubectl 
      roles/config/files/kubectl
      roles/master/files/kube-apiserver...kube-controller-manager...kube-scheduler
      roles/node/files/kubelet....kube-proxy 
   now you must download 1.6 version exe: kubelet,kube-proxy
after install:
   if you found node is not all.you should check use kubectl get csr,and kubectl approve the pending csr
   
