# Terraform with Pangeo JupyterHub

## Terraform Documentation

Good examples here:
https://github.com/terraform-providers/terraform-provider-aws/tree/master/examples 

And Terraform Docs:
https://learn.hashicorp.com/terraform/getting-started/variables
https://www.terraform.io/docs/providers/aws/index.html

Good info on iam json specification options:
https://learn.hashicorp.com/terraform/aws/iam-policy

## Motivation

Currently, the setup for a JupyterHub has a lot of variablity. This is unideal for new users who just want a working example with acceptable security, a few image options, and other features common to geoscience workflows.

This repository will help us enforce a documentation onto the Pangeo JupyterHub deployment. The added benefit of using Terraform is that a lot of the AWS infrastructure can now be written as code. This aids in readability, reproducability, and flexibility. Terraform is a provider-agnostic Infrastructure-as-Code (IAC) tool, free to use, and has a decently large user group.

## Repo Contents

The ec2 folder has Terraform files to setup an AWS EC2 instance.

The efs folder has Terraform files to setup an AWS EFS instance.

The eks folder has Terraform files to setup an IAM user / policy set for cluster management.

The eksctl folder has the EKS cluster configuration files and scripts to launch a cluster with that configuration. There are also Terraform files to wrap the scripts, but we don't recommend using them right now.

The s3 folder has json and template files for setting up some S3 buckets. No Terraform yet.

The s3backend folder has Terraform files to setup an S3 bucket and DynamoDB table for use as a Terraform backend.

Currently, JupyterHub creation can be done with the eks and eksctl folders, and the s3backend folder can be used optionally.

## Required Packages


[awscli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv1.html)
: Allows command-line calls to the AWS API

[eksctl](https://eksctl.io/introduction/installation/)
: Allows EKS cluster creation via command line / AWS API

[kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
: Allows managing of Kubernetes (k8s) via command line

[Terraform](https://learn.hashicorp.com/terraform/getting-started/install)
: Infrastructure as Code package, allows us to define files to configure AWS resources

[Helm 3](https://github.com/helm/helm#install)
: Kuberenetes package manager, used to install a "Helm Chart" where the JupyterHub's dependencies are defined

## JupyterHub Creation

### Terraform's S3 Backend Setup

- Go to s3backend directory and make the bucket and table
 - `terraform init`
 - `terraform plan`
 - `terraform apply'`
- Go to eks directory
 - Add backend code to eks directory
 - Code should already be present, just needs to be uncommented
 - It is the `terraform { backend "s3" {...} }` block

### Basic Pangeo JupyterHub Install

- Go to eks directory and make the IAM Role / permissions
 - `terraform init`
 - `terraform plan`
 - `terraform apply'`
- Make new aws keys and a new profile for them, configure in terminal
 - `aws configure --profile eksbot`
- Go to eksctl directory and make the cluster
 - `./create_cluster.sh`
- Install JupyterHub Helm chart onto cluster
 - [`kubectl create ns jhub`](https://github.com/helm/helm/issues/5753#issue-445472415)
  - [Why](https://github.com/helm/helm/issues/5753#issuecomment-502163585)
 - Add repo, update, install chart as below
 - `helm upgrade --install $RELEASE jupyterhub/jupyterhub --namespace $NAMESPACE --version=0.8.2 --values jupyterhub-config.yml`

### Uninstall

- `helm delete jhub --namespace jhub`
- `kubectl delete namespace jhub`
- In the eksctl folder
 - `eksctl delete cluster --profile eksbot --config-file=eksctl-config.yml --wait`
- In the eks folder
 - `terraform destroy`
- If you created the S3 Backend, in the s3backend folder
 - `terraform destroy`
