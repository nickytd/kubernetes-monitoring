# kubernetes-monitoring
A bunch of setup configurations for installing set of monitoring tools for kubernetes clusters:
* [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
* [blackbox-exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-blackbox-exporter)
* [karma](https://github.com/ibelikov/helm-karma)
  


The main purpose is to suport learning and experimentation with an easy to reconstruct environment. It uses [kind](https://kind.sigs.k8s.io) to setup a local kubernetes cluster. 

Following urls are configured for the ingresses
```prometheus.local alertmanager.local grafana.local karma.local blackbox-exporter.local```

And if logging stack is also installed we have also
```kibana.local es.local```

To resolve those URL in local browser either add those to ```/etc/hosts```
