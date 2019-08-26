#!/bin/bash

########################
# include the magic
########################
. demo-magic.sh
clear

# Script
p "brew cask install minikube"

p "brew install docker-machine-drive-vmware"

p "minikube config set vm-driver vmware"

p "minikube start --memory=16384 --cpus=4 --kubernetes-version=v1.4.2"

pe "kubectl get nodes"

pe "brew install kubernetes-helm"

pe "helm repo add istio.io https://storage.googleapis.com/istio-release/releases/1.2.4/charts/"