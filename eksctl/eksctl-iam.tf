### All IAM Resources for the EKSCTL configuration

## Resources for the Cluster Control Plane

# Role data
data "aws_iam_policy_document" "eks_iam_role_data" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = "eks.amazonaws.com"
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

# The role itself
resource "aws_iam_policy" "eks_iam_role" {
  name    = "eks-cluster-role-salvis"
  path    = "/"
  policy  = "${data.aws_iam_policy_document.eks_iam_role_data.json}"
}

# Attach existing policies to role
resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role        = "${aws_iam_role.example.name}"
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSServicePolicy" {
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role        = "${aws_iam_role.example.name}"
}

## IAM Roles for Service Accounts

# Here is the YAML for the existing service account 
#iam:
 withOIDC: true
# serviceAccounts:
  - metadata:
      name: cluster-autoscaler
      namespace: kube-system
#    attachPolicy: # inline policy can be defined along with `attachPolicyARNs`
#      Version: "2012-10-17"
#      Statement:
#      - Effect: Allow
#        Action:
#          - "autoscaling:DescribeAutoScalingGroups"
#          - "autoscaling:DescribeAutoScalingInstances"
#          - "autoscaling:DescribeLaunchConfigurations"
#          - "autoscaling:DescribeTags"
#          - "autoscaling:SetDesiredCapacity"
#          - "autoscaling:TerminateInstanceInAutoScalingGroup"
#          - "ec2:DescribeLaunchTemplateVersions"
#        Resource: '*'

# Here is the Terraform Code

data "aws_iam_policy_document" "service-account-policy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups"
      "autoscaling:DescribeAutoScalingInstances"
      "autoscaling:DescribeLaunchConfigurations"
      "autoscaling:DescribeTags"
      "autoscaling:SetDesiredCapacity"
      "autoscaling:TerminateInstanceInAutoScalingGroup"
      "ec2:DescribeLaunchTemplateVersions"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "jupyterhub-serviceaccount" {
  name = "jupyterhub-serviceaccount-salvis"
  path = "/"
  policy = "${data.aws_iam_policy_document.jupyterhub-serviceaccount.json}"
}




















