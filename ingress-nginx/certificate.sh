#!/bin/bash

set -eo pipefail

dir=$(dirname $0)
domain=$1

if [[ -z $domain ]]; then
	domain="develop"
fi

echo "create self signed wildcard certificate for $domain"

rm -f wildcard.*

openssl req -nodes -newkey rsa:2048 -new -sha256 \
  -keyout $dir/wildcard.$domain.key \
  -out $dir/wildcard.$domain.csr \
  -subj "/O=develop/CN=*.$domain"

openssl req -text -in $dir/wildcard.$domain.csr -noout -verify

openssl x509 -req -signkey $dir/wildcard.$domain.key -days 365 \
  -in $dir/wildcard.$domain.csr -out $dir/wildcard.$domain.crt
