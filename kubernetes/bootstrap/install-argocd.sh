#!/bin/env bash

alias kubectl='microk8s kubectl'

argo_version="stable"

# Download the latest stable Argo CD installation manifest
curl -sSL https://raw.githubusercontent.com/argoproj/argo-cd/$argo_version/manifests/install.yaml >../argocd/argocd.yaml

kubectl create namespace argocd
kubectl apply -n argocd -f argocd.yaml
