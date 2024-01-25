#!/bin/bash

set -x

PARAMETER_COUNT=0

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
    echo -e "Usage: ./install.sh [-cn|--cluster-name <value>] [-ns|--namespace <value> (default: sensor)] [-it|--image-tag <value> (deafult: latest)] [-l|--labels <value1;value2;value3> (deafult blank)]"
    exit 0
    ;;
    -cn|--cluster-name)
    CLUSTER_NAME="$2"
    PARAMETER_COUNT=$((PARAMETER_COUNT + 1))
    shift
    shift
    ;;
    -ns|--namespace)
    NAMESPACE="${2:-sensor}"
    PARAMETER_COUNT=$((PARAMETER_COUNT + 1))
    shift
    shift
    ;;
    -l|--labes)
    LABELS="${2:-''}"
    PARAMETER_COUNT=$((PARAMETER_COUNT + 1))
    shift
    shift
    ;;
    -it|--image-tag)
    IMAGE_TAG="${2:-latest}"
    PARAMETER_COUNT=$((PARAMETER_COUNT + 1))
    shift
    shift
    ;;
    *)
    echo "Error: Invalid parameter: $1"
    exit 1
    ;;
esac
done

[[ $PARAMETER_COUNT -eq 4 ]] || { echo "Incorrect number of parameters."; exit 1; }

CLUSTER_NAME=$(echo "$CLUSTER_NAME" | tr '[:upper:]' '[:lower:]')

[[ ${#CLUSTER_NAME} -lt 253 ]] || { echo "Cluster Name length may not exceed 253 characters."; exit 1; }

[[ "$CLUSTER_NAME" =~ '^[[:alnum:]-\.]+$' && $CLUSTER_NAME =~ '^[[:alnum:]].*[[:alnum:]]$' ]] || { echo "Cluster Name may only contain alphanumeric, dash and dot characters and it must begin and end with alphanumeric characters."; exit 1; }

echo "Cluster Name: $CLUSTER_NAME"

NAMESPACE=$(echo "$NAMESPACE" | tr '[:upper:]' '[:lower:]')

[[ ${#NAMESPACE} -lt 63 ]] || { echo "Namespace length may not exceed 63 characters."; exit 1; }

[[ "$NAMESPACE" =~ '^[[:alnum:]-]+$' &&  ]] || { echo "Namespace may only contain alphanumeric and dash characters."; exit 1; }

echo "Namespace: $NAMESPACE"

read -p "If you wish to enter some labels e.g. some;labels;here, please type them in else type [Nn] to skip: " LABELS
if [[ $LABELS =~ ^[Nn]$ ]]; then
  echo "Skipping labels..."
  LABELS=""
else
  echo "You entered: $LABELS"
fi

# Curl call the GitHub Packages to generate a token
# Use token to generate a secret

helm repo add sensor-chart <replace with correct url> && helm repo update

helm upgrade --install sensor sensor <repo-name> --username talo --password "LHkXTv&6%r" --create-namespace --namespace $NAMESPACE --set env.SENSOR_CLUSTER_NAME="$CLUSTER_NAME",env.SENSOR_CUSTOM_LABELS="$LABELS",image.tag="$IMAGE_TAG"