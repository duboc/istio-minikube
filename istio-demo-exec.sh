#!/bin/bash

########################
# include the magic
########################
. demo-magic.sh
clear

# Installing minikube
pe "brew cask install minikube"

pe "brew install docker-machine-drive-vmware"

pe "minikube config set vm-driver vmware"

pe "minikube start --memory=16384 --cpus=4 --kubernetes-version=v1.4.2"

# LoadBalancer 
pe "sudo minikube tunnel"

# check kubernetes nodes
pe "kubectl get nodes"

# install helm and add helm repo
pe "brew install kubernetes-helm"

pe "helm repo add istio.io https://storage.googleapis.com/istio-release/releases/1.2.4/charts/"

# download istio release
pe "curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.2.4 sh -"

pe "cd istio-1.2.4"

pe "export PATH=$PWD/bin:$PATH"

# deploy istio using helm with demo profile
pe "kubectl create namespace istio-system"

pe "helm template install/kubernetes/helm/istio-init --name istio-init --namespace istio-system | kubectl apply -f -"

pe "kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l"

pe "helm template install/kubernetes/helm/istio --name istio --namespace istio-system --values install/kubernetes/helm/istio/values-istio-demo.yaml | kubectl apply -f -"

pe "kubectl get svc -n istio-system"

pe "kubectl get pods -n istio-system"

# deploy bookinfo app
pe "kubectl label namespace default istio-injection=enabled"

pe "kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml"

# testing bookinfo app with curl
pe "kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>""

# getting a gateway and configuring that gateway with a external load balancer(we are using minikube tunnel for that)
pe "kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml"

pe "kubectl get gateway"

pe "export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"

pe "export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')"

pe "export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')"

pe "export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT"

pe "curl -s http://${GATEWAY_URL}/productpage | grep -o "<title>.*</title>""

##  cleanup 
pe "helm template install/kubernetes/helm/istio --name istio --namespace istio-system --values install/kubernetes/helm/istio/values-istio-demo.yaml | kubectl delete -f -"

pe "kubectl delete namespace istio-system"

