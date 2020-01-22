# Run eksctl if jupyterhub cluster doesn't already exist
# Run only once
# =======================
terraform {
  required_version = ">= 0.12.0"
}

#provider "null" { 
#  version = "~> 2.1"
#}

#provider "external" { 
#  version = "~> 1.2"
#}

# Has harcoded variable values 
#data "external" "eksctl_create" {
#  program = ["${path.module}/get_cluster_json.sh"]
#}

#output "eksctl_info" {
#  value = data.external.eksctl_create.result
#}
