# kubernetes-monitoring
A bunch of setup configurations for installing set of monitoring tools for kubernetes clusters:
* [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
* [blackbox-exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-blackbox-exporter)
* [karma](https://github.com/ibelikov/helm-karma)
  
The main purpose is to suport learning and experimentation with an easy to reconstruct environment. It uses [kind](https://kind.sigs.k8s.io) to setup a local kubernetes cluster. 

Use ```setup-cluster.sh``` to create a local development cluster. The cluster features a nginx based ingress controller.
Add  kube-prometheus-stack helm repo with ```helm repo add	https://prometheus-community.github.io/helm-charts ``` and stable repo with ```helm repo add https://charts.helm.sh/stable```

Execute ```./install-monitoring.sh``` to provision the monitoring stack

Following urls are configured for the ingresses
```prometheus.local alertmanager.local grafana.local karma.local blackbox-exporter.local```


To resolve those URL in local browser add those to ```/etc/hosts``` or use local dns service resolver
