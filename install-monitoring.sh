#!/bin/bash

set -eo pipefail

dir=$(dirname $0)

echo "setting up monitoring stack"
echo "options: --with-blackbox-exporter --with-karma --with-thanos --with-lb"

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

      echo "creating blackbox-exporter"

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

    if [[ "$var" = "--with-lb" ]]; then
      echo "creating kibana LoadBalancer"

      kubectl expose svc/monitoring-kube-prometheus-prometheus \
        -n monitoring --name prometheus-lb --type=LoadBalancer \
        --port 9090 --target-port=9090 \
        --dry-run=client -o yaml | kubectl apply -f -

      kubectl expose svc/monitoring-kube-prometheus-alertmanager \
        -n monitoring --name alertmanager-lb --type=LoadBalancer \
        --port 9093 --target-port=9093 \
        --dry-run=client -o yaml | kubectl apply -f -

      kubectl expose svc/monitoring-grafana \
        -n monitoring --name grafana-lb --type=LoadBalancer \
        --port 3000 --target-port=3000 \
        --dry-run=client -o yaml | kubectl apply -f -    

      kubectl expose svc/blackbox-exporter-prometheus-blackbox-exporter \
        -n monitoring --name blackbox-exporter-lb --type=LoadBalancer \
        --port 9115 --target-port=9115 \
        --dry-run=client -o yaml | kubectl apply -f -  

      kubectl expose svc/karma \
        -n monitoring --name karma-lb --type=LoadBalancer \
        --port 8000 --target-port=8000 \
        --dry-run=client -o yaml | kubectl apply -f -  

    fi    

    if [[ "$var" = "--with-thanos" ]]; then 

        echo "creating thanos"
        if [ -d $dir/ssl ]; then
          kubectl create secret tls thanos.local.dev-tls -n monitoring \
            --cert=$dir/ssl/wildcard.crt \
            --key=$dir/ssl/wildcard.key \
            --dry-run=client -o yaml | kubectl apply -f -
        fi    

        helm upgrade thanos -n monitoring  \
        -f $dir/monitoring/thanos-values.yaml bitnami/thanos \
        --install --wait --timeout 15m  

    fi

done