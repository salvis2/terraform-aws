#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

# Return valid JSON string
eksctl get cluster --profile eksctlbot --name jupyterhub-salvis -o json | jq -r ".[] | {Arn:.Arn}"
