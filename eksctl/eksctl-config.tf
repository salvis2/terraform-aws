# Terraform file to replace eksctl-config.yml and create_cluster.sh

# First set of data / resources are from the Terraform EKS intro
# Some adjustments may be needed

data "aws_availability_zones" "available" {

}

resource "aws_vpc" "jupyter_vpc" {
  cidr_block = "192.168.0.0/16"

  tags = {
    "Name"                                      = "terraform-eks-jupyterhub"
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_subnet" "jupyter_subnet" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block = "10.0.${count.index}.0/24"
  vpc_id = aws_vpc.jupyter_vpc.id

  tags = {
    "Name"                                      = "terraform-eks-jupyterhub"
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_internet_gateway" "jupyterhub_gateway" {
  vpc_id = aws_vpc.jupyter_vpc.id

  tags = {
    "Name" = "terraform-eks-jupyterhub"
  }
}

resource "aws_route_table" "jupyterhub_route_table" {
  vpc_id = aws_vpc.jupyter_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jupyterhub_gateway.id
  }
}

resource "aws_route_table_association" "jupyterhub_route_association" {
  count = 2

  subnet_id = aws_subnet.jupyter_subnet[count.index].id
  route_table_id = aws_route_table.jupyterhub_route_table.id
}

# Need the following
# - EKS Master Cluster IAM Role
# - EKS Master Security Group
# - EKS Master Cluster (should be aws_eks_cluster.jupyterhub below)
# - Worker Node IAM Role and Instance Profile
# - Worker Node Security Group
# - Worker Node Access to EKS Master Cluster (aws_security_group_rule)
# - Worker Node AutoScaling Group
# - "local" blocks to run preBootStrap commands?
# - Control Plan Logging

# The following set of resources are my attempts to translate 
# the YAML configuration into Terraform code
# This was done with help from the Terraform documentation

resource "aws_eks_cluster" "jupyterhub" {
  metadata:
  name: jupyterhub-salvis
  region: us-west-2

  name = "jupyterhub-salvis"
  role_arn = "${aws_iam_policy.eks_iam_role.arn}"
  vpc_config {
    subnet_ids = 
  }
}

resource "awk_eks_node_group" "core_nodes_group" {
  # YAML config
  # Lines that are commented have been turned into tf code
  #name: core
    #instanceType: m5.large
    #minSize: 1
    #maxSize: 1
    #desiredCapacity: 1
    privateNetworking: true
    #volumeSize: 100
    volumeType: gp2
    #labels:
      #node-role.kubernetes.io/core: core
      #hub.jupyter.org/node-purpose: core
    #ami: auto
    amiFamily: Ubuntu1804
  # End of YAML config

  cluster_name    = 
  node_group_name = "core"
  node_role_arn   = 
  subnet_ids      = 
  ami_type        = "auto"   # This may not be correct. auto is the default value, so maybe don't need this
  disk_size       = 100
  instance_types  = "m5.large"

  scaling_config {
    desired_size  = 1
    min_size      = 1
    max_size      = 1
  }

  labels {
    "node-role.kubernetes.io/core" = "core"
    "hub.jupyter.org/node-purpose" = "core"
  }
}

resource "awk_eks_node_group" "user_spot_nodes_group" {
  # YAML config
  # Lines that are commented have been turned into tf code
  #name: user-spot
    #minSize: 0
    #maxSize: 100
    #desiredCapacity: 0
    privateNetworking: true
    instancesDistribution:
      #maxPrice: 0.017 #default to max price = on demand price
      #instanceTypes:
      #  - m5.2xlarge
      #  - m4.2xlarge # At least two instance types should be specified
      spotInstancePools: 2
      onDemandBaseCapacity: 0
      onDemandPercentageAboveBaseCapacity: 0 # all spot
    #volumeSize: 100
    volumeType: gp2
    #labels:
    #  node-role.kubernetes.io/user: user
    #  hub.jupyter.org/node-purpose: user
    taints:
      hub.jupyter.org/dedicated: 'user:NoSchedule'
    #tags:
    #    k8s.io/cluster-autoscaler/node-template/label/hub.jupyter.org/node-purpose: user
    #    k8s.io/cluster-autoscaler/node-template/taint/hub.jupyter.org/dedicated: 'user:NoSchedule'
    #ami: auto
    amiFamily: Ubuntu1804
    preBootstrapCommands: # see https://github.com/weaveworks/eksctl/issues/1310
      - yum install -y iptables-services
      - iptables --insert FORWARD 1 --in-interface eni+ --destination 169.254.169.254/32 --jump DROP
      - iptables-save | tee /etc/sysconfig/iptables
      - systemctl enable --now iptables
  # End of YAML config

  cluster_name    = 
  node_group_name = "user-spot"
  node_role_arn   = 
  subnet_ids      = 
  ami_type        = "auto"   # This may not be correct. auto is the default value, so maybe don't need this
  disk_size       = 100
  instance_types  = [
    "m5.2xlarge",
    "m4.2xlarge"
  ]

  scaling_config {
    desired_size  = 0
    min_size      = 0
    max_size      = 100
  }

  labels {
    "node-role.kubernetes.io/user" = "user"
    "hub.jupyter.org/node-purpose" = "user"
  }

  tags {
    "k8s.io/cluster-autoscaler/node-template/label/hub.jupyter.org/node-purpose"  = "user"
    "k8s.io/cluster-autoscaler/node-template/taint/hub.jupyter.org/dedicated"     = "user:NoSchedule"
  }
}

resource "awk_eks_node_group" "worker_spot_nodes_group" {
  # YAML config
  # Lines that are commented have been turned into tf code
  #name: worker-spot
    #minSize: 0
    #maxSize: 100
    #desiredCapacity: 0
    privateNetworking: true
    instancesDistribution:
      #instanceTypes:
      #  - r5.2xlarge
      #  - r4.2xlarge
      spotInstancePools: 2
      onDemandBaseCapacity: 0
      onDemandPercentageAboveBaseCapacity: 0
    #volumeSize: 100
    volumeType: gp2
    #labels:
    #  node-role.kubernetes.io/worker: worker
    #  k8s.dask.org/node-purpose: worker
    taints:
      k8s.dask.org/dedicated: 'worker:NoSchedule'
    #tags:
    #    k8s.io/cluster-autoscaler/node-template/label/k8s.dask.org/node-purpose: worker
    #    k8s.io/cluster-autoscaler/node-template/taint/k8s.dask.org/dedicated: "worker:NoSchedule"
    #ami: auto
    amiFamily: Ubuntu1804
    preBootstrapCommands: # see https://github.com/weaveworks/eksctl/issues/1310
      - yum install -y iptables-services
      - iptables --insert FORWARD 1 --in-interface eni+ --destination 169.254.169.254/32 --jump DROP
      - iptables-save | tee /etc/sysconfig/iptables
      - systemctl enable --now iptables
  # End of YAML config

  cluster_name    = 
  node_group_name = "worker-spot"
  node_role_arn   = 
  subnet_ids      = 
  ami_type        = "auto"   # This may not be correct. auto is the default value, so maybe don't need this
  disk_size       = 100
  instance_types  = [
    "r5.2xlarge",
    "r4.2xlarge"
  ]

  scaling_config {
    desired_size  = 0
    min_size      = 0
    max_size      = 100
  }

  labels {
    "node-role.kubernetes.io/worker" = "worker"
    "hub.jupyter.org/node-purpose" = "worker"
  }

  tags {
    "k8s.io/cluster-autoscaler/node-template/label/hub.dask.org/node-purpose"  = "worker"
    "k8s.io/cluster-autoscaler/node-template/taint/hub.dask.org/dedicated"     = "worker:NoSchedule"
  }
}


apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

# list of zones (otherwise automatic)
#availabilityZones: {{eksctl.zones}}


iam:
 withOIDC: true
 serviceAccounts:
  - metadata:
      name: cluster-autoscaler
      namespace: kube-system
    attachPolicy: # inline policy can be defined along with `attachPolicyARNs`
      Version: "2012-10-17"
      Statement:
      - Effect: Allow
        Action:
          - "autoscaling:DescribeAutoScalingGroups"
          - "autoscaling:DescribeAutoScalingInstances"
          - "autoscaling:DescribeLaunchConfigurations"
          - "autoscaling:DescribeTags"
          - "autoscaling:SetDesiredCapacity"
          - "autoscaling:TerminateInstanceInAutoScalingGroup"
          - "ec2:DescribeLaunchTemplateVersions"
        Resource: '*'
