#!/bin/bash

set -eo pipefail

dir=$(dirname $0)

echo "setting up monitoring stack"

kubectl create namespace monitoring \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f $dir/monitoring/blackbox-targets.yaml -n monitoring \
   --dry-run=client -o yaml | kubectl apply -f -

helm upgrade monitoring -n monitoring \
   -f $dir/monitoring/kube-prometheus-values.yaml prometheus-community/kube-prometheus-stack \
   --install --wait --timeout 15m

helm upgrade blackbox-exporter -n monitoring  \
   -f $dir/monitoring/blackbox-exporter-values.yaml prometheus-community/prometheus-blackbox-exporter \
   --install --wait --timeout 15m

helm upgrade karma -n monitoring \
    -f $dir/monitoring/karma-values.yaml stable/karma \
    --install --wait --timeout 15m
    
kubectl apply -f $dir/monitoring/system-rules.yaml -n monitoring \
   --dry-run=client -o yaml | kubectl apply -f -    

kubectl apply -f $dir/monitoring/blackbox-rules.yaml -n monitoring \
   --dry-run=client -o yaml | kubectl apply -f -   

for dashboard in $dir/monitoring/grafana-dashboards/* ; do
echo "processing "$(basename $dashboard)""
kubectl apply -f $dashboard -n monitoring \
   --dry-run=client -o yaml | kubectl apply -f -
done