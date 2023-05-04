#! /usr/bin/bash

# SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

PS4="▶️  "

GITHUB_REPO="https://github.com/$(git remote -v | awk -F[\:\.] '/fetch/ {print $3}')"

source $SCRIPT_DIR/functions.sh

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


