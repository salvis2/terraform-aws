# Create an IAM user that can create and manage EKS clusters
# =======================
terraform {
  required_version = ">= 0.12.0"
}

#terraform {
#  backend "s3" {
#    bucket         = "terraform-pangeo-access-state-alvis"
#    key            = "eks-role/terraform-eks-role.tfstate"
#    region         = "us-west-2"
#    dynamodb_table = "terraform-pangeo-access-locks-alvis"
#    encrypt        = true
#  }
#}

provider "aws" {
  version = "~> 2.40"
  profile = var.profile
  region  = var.region
}

provider "template" {
  version = "~> 2.1"
}

# DATA
# -----------------------
data "aws_caller_identity" "current" {}

# Outputs to terminal on tf apply
#output "account_id" {
#  value = data.aws_caller_identity.current.account_id
#}

# RESOURCES
# ----------------------
resource "aws_iam_user" "user" {
  name = var.iam_user
}

resource "aws_iam_policy" "policy" {
  name        = "eksctl-policy"
  description = "Permissions for EKS cluster creation and management"
  policy      = templatefile("eksctl-policy.json.tpl", {account_id = data.aws_caller_identity.current.account_id})
}

resource "aws_iam_user_policy_attachment" "attach-eksctl-permissions" {
  user        = aws_iam_user.user.name
  policy_arn  = aws_iam_policy.policy.arn
}
