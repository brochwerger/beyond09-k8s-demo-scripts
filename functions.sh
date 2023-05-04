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

function fire_browser() {
    echo "WARN: Use NodePort services only in development"
    PORT=$(kubectl get svc $1 | awk -F"[:/]" '/NodePort/ {print $2}')
    NODE=$(kubectl get nodes -o wide | awk '/minikube/ {print $6}')
    set -x
    kubectl get svc 
    kubectl get node -o wide
    $BROWSER "http://$NODE:$PORT" &> /dev/null &
    set +x
}

function kill_pod() {
    set -x
    kubectl get pods
    set +x
    target=$(kubectl get pods | grep $APPNAME | awk '/Running/ {print $1}')
    set -x
    kubectl delete pod $target
    sleep 1
    kubectl get pods
    set +x
    echo -e "\e[0;33m$1\e[0m"
}

function echo_colored() {
    echo -e "\e[0;33m$1 \e[0m"
}
