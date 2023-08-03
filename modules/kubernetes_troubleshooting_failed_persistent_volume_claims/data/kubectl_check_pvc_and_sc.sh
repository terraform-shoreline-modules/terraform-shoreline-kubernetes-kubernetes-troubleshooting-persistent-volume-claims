
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