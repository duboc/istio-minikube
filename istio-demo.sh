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

p "sudo minikube tunnel"

p "kubectl get nodes"

p "brew install kubernetes-helm"

p "helm repo add istio.io https://storage.googleapis.com/istio-release/releases/1.2.4/charts/"

p "curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.2.4 sh -"

p "cd istio-1.2.4"

p "export PATH=$PWD/bin:$PATH"

p "kubectl create namespace istio-system"

p "helm template install/kubernetes/helm/istio-init --name istio-init --namespace istio-system | kubectl apply -f -"

p "kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l"

p "helm template install/kubernetes/helm/istio --name istio --namespace istio-system --values install/kubernetes/helm/istio/values-istio-demo.yaml | kubectl apply -f -"

p "kubectl get svc -n istio-system"