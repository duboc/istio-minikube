#!/bin/bash

########################
# include the magic
########################
. demo-magic.sh
clear

# Installing minikube
p "brew cask install minikube"

p "brew install docker-machine-drive-vmware"

p "minikube config set vm-driver vmware"

p "minikube start --memory=16384 --cpus=4 --kubernetes-version=v1.4.2"

# LoadBalancer 
p "sudo minikube tunnel"

# check kubernetes nodes
p "kubectl get nodes"

# install helm and add helm repo
p "brew install kubernetes-helm"

p "helm repo add istio.io https://storage.googleapis.com/istio-release/releases/1.2.4/charts/"

# download istio release
p "curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.2.4 sh -"

p "cd istio-1.2.4"

p "export PATH=$PWD/bin:$PATH"

# deploy istio using helm with demo profile
p "kubectl create namespace istio-system"

p "helm template install/kubernetes/helm/istio-init --name istio-init --namespace istio-system | kubectl apply -f -"

p "kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l"

p "helm template install/kubernetes/helm/istio --name istio --namespace istio-system --values install/kubernetes/helm/istio/values-istio-demo.yaml | kubectl apply -f -"

p "kubectl get svc -n istio-system"

p "kubectl get pods -n istio-system"

# deploy bookinfo app
p "kubectl label namespace default istio-injection=enabled"

p "kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml"

# testing bookinfo app with curl
p "kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>""

# getting a gateway and configuring that gateway with a external load balancer(we are using minikube tunnel for that)
p "kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml"

p "kubectl get gateway"

p "export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"

p "export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')"

p "export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')"

p "export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT"

p "curl -s http://${GATEWAY_URL}/productpage | grep -o "<title>.*</title>""

##  cleanup 
p "helm template install/kubernetes/helm/istio --name istio --namespace istio-system --values install/kubernetes/helm/istio/values-istio-demo.yaml | kubectl delete -f -"

p "kubectl delete namespace istio-system"

