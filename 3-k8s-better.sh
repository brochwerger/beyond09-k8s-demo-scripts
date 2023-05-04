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

if prompt "Review/edit application YAML"
then 
    vi $MANIFESTS_DIR/03-appserver.yaml
fi

if prompt "Deploy application server"
then
    set -x
    kubectl apply -f $MANIFESTS_DIR/03-appserver.yaml
    sleep 5
    kubectl get all -l app=$APPNAME
    set +x
fi
    
if prompt "Find out service address and port and fire local browser"
then
    fire_browser $APPNAME
fi

if prompt "$FEATURE_COLOR AVAILABILITY$PRMPT_COLOR - let's delete the pod and see what happens now ..."
then
    kill_pod "As before, K8S ensures the service continues working in case of failures but now ..."
fi    

if prompt "Go to browser window and refresh the page..." "Are you done"
then
    echo_colored "Now we don't lose our data 🤩🤩🤩"
    echo_colored "What about the DB (still a single point of failure) ?"
    echo_colored "For stateful services we'll need more than a few minutes"
    echo_colored "So K8S gives us $FEATURE_COLOR AVAILABILITY$MSG_COLOR and$FEATURE_COLOR SERVICE DISCOVERY$MSG_COLOR, anything else?"
fi

if prompt "What about $FEATURE_COLOR SCALABILITY$RESET_COLOR ?"
then
    set -x
    kubectl get pods -l app=$APPNAME
    kubectl scale deployment --replicas 3 $APPNAME
    kubectl get pods -l app=$APPNAME
    set +x
fi

if prompt "Check who (pod) is now serving my requests"
then 
    PORT=$(kubectl get svc $APPNAME | awk -F"[:/]" '/NodePort/ {print $2}')
    NODE=$(kubectl get nodes -o wide | awk '/minikube/ {print $6}')
    echo "while true ; do  curl -s http://$NODE:$PORT | grep \"Served\" ; sleep 1 ; done"
    while true ; do  curl -s http://$NODE:$PORT | grep "Served" ; sleep 1 ; done
    # while true ; do  curl -s http://$NODE:$PORT | grep "Served\|Benny" ; sleep 1 ; done
fi

