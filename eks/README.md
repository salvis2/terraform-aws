# set up required infrastructure for deploying jupyterhub on eks

eksctl simplifies cluster creation and management, but doesn't do it all:

1) Need an iam user with cluster management permissions
2) Need an EFS drive for user home directories
3) Need policies giving hub users access to S3 buckets

### Keep an eye on [eksctl integration](https://github.com/weaveworks/eksctl/issues/1094) w/ terraform (would enable single script!)
