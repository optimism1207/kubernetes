
# hlem 错误记录

# tiller-deploy-56957488f7-s7rwz Imagepullbackoff
    
    docker pull docker.io/optimism1207/tiller:v2.13.0
    docker tag docker.io/optimism1207/tiller:v2.13.0 gcr.io/kubernetes-helm/tiller:v2.13.0
    
# helm ls 错误

    [gx@kubemaster ~]$ helm ls
    Error: configmaps is forbidden: User "system:serviceaccount:kube-system:default" cannot list resource "configmaps" in API group "" in the namespace "kube-system"
    
    1.kubectl create serviceaccount --namespace kube-system tiller
    2.kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
    3.kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
    4.helm init --service-account tiller --upgrade -i gcr.io/kubernetes-helm/tiller:v2.13.0
    
