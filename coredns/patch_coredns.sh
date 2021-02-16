#!/bin/bash

set -eo pipefail

dir=$(dirname $0)

echo "apply coredns patch"

IP=$(minikube ip)

if [ -z $IP ]; then
	echo "cannot get minikube ip"
	exit 1
fi


sed "s/minikube_ip/$IP/g" hosts > local.dev.hosts

kubectl apply -k . --dry-run=client -o yaml | \
  kubectl apply -f -

