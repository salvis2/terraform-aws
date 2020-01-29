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

Note: It may feel like there are a lot of different moving parts to this setup. This is true. Currently, Terraform and eksctl are both used to create infrastructure on AWS. eksctl requires much less configuration than Terraform, but has a much more limited set of use cases and can only affect one cloud provider. In the future, we hope to have everything spun up on Terraform. 

Once the cluster is set up, we need to install software on the it. We do this with `kubectl apply` and `helm upgrade`, which are two different softwares. Kubectl is the kubernetes command line tool, which we use to install software that are completely defined in local files (k8s-autoscaler.yml). Helm is the kubernetes package manager, which can find and deploy software that is publicly available online. We pass configuration files with Helm to override default settings.

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
  - `terraform apply`
- Every folder whose state file you want stored on S3 needs a block in a .tf file
  - Example: the `terraform { backend "s3" {...} }` block in eks.tf tells Terraform where to store and retrieve the state file

### Basic Pangeo JupyterHub Install

- Go to eks directory and make the IAM Role / permissions
  - `terraform init`
  - `terraform plan`
  - `terraform apply`
- Make new aws keys and a new profile for them, configure in terminal
  - `aws configure --profile eksctlbot`
- Go to eksctl directory and make the cluster
  - `./create_cluster.sh`
- Install the autoscaler
  - `kubectl apply -f k8s-autoscaler.yml`
- Install JupyterHub Helm chart onto cluster
  - [`kubectl create ns jhub`](https://github.com/helm/helm/issues/5753#issue-445472415)
    - [Why](https://github.com/helm/helm/issues/5753#issuecomment-502163585)
  - Add repo, update, install chart as below
    - `helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/`
    - `helm repo upgrade`
    - `helm upgrade --install jhub jupyterhub/jupyterhub -n jhub --version=0.9.0-beta.3 --values basic-jupyterhub-config.yml`
  - Enabling HTTPS
    -`basic-jupyterhub-config.yml` should have an https block that is disabled. Run `kubectl get svc -n jhub` and go to the external IP for the proxy-public service in your web browser.
    - Go to your hosted domain and create an A record pointing to the external IP above.
    - Wait until you can type in your hosted domain and get a Timeout error.
    - Go back into `basic-jupyterhub-config.yml` and comment out the `enabled: false` line.
    - Uncomment the four lines below (hosts, your hosted domain, letsencrypt, and contactEmail)
    - Re run the `helm upgrade` command as above.
- Go to efs directory and create the EFS for JupyterHub users' files
  - `terraform init`
  - `terraform plan`
  - `terraform apply`

### Uninstall

- `helm delete jhub --namespace jhub`
- `kubectl delete namespace jhub`
- In the efs folder
  - `terraform destroy`
- In the eksctl folder
  - `eksctl delete cluster --profile eksctlbot --config-file=eksctl-config.yml --wait`
- In the eks folder
  - `terraform destroy`
- If you created the S3 Backend, in the s3backend folder
  - `terraform destroy`
