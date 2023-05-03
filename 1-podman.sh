#! /usr/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DEMO_DIR=$(dirname $SCRIPT_DIR)

source $SCRIPT_DIR/setup.sh
 
if prompt "Create a new git branch and reset it to DEMO 1 commit" 
then 
    # DEMO1_COMMIT=$(git log --oneline main | awk '/DEMO 1/ {print $1}')
    set -x 
    git checkout -b $BRANCH
    # git reset --hard $DEMO1_COMMIT
    git reset --hard DEMO1
    set +x
fi

if prompt "Check status of local image registry and containers (podman)"
then 
    set -x
    podman images
    podman ps -a
    set +x
fi

if prompt "Build local container image (podman)" 
then 
    set -x
    podman build -t $APPNAME:1.0 .
    podman images
    set +x
fi

if prompt "Run a container from the image built in previous step ?"
then
    set -x
    podman run -d -p 8000:8000 --name $APPNAME $APPNAME:1.0
    podman ps 
    set +x
fi

if prompt "We're done - do you want to open up browser to check"
then
    set -x
    $BROWSER http://localhost:8000 &> /dev/null &
    set +x
fi