#!/bin/bash

# SSH into the new host and run this script to bootstrap microk8s and install Argo CD.
# Ensure you have microk8s installed on the host before running this script.
# Save yourself some trouble and use `ssh -L 8080:localhost:8080 user@remote-host`
# to forward the port for accessing the Argo CD UI when the time comes.

alias kubectl='microk8s kubectl'
alias k='microk8s kubectl'

# Enable microk8s modules
microk8s enable dns
microk8s enable ingress

# Install Argo CD
argo_version="stable"
microk8s kubectl create namespace argocd
microk8s kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Print the initial admin password for Argo CD
echo "Argo CD initial admin password: $(microk8s kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"
# Delete Argo CD initial admin password secret
microk8s kubectl -n argocd delete secret argocd-initial-admin-secret
echo "Argo CD initial admin password secret deleted."

# Add port forwarding to access the Argo CD UI
microk8s kubectl port-forward svc/argocd-server -n argocd 8080:443
