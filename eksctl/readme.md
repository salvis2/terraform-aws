# EKS Cluster Creation

Running `./create_cluster.sh` should create the cluster as long as you have configured an awscli profile with the name 'eksbot.' The shell script runs the following command to create the cluster:

`eksctl create cluster --profile eksbot --config-file=eksctl-config.yml`

eksctl-config.yml is in this directory and dictates what resources the cluster is created with. eksctl-modify.yml is an alternate config file.

The cluster can be torn down with a similar command:

`eksctl delete cluster --profile eksbot --config-file=eksctl-config.yml --wait`

The `--wait` flag will prevent errors that arise from the eksctl trying to delete resources before their dependents are freed up.

jupyterhub-config.yml is the current file used to format the jupyterhub with Helm. https-config.yml will help more later, but it needs a program to fill out several of the fields first.

eksctl.tf is the Terraform wrapper for create_cluster.sh, but we don't recommend using it for now. Notes: 

Even if the terraform'd command to spin up the cluster works, how do you undo that? If you can't undo it in terraform, then what's the point? I think `terraform plan` runs the whole command, but doesn't tell you output. I don't like this method. Running `terraform plan` or `terraform apply` causes the shell script to be run immediately (I think because it is the "data" object), but produces the following error:
```
Error: command "./create_cluster.sh" produced invalid JSON: invalid character 'â' looking for beginning of value

on eksctl.tf line 17, in data "external" "eksctl_create":
17: data "external" "eksctl_create" {
```
But the command works. The cluster will be created after running any terraform command listed above.