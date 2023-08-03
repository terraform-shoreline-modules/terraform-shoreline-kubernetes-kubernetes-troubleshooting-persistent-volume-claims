
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kubernetes - Troubleshooting Failed Persistent Volume Claims
---

This incident type involves issues with persistent volume claims in a Kubernetes cluster. This could be due to storage problems or other configuration issues. It is important to resolve these issues promptly to ensure that the Kubernetes cluster is functioning properly.

### Parameters
```shell
# Environment Variables
export NAMESPACE_NAME="PLACEHOLDER"
export POD_NAME="PLACEHOLDER"
export STORAGE_CLASS_NAME="PLACEHOLDER"
export NODE_NAME="PLACEHOLDER"
export VOLUME_SIZE="PLACEHOLDER"
export PERSISTENT_VOLUME_CLAIM_NAME="PLACEHOLDER"
```

## Debug

### Check the status of the persistent volume claims
```shell
kubectl get pvc
```

### Check the status of persistent volumes
```shell
kubectl get pv
```

### Check if there are any failed pods in the cluster
```shell
kubectl get pods --field-selector=status.phase=Failed
```

### Check the events for the namespace where the incident occurred
```shell
kubectl get events -n ${NAMESPACE_NAME}
```

### Describe the pod that is having issues with persistent volume claims
```shell
kubectl describe pod ${POD_NAME}
```

### Check the logs of the pod
```shell
kubectl logs ${POD_NAME}
```

### Check the storage class and volume configurations
```shell
kubectl get storageclass
kubectl describe storageclass ${STORAGE_CLASS_NAME}
```

### Check the state of the nodes in the cluster
```shell
kubectl get nodes
kubectl describe node ${NODE_NAME}
```

### Misconfigured storage classes, which can cause volumes to fail to mount properly.
```shell

#!/bin/bash

# Set the namespace for the Kubernetes resources we'll be checking
NAMESPACE=${NAMESPACE_NAME}

# Get a list of all storage classes in the namespace
STORAGE_CLASSES=$(kubectl get storageclasses -n $NAMESPACE -o=name)

# Loop through each storage class and check if it's set to the default mount options
for storage_class in $STORAGE_CLASSES; do
    MOUNT_OPTIONS=$(kubectl get $storage_class -n $NAMESPACE -o=jsonpath='{.parameters.mountOptions}')
    if [ "$MOUNT_OPTIONS" == "[]]" ]; then
        echo "Storage class $storage_class is misconfigured - mount options not set"
    fi
done

```

### Insufficient storage capacity in the cluster leading to failed persistent volume claims.
```shell

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

```

---

## Repair
---

### Check the storage configuration of the Kubernetes cluster to ensure that it is properly configured.
```shell

#!/bin/bash

# Ensure that the storage configuration is properly set by checking the StorageClass configuration
kubectl get storageclass

# Check if there are any errors in the StorageClass configuration
kubectl describe storageclass

# If there are any issues with the StorageClass, update the configuration
kubectl edit storageclass ${STORAGE_CLASS_NAME}

```

### Check the persistent volume claims to ensure that they are correctly configured and that the storage class is available.
```shell

#!/bin/bash

# Check if the kubectl command is installed
which kubectl > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Error: kubectl command not found"
  exit 1
fi

# Check the persistent volume claims
kubectl get pvc ${PERSISTENT_VOLUME_CLAIM_NAME} -n ${NAMESPACE} > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Error: Persistent volume claim ${PERSISTENT_VOLUME_CLAIM_NAME} not found in namespace ${NAMESPACE}"
  exit 1
else
  echo "Persistent volume claim ${PERSISTENT_VOLUME_CLAIM_NAME} found in namespace ${NAMESPACE}"
fi

# Check the storage class
kubectl get sc ${STORAGE_CLASS_NAME} > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Error: Storage class ${STORAGE_CLASS_NAME} not found"
  exit 1
else
  echo "Storage class ${STORAGE_CLASS_NAME} found"
fi

```

---