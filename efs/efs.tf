# Create efs drive in same vpc as eks cluster
# NOTE: `run terraform destroy` before `eksctl delete cluster`
# ==================================
terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
  profile = var.profile
}

# Backend
terraform {
  backend "s3" {
    bucket         = "terraform-pangeo-access-state-alvis"
    key            = "efs/terraform-jupyter-efs.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-pangeo-access-locks-alvis"
    encrypt        = true
  }
}

# DATA
# --------
data "aws_eks_cluster" "jupyterhub" {
  name = "jupyterhub"
}

data "aws_subnet_ids" "select" {
  vpc_id = data.aws_eks_cluster.jupyterhub.vpc_config.0.vpc_id

  tags = {
    Name = "*Private*"
  }
}

# Converts 'set' type to 'list'
data "aws_subnet" "private" {
  count = length(data.aws_subnet_ids.select.ids)
  id    = tolist(data.aws_subnet_ids.select.ids)[count.index]
}


data "aws_security_groups" "select" {
  filter {
    name   = "vpc-id"
    values = [data.aws_eks_cluster.jupyterhub.vpc_config.0.vpc_id]
  }
  
  filter {
    name   = "group-name"
    values = ["*ClusterSharedNodeSecurityGroup*"]
  }
}

# OUTPUTS
# --------
output "subnet_ids" {
  value = [data.aws_subnet.private.*.id]
}

output "eks_sg" {
  value = data.aws_eks_cluster.jupyterhub.vpc_config.0.cluster_security_group_id
}


# RESOURCES
# --------
resource "aws_efs_file_system" "jhub_efs" {
  tags = {
    Name = "EFS for EKS"
  }
}

# One for each private subnet
resource "aws_efs_mount_target" "jhub_efs_mount" {
   count            = length(data.aws_subnet.private)
   file_system_id   = aws_efs_file_system.jhub_efs.id
   subnet_id        = data.aws_subnet.private[count.index].id
   security_groups  = [aws_security_group.jhub_efs_sg.id]
 }

resource "aws_security_group" "jhub_efs_sg" {
   name   = "jhub-efs-sg"
   vpc_id = data.aws_eks_cluster.jupyterhub.vpc_config.0.vpc_id 

   # NFS
   ingress {
     security_groups  = data.aws_security_groups.select.ids
     from_port        = 2049
     to_port          = 2049
     protocol         = "tcp"
   }
 }
