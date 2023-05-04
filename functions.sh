FEATURE_COLOR="\e[1;32m"
RESET_COLOR="\e[0m"
MSG_COLOR="\e[0;33m"
PRMPT_COLOR="\e[0;31m"

function echo_colored() {
    echo -e "$MSG_COLOR$1$RESET_COLOR"
}

function prompt() {
    echo ""
    echo "=================================================="
    echo -e "$PRMPT_COLOR$1$RESET_COLOR"
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

function get_url() {
  # set -x
  # kubectl get svc $1 
  # kubectl get node -o wide
  # set +x
  PORTS=$(kubectl get --no-headers svc $1 | awk '{print $5}')
  if [[ $TARGET == "gke" ]]
  then 
    HOST=$(kubectl get --no-headers svc $1 | awk '{print $4}')
    PORT=$(echo $PORTS | awk -F":" '{print $1}')
  else
    HOST=$(kubectl get nodes -o wide | awk '/minikube/ {print $6}')
    PORT=$(echo $PORTS | awk -F"[:/]" '{print $2}')
  fi
  URL="http://$HOST:$PORT"
}

function fire_browser() {
    URL=$(get_url messageboard)
    echo $URL
    $BROWSER "http://$URL" &> /dev/null &
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
    echo_colored $1
}