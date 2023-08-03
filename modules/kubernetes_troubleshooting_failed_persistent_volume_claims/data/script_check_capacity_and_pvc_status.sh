
#!/bin/bash

# Set variables
NAMESPACE="${NAMESPACE_NAME}"
STORAGE_CLASS="${STORAGE_CLASS_NAME}"
VOLUME_SIZE="${VOLUME_SIZE}"

# Check available storage capacity
AVAILABLE_CAPACITY=$(kubectl get nodes -o json | jq -r '.items[].status.allocatable."ephemeral-storage"' | awk '{total += $1} END {print total}')
if [ $AVAILABLE_CAPACITY -lt $VOLUME_SIZE ]; then
    echo "Error: Insufficient storage capacity available in the cluster."
    exit 1
fi

# Check storage class
STORAGE_CLASS_EXISTS=$(kubectl get storageclass | grep $STORAGE_CLASS | wc -l)
if [ $STORAGE_CLASS_EXISTS -eq 0 ]; then
    echo "Error: Storage class $STORAGE_CLASS does not exist."
    exit 1
fi

# Check PVC status
PVC_STATUS=$(kubectl get pvc -n $NAMESPACE | awk '{print $2}' | tail -1)
if [ $PVC_STATUS != "Bound" ]; then
    echo "Error: Persistent Volume Claim in namespace $NAMESPACE is not bound."
    exit 1
fi

echo "No issues found."
exit 0