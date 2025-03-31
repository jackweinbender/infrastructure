#!/bin/bash

# argocd installation
argo_version="stable"
kubectl create namespace argocd
kubectl apply -n argocd -f "https://raw.githubusercontent.com/argoproj/argo-cd/$argo_version/manifests/install.yaml"

# install cert-manager
cert_manager_version="v1.17.0"
kubectl create namespace cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/$cert_manager_version/cert-manager.yaml