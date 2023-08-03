
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