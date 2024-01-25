#!/usr/bin/env bash

echo "$(date): Creating secret for namespace - myname"
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com

kubectl create namespace myname --dry-run=client -o yaml | kubectl apply -f -

kubectl delete secret my-regcred -n myname

kubectl create secret docker-registry my-regcred --save-config --dry-run=client --from-file=.dockerconfigjson=$HOME/.docker/config.json -n myname -o yaml | kubectl apply -f -