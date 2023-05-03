#! /usr/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DEMO_DIR=$(dirname $SCRIPT_DIR)

source $SCRIPT_DIR/setup.sh

if prompt "To use container image in the cloud we need to upload to a registy (e.g. $REGISTRY)"
then
    set -x
    podman login -u $PROJECTID $REGISTRY
    podman tag  $APPNAME:1.0 $REGISTRY/$PROJECTID/$APPNAME:1.0
    podman push $REGISTRY/$PROJECTID/$APPNAME:1.0
    set +x
fi

# GENERATE YAML
if prompt "Generate K8S deployment YAML from running container "
then
    set -x
    podman kube generate -f $APPNAME.yaml -t deployment -s $APPNAME
    vi $APPNAME.yaml
    set +x
fi

# MINIKUBE
if prompt "Check status of minikube, if it is not running start it ..."
then
    nrun=$(minikube status | grep "Running"  | wc -l)
    if [[ $nrun != 3  ]]
    then
        set -x
        minikube start
    else
        set -x
        minikube status

        echo "Set local minikube as default cluster"
        KUBECONFIG=~/.kube/config 
        kubectl config use-context minikube
    fi
    set +x

fi

if prompt "Check what is running in the k8s cluster"
then
    set -x
    kubectl get all
    set +x
fi

if prompt "Deploy our container in the k8s cluster"
then
    set -x
    kubectl apply -f $APPNAME.yaml
    set +x
fi

if prompt "Check again what is running in the k8s cluster"
then
    set -x
    kubectl get all
    set +x
fi

if prompt "Find out service address and port and fire local browser"
then
    echo "WARN: Use NodePort services only in development"
    PORT=$(kubectl get svc | awk -F"[:/]" '/NodePort/ {print $2}')
    NODE=$(kubectl get nodes -o wide | awk '/minikube/ {print $6}')
    set -x
    kubectl get svc 
    kubectl get node -o wide
    $BROWSER "http://$NODE:$PORT" &> /dev/null &
    set +x
fi
