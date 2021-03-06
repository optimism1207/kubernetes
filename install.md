#添加阿里云yum源

    cat <<EOF > /etc/yum.repos.d/kubernetes.repo
    > [kubernetes]
    > name=Kubernetes
    > baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
    > enabled=1
    > gpgcheck=0
    > repo_gpgcheck=0
    >gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
    >http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
    > EOF

#关闭selinux，防火墙开放相应节点或关闭，vmware里试了下，光开这些端口还不够，使用flannel总是无法通信，留着之后再研究，先关了防火墙
    
![image](https://github.com/optimism1207/kubernetes/blob/master/required%20ports.png)


#安装前所需要的镜像

    Master节点：
    k8s.gcr.io/pause                     3.1                 7d6e17dbc867        3 days ago          742 kB
    k8s.gcr.io/coredns                   1.2.6               1e156bdb5c9c        3 days ago          40 MB
    k8s.gcr.io/etcd                      3.2.24              f4dce037de48        3 days ago          220 MB
    k8s.gcr.io/kube-scheduler            v1.13.3             dd9a9125881b        3 days ago          79.6 MB
    k8s.gcr.io/kube-proxy                v1.13.3             76ab9d4cefc9        3 days ago          80.3 MB
    k8s.gcr.io/kube-apiserver            v1.13.3             3a11e720b0bc        3 days ago          181 MB
    k8s.gcr.io/kube-controller-manager   v1.13.3             d1c8ae52aa64        3 days ago          146 MB

    Node节点：
    k8s.gcr.io/pause               3.1                 7d6e17dbc867        3 days ago          742 kB
    k8s.gcr.io/kube-proxy          v1.13.3             76ab9d4cefc9        3 days ago          80.3 MB

#国内无法直接拉取镜像，用github存放Dockerfile，由dockerhub自动生成docker镜像再拉取，用dockertag.sh拉取并自动完成改名

#初始化master节点，后面两条命令换用户要再执行
    
    sudo kubeadm init --kubernetes-version 1.13.3 --apiserver-advertise-address 192.168.80.7 --pod-network-cidr=10.244.0.0/16
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && sudo chown $(id -u):$(id -g) $HOME/.kube/config

#默认秘钥24小时过期，创建永不过期的token，命令保存下来

    kubeadm token create --print-join-command --ttl 0

#设置flannel网络
    
    wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml 
    kubectl apply -f kube-flannel.yml
    #删除
    kubectl delete -f kube-flannel.yml

#节点执行
    
    sudo kubeadm join 192.168.80.7:6443 --token 7z7omc.frnfb2tdfw2k6uh5 --discovery-token-ca-cert-hash sha256:b719ef6c25c935eb867439daaecaab422147e55a754be7d751b524136625466f

#删除节点

    kubectl drain node1 --delete-local-data --force --ignore-daemonsets && kubectl delete node node1
    sudo kubeadm reset
    
#删除pod、deployment
    
    检查是否创建了deployments任务：kubectl get deployments
    检查是否创建了副本控制器：ReplicationController：kubectl get rc
    检查死否创建了副本集：replicasets：kubectl get rs
