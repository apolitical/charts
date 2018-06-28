#!/usr/bin/env bash

# Allow unbound (no u on the next line) to give better feedback when things go wrong
set -eo pipefail
IFS=$'\n\t'

CONTEXT=$1

if [ -z ${CONTEXT:+TEST_STRING} ]; then

    echo "Usage: setup <context>"
    false

fi

helm init --kube-context ${CONTEXT}
kubectl create serviceaccount --namespace kube-system tiller --context ${CONTEXT}
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller --context ${CONTEXT}
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}' --context ${CONTEXT}
