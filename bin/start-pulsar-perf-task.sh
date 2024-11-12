#!/bin/bash

# Ensure the required arguments are passed
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <namespace> <pod-name> <pulsar-perf-command>"
    echo "Example: $0 pulsar-namespace pulsar-perf-pod 'pulsar-perf produce -r 100 -m 1000000 my-topic'"
    exit 1
fi

NAMESPACE=$1
POD_NAME=$2
PULSAR_PERF_COMMAND=$3

# Function to start pulsar-perf command in the pod
start_pulsar_perf_task() {
    echo "Starting pulsar-perf task on pod $POD_NAME in namespace $NAMESPACE..."
    
    kubectl exec -n "$NAMESPACE" "$POD_NAME" -- /bin/sh -c "$PULSAR_PERF_COMMAND"
    
    if [ $? -eq 0 ]; then
        echo "Pulsar-perf task started successfully."
    else
        echo "Failed to start pulsar-perf task."
        exit 1
    fi
}

# Call the function
start_pulsar_perf_task

