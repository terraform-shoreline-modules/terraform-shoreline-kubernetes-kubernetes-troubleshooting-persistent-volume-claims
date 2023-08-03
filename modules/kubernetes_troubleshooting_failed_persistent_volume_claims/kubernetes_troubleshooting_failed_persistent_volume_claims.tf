resource "shoreline_notebook" "kubernetes_troubleshooting_failed_persistent_volume_claims" {
  name       = "kubernetes_troubleshooting_failed_persistent_volume_claims"
  data       = file("${path.module}/data/kubernetes_troubleshooting_failed_persistent_volume_claims.json")
  depends_on = [shoreline_action.invoke_get_storageclass_describe_storageclass,shoreline_action.invoke_kubectl_nodes_info,shoreline_action.invoke_check_storage_class_mount_options,shoreline_action.invoke_script_check_capacity_and_pvc_status,shoreline_action.invoke_storageconfig_check,shoreline_action.invoke_kubectl_check_pvc_and_sc]
}

resource "shoreline_file" "get_storageclass_describe_storageclass" {
  name             = "get_storageclass_describe_storageclass"
  input_file       = "${path.module}/data/get_storageclass_describe_storageclass.sh"
  md5              = filemd5("${path.module}/data/get_storageclass_describe_storageclass.sh")
  description      = "Check the storage class and volume configurations"
  destination_path = "/agent/scripts/get_storageclass_describe_storageclass.sh"
  resource_query   = "container | app='shoreline'"
  enabled          = true
}

resource "shoreline_file" "kubectl_nodes_info" {
  name             = "kubectl_nodes_info"
  input_file       = "${path.module}/data/kubectl_nodes_info.sh"
  md5              = filemd5("${path.module}/data/kubectl_nodes_info.sh")
  description      = "Check the state of the nodes in the cluster"
  destination_path = "/agent/scripts/kubectl_nodes_info.sh"
  resource_query   = "container | app='shoreline'"
  enabled          = true
}

resource "shoreline_file" "check_storage_class_mount_options" {
  name             = "check_storage_class_mount_options"
  input_file       = "${path.module}/data/check_storage_class_mount_options.sh"
  md5              = filemd5("${path.module}/data/check_storage_class_mount_options.sh")
  description      = "Misconfigured storage classes, which can cause volumes to fail to mount properly."
  destination_path = "/agent/scripts/check_storage_class_mount_options.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "script_check_capacity_and_pvc_status" {
  name             = "script_check_capacity_and_pvc_status"
  input_file       = "${path.module}/data/script_check_capacity_and_pvc_status.sh"
  md5              = filemd5("${path.module}/data/script_check_capacity_and_pvc_status.sh")
  description      = "Insufficient storage capacity in the cluster leading to failed persistent volume claims."
  destination_path = "/agent/scripts/script_check_capacity_and_pvc_status.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "storageconfig_check" {
  name             = "storageconfig_check"
  input_file       = "${path.module}/data/storageconfig_check.sh"
  md5              = filemd5("${path.module}/data/storageconfig_check.sh")
  description      = "Check the storage configuration of the Kubernetes cluster to ensure that it is properly configured."
  destination_path = "/agent/scripts/storageconfig_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "kubectl_check_pvc_and_sc" {
  name             = "kubectl_check_pvc_and_sc"
  input_file       = "${path.module}/data/kubectl_check_pvc_and_sc.sh"
  md5              = filemd5("${path.module}/data/kubectl_check_pvc_and_sc.sh")
  description      = "Check the persistent volume claims to ensure that they are correctly configured and that the storage class is available."
  destination_path = "/agent/scripts/kubectl_check_pvc_and_sc.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_get_storageclass_describe_storageclass" {
  name        = "invoke_get_storageclass_describe_storageclass"
  description = "Check the storage class and volume configurations"
  command     = "`chmod +x /agent/scripts/get_storageclass_describe_storageclass.sh && /agent/scripts/get_storageclass_describe_storageclass.sh`"
  params      = ["STORAGE_CLASS_NAME"]
  file_deps   = ["get_storageclass_describe_storageclass"]
  enabled     = true
  depends_on  = [shoreline_file.get_storageclass_describe_storageclass]
}

resource "shoreline_action" "invoke_kubectl_nodes_info" {
  name        = "invoke_kubectl_nodes_info"
  description = "Check the state of the nodes in the cluster"
  command     = "`chmod +x /agent/scripts/kubectl_nodes_info.sh && /agent/scripts/kubectl_nodes_info.sh`"
  params      = ["NODE_NAME"]
  file_deps   = ["kubectl_nodes_info"]
  enabled     = true
  depends_on  = [shoreline_file.kubectl_nodes_info]
}

resource "shoreline_action" "invoke_check_storage_class_mount_options" {
  name        = "invoke_check_storage_class_mount_options"
  description = "Misconfigured storage classes, which can cause volumes to fail to mount properly."
  command     = "`chmod +x /agent/scripts/check_storage_class_mount_options.sh && /agent/scripts/check_storage_class_mount_options.sh`"
  params      = ["NAMESPACE_NAME"]
  file_deps   = ["check_storage_class_mount_options"]
  enabled     = true
  depends_on  = [shoreline_file.check_storage_class_mount_options]
}

resource "shoreline_action" "invoke_script_check_capacity_and_pvc_status" {
  name        = "invoke_script_check_capacity_and_pvc_status"
  description = "Insufficient storage capacity in the cluster leading to failed persistent volume claims."
  command     = "`chmod +x /agent/scripts/script_check_capacity_and_pvc_status.sh && /agent/scripts/script_check_capacity_and_pvc_status.sh`"
  params      = ["VOLUME_SIZE","STORAGE_CLASS_NAME","NAMESPACE_NAME"]
  file_deps   = ["script_check_capacity_and_pvc_status"]
  enabled     = true
  depends_on  = [shoreline_file.script_check_capacity_and_pvc_status]
}

resource "shoreline_action" "invoke_storageconfig_check" {
  name        = "invoke_storageconfig_check"
  description = "Check the storage configuration of the Kubernetes cluster to ensure that it is properly configured."
  command     = "`chmod +x /agent/scripts/storageconfig_check.sh && /agent/scripts/storageconfig_check.sh`"
  params      = ["STORAGE_CLASS_NAME"]
  file_deps   = ["storageconfig_check"]
  enabled     = true
  depends_on  = [shoreline_file.storageconfig_check]
}

resource "shoreline_action" "invoke_kubectl_check_pvc_and_sc" {
  name        = "invoke_kubectl_check_pvc_and_sc"
  description = "Check the persistent volume claims to ensure that they are correctly configured and that the storage class is available."
  command     = "`chmod +x /agent/scripts/kubectl_check_pvc_and_sc.sh && /agent/scripts/kubectl_check_pvc_and_sc.sh`"
  params      = ["PERSISTENT_VOLUME_CLAIM_NAME","STORAGE_CLASS_NAME"]
  file_deps   = ["kubectl_check_pvc_and_sc"]
  enabled     = true
  depends_on  = [shoreline_file.kubectl_check_pvc_and_sc]
}

