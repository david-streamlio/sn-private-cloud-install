#!/bin/bash

# Ensure the required arguments are passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <namespace> <pod-name>"
    exit 1
fi

NAMESPACE=$1
POD_NAME=$2

# Array of pulsar-perf commands you want to run
PULSAR_PERF_COMMANDS=(
    "/pulsar/bin/pulsar-perf produce -r 2000 -s 2048 my-topic-1"
    "/pulsar/bin/pulsar-perf consume my-topic-1 -r 1950 -s my-sub-1"
    "/pulsar/bin/pulsar-perf produce -r 5000 -s 4096 my-topic-2"
    "/pulsar/bin/pulsar-perf consume my-topic-2 -r 5000 -s my-sub-2"
    "/pulsar/bin/pulsar-perf produce -r 10000 -s 8192 my-topic-3"
    "/pulsar/bin/pulsar-perf consume my-topic-3 -r 10000 -s my-sub-3"
)

# Loop through the commands and start each in the background, redirecting output to /dev/null
for CMD in "${PULSAR_PERF_COMMANDS[@]}"; do
    ./start-pulsar-perf-task.sh "$NAMESPACE" "$POD_NAME" "$CMD" > /dev/null 2>&1 &
    echo "Started: $CMD"
done

echo "All pulsar-perf tasks started."

