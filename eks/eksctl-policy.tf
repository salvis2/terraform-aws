data "aws_iam_policy_document" "eksctl_policy_source" {
    version = "2012-10-17"

    statement {
        # Defaults to Allow, but I want to make sure the syntax works
        effect = "Allow"

        actions = [
            "iam:CreateInstanceProfile",
            "iam:DeleteInstanceProfile",
            "iam:GetRole",
            "iam:GetInstanceProfile",
            "iam:RemoveRoleFromInstanceProfile",
            "iam:CreateRole",
            "iam:DeleteRole",
            "iam:AttachRolePolicy",
            "iam:PutRolePolicy",
            "iam:ListInstanceProfiles",
            "iam:AddRoleToInstanceProfile",
            "iam:ListInstanceProfilesForRole",
            "iam:PassRole",
            "iam:DetachRolePolicy",
            "iam:DeleteRolePolicy",
            "iam:GetRolePolicy",
            "iam:CreatePolicy",
            "iam:DeleteServiceLinkedRole",
            "iam:CreateServiceLinkedRole",
            "iam:CreateOpenIDConnectProvider",
            "iam:GetOpenIDConnectProvider",
            "iam:DeleteOpenIDConnectProvider"
        ]

        resources = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/eksctl-*",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eksctl-*",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.*"
        ]
    }

    statement {
        effect = "Allow"

        actions = [
            "cloudformation:*",
        ]

        resources = [
            "*"
        ]
    }

    statement {
        effect = "Allow"

        actions = [
            "eks:*",
        ]

        resources = [
            "*"
        ]
    }

    statement {
        effect = "Allow"

        actions = [
            "elasticfilesystem:*",
        ]

        resources = [
            "*"
        ]
    }

    statement {
        effect = "Allow"

        actions = [
            "elasticloadbalancing:*",
        ]

        resources = [
            "*"
        ]
    }

    statement {
        effect = "Allow"

        actions = [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:DescribeScalingActivities",
            "autoscaling:CreateLaunchConfiguration",
            "autoscaling:DeleteLaunchConfiguration",
            "autoscaling:UpdateAutoScalingGroup",
            "autoscaling:DeleteAutoScalingGroup",
            "autoscaling:CreateAutoScalingGroup",
        ]

        resources = [
            "*"
        ]
    }

    statement {
        effect = "Allow"

        actions = [
            "ec2:DeleteInternetGateway",
        ]

        resources = [
            "arn:aws:ec2:*:*:internet-gateway/*"
        ]
    }

    statement {
        effect = "Allow"

        actions = [
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:DeleteSubnet",
            "ec2:DeleteTags",
            "ec2:CreateNatGateway",
            "ec2:CreateVpc",
            "ec2:AttachInternetGateway",
            "ec2:DescribeVpcAttribute",
            "ec2:DeleteRouteTable",
            "ec2:AssociateRouteTable",
            "ec2:DescribeInternetGateways",
            "ec2:CreateRoute",
            "ec2:CreateInternetGateway",
            "ec2:RevokeSecurityGroupEgress",
            "ec2:CreateSecurityGroup",
            "ec2:ModifyVpcAttribute",
            "ec2:DeleteInternetGateway",
            "ec2:DescribeRouteTables",
            "ec2:ReleaseAddress",
            "ec2:AuthorizeSecurityGroupEgress",
            "ec2:DescribeTags",
            "ec2:CreateTags",
            "ec2:DeleteRoute",
            "ec2:CreateRouteTable",
            "ec2:DetachInternetGateway",
            "ec2:DescribeNatGateways",
            "ec2:DisassociateRouteTable",
            "ec2:AllocateAddress",
            "ec2:DescribeSecurityGroups",
            "ec2:RevokeSecurityGroupIngress",
            "ec2:DeleteSecurityGroup",
            "ec2:DeleteNatGateway",
            "ec2:DeleteVpc",
            "ec2:CreateSubnet",
            "ec2:DescribeSubnets",
            "ec2:DescribeAvailabilityZones",
            "ec2:DescribeImages",
            "ec2:describeAddresses",
            "ec2:DescribeVpcs",
            "ec2:CreateLaunchTemplate",
            "ec2:DescribeLaunchTemplates",
            "ec2:RunInstances",
            "ec2:DeleteLaunchTemplate",
            "ec2:DescribeLaunchTemplateVersions",
            "ec2:DescribeImageAttribute",
            "ec2:DescribeKeyPairs",
            "ec2:ImportKeyPair",
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface",
            "ec2:ModifyNetworkInterfaceAttribute",
            "ec2:DescribeNetworkInterfaceAttribute",
        ]

        resources = [
            "*"
        ]
    }
}

resource "aws_iam_policy" "eksctl_policy" {
    name = "eksctl-policy"
    path = "/"
    description = "Permissions for EKS cluster creation and management"
    policy = data.aws_iam_policy_document.eksctl_policy_source.json
}
