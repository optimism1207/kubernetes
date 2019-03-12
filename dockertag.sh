#!/bin/bash
#tag kubeimages
images='kube-apiserver:1.13.3 kube-controller-manager:1.13.3 kube-scheduler:1.13.3 kube-proxy:1.13.3 pause:3.1 etcd:3.2.24 coredns:1.2.6'
for image in $images
do
    echo $image
    docker pull docker.io/optimism1207/$image
done

old_tag=`docker images --format "{{.Repository}}:{{.Tag}}" | grep optimism1207`
#old_tag=`docker images --format "{{.Repository}}:{{.Tag}}" | grep gcr.io`

for i in $old_tag
do
    j=`echo $i | awk -F/ '{print $3}'`
    if [[ $j =~ 'kube' ]]
    then
        j_part1=`echo $j | awk -F: '{print $1}'`
        j_part2=`echo $j | awk -F: '{print $2}'`
        docker tag $i k8s.gcr.io/$j_part1:v$j_part2
    else
        docker tag $i k8s.gcr.io/$j
    fi
    docker rmi $i
done
