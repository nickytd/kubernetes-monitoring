#!/bin/bash

set -eo pipefail

dir=$(dirname $0)
domain=$1

if [[ -z $domain ]]; then
	domain="local.dev"
fi

echo "apply minikube ip patch"

IP=$(minikube ip)

if [ -z $IP ]; then
	echo "cannot get minikube ip"
	exit 1
fi


sed "s/minikube_ip/$IP/g" $dir/certificate_patch.cnf > $dir/certificate.cnf

echo "create self signed wildcard certificate for $domain"

rm -f wildcard.*

openssl req -nodes -newkey rsa:2048 -new -sha256 \
  -keyout $dir/wildcard.$domain.key \
  -out $dir/wildcard.$domain.csr \
  -config $dir/certificate.cnf  

openssl req -text -in $dir/wildcard.$domain.csr -noout -verify

openssl x509 -req -signkey $dir/wildcard.$domain.key -days 365 \
  -in $dir/wildcard.$domain.csr -out $dir/wildcard.$domain.crt
