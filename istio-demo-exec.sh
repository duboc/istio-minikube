#!/bin/bash

########################
# include the magic
########################
. demo-magic.sh
clear

# Script
pe "brew cask install minikube"

pe "brew install docker-machine-drive-vmware"

pe "minikube config set vm-driver vmware"

pe "minikube start --memory=16384 --cpus=4 --kubernetes-version=v1.4.2"

pe "sudo minikube tunnel"

pe "kubectl get nodes"

pe "brew install kubernetes-helm"

pe "helm repo add istio.io https://storage.googleapis.com/istio-release/releases/1.2.4/charts/"

pe "curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.2.4 sh -"

pe "cd istio-1.2.4"

pe "export PATH=$PWD/bin:$PATH"

pe "kubectl create namespace istio-system"

pe "helm template install/kubernetes/helm/istio-init --name istio-init --namespace istio-system | kubectl apply -f -"

pe "kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l"

pe "helm template install/kubernetes/helm/istio --name istio --namespace istio-system --values install/kubernetes/helm/istio/values-istio-demo.yaml | kubectl apply -f -"

pe "kubectl get svc -n istio-system"