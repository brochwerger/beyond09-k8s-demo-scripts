#! /usr/bin/bash
 
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

MANIFESTS_DIR=./k8s-manifests

source $SCRIPT_DIR/setup.sh

if prompt "Cleanup podman demo"
then
    # Cleanup podman
    podman stop -a
    podman container prune
    podman rmi --all
fi

if prompt "Cleanup simple demo ($APPNAME-pod) ?"
then 
    oc delete all -l app=$APPNAME-pod
fi

if prompt "Cleanup full demo ($APPNAME)"
then
    for f in $(ls -1r $MANIFESTS_DIR/*.yaml) ; do echo $f ; oc delete -f $f ; done
fi

rm ./$APPNAME.yaml
rm $SCRIPT_DIR/vars.sh