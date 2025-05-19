#!/bin/bash

# -----------------------------------------------------------------------------
# setup_k8s_lab_debian.sh
# Roteiro automatizado de instalação: Docker + kubectl + Minikube + Istio
# Adaptado para Debian 12 - executar como root
# -----------------------------------------------------------------------------

set -euo pipefail

# ----------------------------- Configurações ---------------------------------
K8S_VERSION="v1.32.0"          # Versão-alvo do cluster Kubernetes
MINIKUBE_VERSION="v1.35.0"     # Versão compatível do Minikube
ISTIO_VERSION="1.22.0"         # Versão recomendada do Istio
ARCH=$(uname -m)               # Captura a arquitetura da máquina

# Mapeia nome de arquivo para Minikube conforme arquitetura
case "$ARCH" in
x86_64)   MINIKUBE_BIN="minikube-linux-amd64" ;;
aarch64)  MINIKUBE_BIN="minikube-linux-arm64" ;;
armv7l)   MINIKUBE_BIN="minikube-linux-arm"   ;;
*)        echo "Arquitetura $ARCH não suportada"; exit 1 ;;
esac

# ----------------------------- Formata Log ---------------------------------
log(){ printf "\n\033[1;34m>> %s\033[0m\n" "$*"; }

# ---------------------------- Atualizações base ------------------------------
log "Atualizando o sistema e instalando utilitários básicos"
apt-get update
apt-get upgrade -y
apt-get install -y curl wget git conntrack jq apt-transport-https ca-certificates gnupg

# ---------------------------- Instalar Docker --------------------------------
log "Instalando Docker Engine e dependências"
apt-get remove -y docker docker-engine docker.io containerd runc || true
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker

# -------------------------- Instalar kubectl ---------------------------------
log "Baixando kubectl ${K8S_VERSION}"
curl -LO "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/
rm kubectl
kubectl version --client --output=yaml

# -------------------------- Instalar Minikube --------------------------------
log "Baixando Minikube ${MINIKUBE_VERSION} (${MINIKUBE_BIN})"
curl -LO "https://github.com/kubernetes/minikube/releases/download/${MINIKUBE_VERSION}/${MINIKUBE_BIN}"
install -o root -g root -m 0755 "${MINIKUBE_BIN}" /usr/local/bin/minikube
rm "${MINIKUBE_BIN}"
minikube version

# --------------------------- Criar cluster -----------------------------------
log "Inicializando Minikube (driver Docker)"
# Ajuste CPUs/Memória conforme hardware disponível
minikube start --driver=docker --cpus=4 --memory=8192

# ---------------------------- Instalar Istio ---------------------------------
log "Baixando e instalando Istio ${ISTIO_VERSION}"
curl -L https://istio.io/downloadIstio | ISTIO_VERSION="${ISTIO_VERSION}" sh -
export PATH="$PATH:/root/istio-${ISTIO_VERSION}/bin"
grep -qxF 'export PATH="$PATH:/root/istio-'$ISTIO_VERSION'/bin"' /root/.bashrc || 
echo 'export PATH="$PATH:/root/istio-'$ISTIO_VERSION'/bin"' >> /root/.bashrc

log "Instalando perfil demo do Istio"
istioctl install --set profile=demo -y
istioctl verify-install

# --------------------------- Validações finais -------------------------------
log "Cluster e Istio prontos! Resumo:"
minikube status
kubectl get nodes
