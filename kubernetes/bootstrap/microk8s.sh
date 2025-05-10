# Commands to bootstrap microk8s on a new host.
# These commands are idempotent, so you can run them multiple times without issues.
alias kubectl='microk8s kubectl'
alias k='microk8s kubectl'

# DNS is required for most applications to resolve service names within the cluster.
# in my case, argocd is the key app that needs this
microk8s enable dns

# `ingress` here is the ingress-nginx controller, which is an official Kubernetes
# project that manages external access to the services in a cluster.
microk8s enable ingress
