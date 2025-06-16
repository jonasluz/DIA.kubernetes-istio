git submodule add https://github.com/jonasluz/microservices-demo.git vendor/online-boutique

# Implantação básica
kubectl create namespace boutique-base
kubectl apply -f vendor/online-boutique/release/kubernetes-manifests.yaml -n boutique-base
minikube service frontend-external -n boutique-base

# Verificação - aguardar todos 'Running'
kubectl get pods -n boutique-base -w

# Exposição da versão básica
minikube service frontend-external -n boutique-base


# Implantação com Istio
kubectl create namespace boutique-istio
kubectl label namespace boutique-istio istio-injection=enabled
kubectl apply -f vendor/online-boutique/release/kubernetes-manifests.yaml -n boutique-istio

# Verificação - constatar que cada pod tem 2/2 containers.
kubectl get pods -n boutique-istio -o wide

# Exposição da versão com Istio via istio gateway.
kubectl apply -n boutique-istio -f <(istioctl kube-inject -f vendor/online-boutique/release/kubernetes-manifests.yaml)



