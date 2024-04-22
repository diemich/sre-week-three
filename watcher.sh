#!/bin/bash 
#Written by Diego Clavijo // https://github.com/diemich

# Kubernetes Deployment Monitoring Script

# Variable definition
NAMESPACE="sre"
DEPLOYMENT_NAME=$(kubectl get pods --namespace sre | grep swype |awk '{print $1}'|head -n 1)
MAX_RESTARTS_ALLOWED=5

# Function to print timestamped messages
print_message() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1"
}

echo "Monitoring ${NAMESPACE} ${DEPLOYMENT_NAME} "
read -p "Press Enter to continue..."

# Infinite loop
while true; do
     
    # Get the restart count for the specified pod
    restarts=$(kubectl get pods -n "$NAMESPACE" "$DEPLOYMENT_NAME" -o jsonpath='{.status.containerStatuses[0].restartCount}')

    # Print current restart count
    print_message "Current restart count: $restarts"

    # Compare with the maximum allowed
    if [ "$restarts" -gt "$MAX_RESTARTS_ALLOWED" ]; then
        print_message "Exceeded maximum restarts. Scaling down deployment..."
        kubectl scale deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE"  --replicas=0
        break
    else
        print_message "Restart count within limits. Waiting for 60 seconds..."
        sleep 60
    fi
done

print_message "Script execution complete."


##for troubleshooting use this commands

#restart de pods and set the restart count back to 0 to debug the bash script
#kubectl delete pod <pod_name> -n <namespace>

# run the script using ./watcher.sh  to monitor is functioning 

#in a splitted terminal is possible to monitor the current status of a pod and the restarting proccess 
#kubectl get pods --namespace sre -w


#Resources used 
#https://www.howtogeek.com/804823/nohup-command-linux/
#https://spacelift.io/blog/restart-kubernetes-pods-with-kubectl
#https://kubernetes.io/docs/reference/kubectl/generated/kubectl_scale/
#https://linuxhandbook.com/run-process-background/
#https://stackoverflow.com/questions/59658516/kubernetes-pod-restart-count-shows-inconsistent-values-when-kubectl-get-pod-w-i



