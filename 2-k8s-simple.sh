#! /usr/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DEMO_DIR=$(dirname $SCRIPT_DIR)

if [[ ! -f $SCRIPT_DIR/vars.sh ]] 
then 
  source $SCRIPT_DIR/setup.sh
fi
source $SCRIPT_DIR/vars.sh
source $SCRIPT_DIR/common.sh
 

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
        set +x
    else
        set -x
        minikube status
        set +x
    fi
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



echo "DONE - Can we do better ?"