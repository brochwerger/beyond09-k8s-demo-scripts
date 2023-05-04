#! /usr/bin/bash

# SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

PS4="▶️  "

GITHUB_REPO="https://github.com/$(git remote -v | awk -F[\:\.] '/fetch/ {print $3}')"

source $SCRIPT_DIR/functions.sh

if [[ ! -f $SCRIPT_DIR/vars.sh ]] 
then 

    echo URL="http://0.0.0.0:9999" > $SCRIPT_DIR/vars.sh

    read -ei "demo" -p "BRANCH = " BRANCH
    echo "BRANCH=$BRANCH" >> $SCRIPT_DIR/vars.sh

    read -ei "messageboard" -p "APPNAME = " APPNAME
    echo "APPNAME=$APPNAME" >> $SCRIPT_DIR/vars.sh

    read -ei "quay.io" -p "REGISTRY = " REGISTRY
    echo "REGISTRY=$REGISTRY" >> $SCRIPT_DIR/vars.sh

    read -p "OWNERID = " OWNERID
    echo "OWNERID=$OWNERID" >> $SCRIPT_DIR/vars.sh

    read -ei "opera" -p "BROWSER = " BROWSER
    echo "BROWSER=$BROWSER" >> $SCRIPT_DIR/vars.sh

    TARGET='?'
    until [[ $TARGET == "gke" ]] || [[ $TARGET == "minikube" ]]
    do
        read -ei "gke|minikube" -p "TARGET = " TARGET
    done 
    echo "TARGET=$TARGET" >> $SCRIPT_DIR/vars.sh

    if [[ $TARGET == "gke" ]] 
    then 
        read -ei "beyond09" -p "PROJECT = " PROJECT
        echo "PROJECT=$PROJECT" >> $SCRIPT_DIR/vars.sh

        read -ei "democluster" -p "CLUSTER = " CLUSTER
        echo "CLUSTER=$CLUSTER" >> $SCRIPT_DIR/vars.sh

        read -ei "us-central1" -p "REGION = " REGION
        echo "REGION=$REGION" >> $SCRIPT_DIR/vars.sh
    fi

else
    source $SCRIPT_DIR/vars.sh
fi



