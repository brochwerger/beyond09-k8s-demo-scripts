#! /usr/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

MANIFESTS_DIR=./k8s-manifests

source $SCRIPT_DIR/setup.sh

if prompt "Get files from git DEMO 2 commit" 
then 
    set -x 
    git reset --hard DEMO2
    set +x
fi

if prompt "Create secret and deploy DB server"
then 
    set -x 
    kubectl apply -f $MANIFESTS_DIR/01-secret.yaml
    kubectl apply -f $MANIFESTS_DIR/02-dbserver.yaml
    kubectl get pvc
    set +x 
fi

if prompt "Build and push updated container image ..."
then
    set -x
    podman build -t "$REGISTRY/$PROJECTID/$APPNAME:2.0" .
    podman push "$REGISTRY/$PROJECTID/$APPNAME:2.0"
    set +x
fi


if prompt "Check if DB server is ready"
then
    set -x
    kubectl get pods
    set +x
fi

if prompt "Deploy application server"
then
    set -x
    kubectl apply -f $MANIFESTS_DIR/03-appserver.yaml
    set +x
fi

if prompt "Find out service address and port and fire local browser"
then
    firebrowser $APPNAME
fi

