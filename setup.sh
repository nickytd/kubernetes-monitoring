#!/bin/bash

set -eo pipefail

dir=$(dirname $0)
source $dir/.includes.sh

check_executables
check_helm_chart "prometheus-community/kube-prometheus-stack"

if [[ "$1" == "-h" ]]; then
   echo "## installs kube prometheus stack ##"
   echo "   supported options:"
   echo "     --with-karma"
   echo "         adds karma applicaiton linked to the alert manager"
   echo "     --with-blackbox-exporter"
   echo "         adds blackbox-exporter with default set of url targets"
   echo "     --with-thanos"
   echo "         adds thanos query for cross cluster observability setup"
   exit
fi

kubectl create namespace monitoring \
  --dry-run=client -o yaml | kubectl apply -f -

if [ -d $dir/ssl ]; then

  certs=("prometheus" "alertmanager" "grafana")
  for c in ${certs[@]}; do
    kubectl create secret tls "$c-tls" -n monitoring \
      --cert=$dir/ssl/wildcard.crt \
      --key=$dir/ssl/wildcard.key \
      --dry-run=client -o yaml | kubectl apply -f - 
  done 
fi 

helm upgrade monitoring -n monitoring \
   -f $dir/monitoring/kube-prometheus-values.yaml prometheus-community/kube-prometheus-stack \
   --install --wait --timeout 15m
    
kubectl apply -f $dir/monitoring/system-rules.yaml -n monitoring \
   --dry-run=client -o yaml | kubectl apply -f -    
  

for dashboard in $dir/monitoring/grafana-dashboards/* ; do
echo "processing "$(basename $dashboard)""
kubectl apply -f $dashboard -n monitoring \
   --dry-run=client -o yaml | kubectl apply -f -
done


for var in "$@"
do
    if [[ "$var" = "--with-karma" ]]; then

      check_helm_chart "stable/karma"
  
      if [ -d $dir/ssl ]; then
        kubectl create secret tls "karma-tls" -n monitoring \
          --cert=$dir/ssl/wildcard.crt \
          --key=$dir/ssl/wildcard.key \
          --dry-run=client -o yaml | kubectl apply -f - 
      fi  

      helm upgrade karma -n monitoring \
        -f $dir/monitoring/karma-values.yaml stable/karma \
        --install --wait --timeout 15m

    fi  

    if [[ "$var" = "--with-blackbox-exporter" ]]; then 

      check_helm_chart "prometheus-community/prometheus-blackbox-exporter"

      if [ -d $dir/ssl ]; then
        kubectl create secret tls "blackbox-exporter-tls" -n monitoring \
          --cert=$dir/ssl/wildcard.crt \
          --key=$dir/ssl/wildcard.key \
          --dry-run=client -o yaml | kubectl apply -f - 
      fi        
      helm upgrade blackbox-exporter -n monitoring  \
        -f $dir/monitoring/blackbox-exporter-values.yaml prometheus-community/prometheus-blackbox-exporter \
        --install --wait --timeout 15m
    fi

    if [[ "$var" = "--with-thanos" ]]; then 

        check_helm_chart "bitnami/thanos"        
        
        if [ -d $dir/ssl ]; then

          kubectl create secret generic thanos-auth -n monitoring \
            --from-file=$dir/ssl/ca.crt \
            --from-file=$dir/ssl/tls.key \
            --from-file=$dir/ssl/tls.crt \
            --dry-run=client -o yaml | kubectl apply -f -

          kubectl create secret tls thanos.local.dev-tls -n monitoring \
            --cert=$dir/ssl/wildcard.crt \
            --key=$dir/ssl/wildcard.key \
            --dry-run=client -o yaml | kubectl apply -f -
        fi    

        helm upgrade thanos -n monitoring  \
        -f $dir/monitoring/thanos-values.yaml bitnami/thanos \
        --install --wait --timeout 15m  

        kubectl apply -f $dir/monitoring/thanos-sidecar.yaml -n monitoring

    fi

done