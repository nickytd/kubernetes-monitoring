# kubernetes-monitoring
A bunch of setup configurations for installing set of monitoring tools for kubernetes clusters:
* [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
* [blackbox-exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-blackbox-exporter)
* [karma](https://github.com/ibelikov/helm-karma)
  
The main purpose is to suport learning and experimentation with an easy to reconstruct environment. It builds on top of [minikube](https://minikube.sigs.k8s.io/) or [kind](https://kind.sigs.k8s.io)


# helm chart dependencies
This project depends on following helm repositories which need to be added before setting up the monitoring stack

* ```helm repo add kube-prometheus-stack  https://prometheus-community.github.io/helm-charts ```
* ```helm repo add bitnami https://charts.bitnami.com/bitnami```
* ```helm repo add stable https://charts.helm.sh/stable```

The ```./setup.sh``` support following options:
* ```--with-thanos```adds Thanos Query component exposed via gPRC enabled ingress.


* ```--with-blackbox-exporter``` installs blackbox exporter with a predefined set of url targets
* ```--with-karma``` installs karma application for alert viewing

The environment depends on ingress controller to expose the applications. Here are two examples how to enable [haproxy](https://github.com/nickytd/kubernetes-ingress-haproxy) or [nginx](https://github.com/nickytd/kubernetes-ingress-haproxy) ingress controllers

By default the external domain names for the deployed applications is ```local.dev```. All ingress definitions have tls enabled and corresponding certificates and secrets should be created. For local development the [mkcert](https://github.com/FiloSottile/mkcert) is a simple way to generate those certificates. Just create "ssl" directory and place the certificates there. Thanos query example depends on client certificate for authentication which also can be generated with mkcert tool. 
Check the [setup.sh](/setup.sh) for the expected ssl directory content and the naming of the certificates files.

To resolve those URL in local browser add them to ```/etc/hosts``` or use local dns service resolver. To support the names within a minikube cluster the configuration of coredns should be enhanced. Here is an example for patching [in-cluster coredns](https://github.com/nickytd/kubernetes-coredns-patch) in minikube



