#! /usr/bin/bash

# SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

PS4="▶️  "

GITHUB_REPO="https://github.com/$(git remote -v | awk -F[\:\.] '/fetch/ {print $3}')"

function prompt() {
    echo ""
    echo "=================================================="
    echo -e "\e[0;31m$1\e[0m"
    echo ""
    while true 
    do 
        echo ${2:-"Proceed"} "[Y|A|S]?"
        read PROCEED
        if [[ $PROCEED = "A" || $PROCEED == "a" ]] # Abort
        then
            echo "Aborting ..."
            exit
        elif [[ $PROCEED = "S" || $PROCEED == "s" ]] # Skip to next step
        then 
            return -1
        elif [[ $PROCEED = "Y" || $PROCEED == "y" ]] # Proceed with step
        then 
            return 0
        fi
    done
}

function firebrowser() {
    echo "WARN: Use NodePort services only in development"
    PORT=$(kubectl get svc $1 | awk -F"[:/]" '/NodePort/ {print $2}')
    NODE=$(kubectl get nodes -o wide | awk '/minikube/ {print $6}')
    set -x
    kubectl get svc 
    kubectl get node -o wide
    $BROWSER "http://$NODE:$PORT" &> /dev/null &
    set +x
}

if [[ ! -f $SCRIPT_DIR/vars.sh ]] 
then 
    read -ei "demo" -p "BRANCH = " BRANCH
    read -ei "messageboard" -p "APPNAME = " APPNAME
    read -ei "quay.io" -p "REGISTRY = " REGISTRY
    read -p "PROJECTID = " PROJECTID
    read -ei "firefox" -p "BROWSER = " BROWSER

    echo "BRANCH=$BRANCH" > $SCRIPT_DIR/vars.sh
    echo "APPNAME=$APPNAME" >> $SCRIPT_DIR/vars.sh
    echo "REGISTRY=$REGISTRY" >> $SCRIPT_DIR/vars.sh
    echo "PROJECTID=$PROJECTID" >> $SCRIPT_DIR/vars.sh
    echo "BROWSER=$BROWSER" >> $SCRIPT_DIR/vars.sh
else
    source $SCRIPT_DIR/vars.sh
fi


