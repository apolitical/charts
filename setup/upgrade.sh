#!/usr/bin/env bash

# Allow unbound (no u on the next line) to give better feedback when things go wrong
set -eo pipefail
IFS=$'\n\t'

CONTEXT=$1
TEST_STRING="test"

if [ -z ${CONTEXT:+TEST_STRING} ]; then

    echo "Usage: setup <context>"
    false

fi

kubectl apply -f helm.rbac.yaml --context ${CONTEXT}
helm init --kube-context ${CONTEXT} --service-account tiller --upgrade
