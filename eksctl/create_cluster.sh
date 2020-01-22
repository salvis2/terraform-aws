#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

# Check if cluster exists first
eksctl create cluster --profile eksctlbot --config-file=eksctl-config.yml

# Return valid JSON string
eksctl get cluster --profile eksctlbot --name jupyterhub-salvis -o json | jq -r ".[] | {Arn:.Arn}"
