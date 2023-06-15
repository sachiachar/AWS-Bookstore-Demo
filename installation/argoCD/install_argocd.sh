#!/bin/bash

NAME_SPACE = argocd

kubectl create namespace $NAME_SPACE

kubectl get ns

kubectl apply -n $NAME_SPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl get all -n $NAME_SPACE

kubectl -n $NAME_SPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
