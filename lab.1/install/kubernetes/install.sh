#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# setup_k8s_lab.sh
# Roteiro automatizado de instalação: Docker + kubectl + Minikube + Istio
# Testado em Fedora 41 (x86_64) – executar com um usuário que possua sudo
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

# ----------------------------- Funções úteis ---------------------------------
log(){ printf "\n\033[1;34m>> %s\033[0m\n" "$*"; }

# ---------------------------- Atualizações base ------------------------------
log "Atualizando o sistema e instalando utilitários básicos"
sudo dnf upgrade --refresh -y
sudo dnf install -y curl wget git conntrack jq

# ---------------------------- Instalar Docker --------------------------------
log "Instalando Docker Engine e dependências"
sudo dnf remove -y docker docker-client docker* || true       # limpa eventuais restos
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER" || true        # adiciona usuário ao grupo docker

# -------------------------- Instalar kubectl ---------------------------------
log "Baixando kubectl ${K8S_VERSION}"
curl -LO "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/
rm kubectl
kubectl version --client --output=yaml

# -------------------------- Instalar Minikube --------------------------------
log "Baixando Minikube ${MINIKUBE_VERSION} (${MINIKUBE_BIN})"
curl -LO "https://github.com/kubernetes/minikube/releases/download/${MINIKUBE_VERSION}/${MINIKUBE_BIN}"
sudo install -o root -g root -m 0755 "${MINIKUBE_BIN}" /usr/local/bin/minikube
rm "${MINIKUBE_BIN}"
minikube version

# --------------------------- Criar cluster -----------------------------------
log "Inicializando Minikube (driver Docker)"
# Ajuste CPUs/Memória conforme hardware disponível
minikube start --driver=docker --cpus=4 --memory=8192

# ---------------------------- Instalar Istio ---------------------------------
log "Baixando e instalando Istio ${ISTIO_VERSION}"
curl -L https://istio.io/downloadIstio | ISTIO_VERSION="${ISTIO_VERSION}" sh -
export PATH="$PATH:$HOME/istio-${ISTIO_VERSION}/bin"
grep -qxF 'export PATH="$PATH:$HOME/istio-'$ISTIO_VERSION'/bin"' ~/.bashrc || \
  echo 'export PATH="$PATH:$HOME/istio-'$ISTIO_VERSION'/bin"' >> ~/.bashrc

log "Instalando perfil demo do Istio"
istioctl install --set profile=demo -y
istioctl verify-install

# --------------------------- Validações finais -------------------------------
log "Cluster e Istio prontos! Resumo:"
minikube status
kubectl get nodes
