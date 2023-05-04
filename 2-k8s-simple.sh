#! /usr/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

source $SCRIPT_DIR/setup.sh

if prompt "To use container image in the cloud we need to upload to a registy (e.g. $REGISTRY)"
then
    set -x
    podman login -u $OWNERID $REGISTRY
    podman tag  $APPNAME:1.0 $REGISTRY/$OWNERID/$APPNAME:1.0
    podman push $REGISTRY/$OWNERID/$APPNAME:1.0
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

echo_colored "Deploying on selected cluster - $TARGET"

if [[ $TARGET == "minikube" ]] 
then 
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
else
    if prompt "Get GKE credentials ..."
    then
        set -x
        gcloud container clusters get-credentials $CLUSTER --region $REGION --project $PROJECT
        set +x
    fi
fi

if prompt "Check the k8s cluster"
then
    set -x
    kubectl get nodes
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
    get_url $APPNAME-pod
    $BROWSER $URL &> /dev/null &
fi

if prompt "Add some messages to message board ... " "Are you done"
then
    echo_colored "Cool, but what is the fuzz about K8S ?"
fi

if prompt "$FEATURE_COLOR AVAILABILITY$PRMPT_COLOR - let's delete the pod and see what happens now ..."
then
    kill_pod "K8S ensures the service continues working in case of failures 🤩🤩🤩, however ..."
fi    

if prompt "Go to browser window and refresh the page..." "Are you done"
then
    echo_colored "We lost our data ... 😱"
    echo_colored "What happened to messages ? Why ?"
fi