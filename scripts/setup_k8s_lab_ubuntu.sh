#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# setup_k8s_lab_ubuntu.sh
# Instalação automatizada: Docker + kubectl + Minikube + Istio
# Otimizado para Ubuntu 24.04 LTS - executar com sudo
# -----------------------------------------------------------------------------

# Configurações de segurança: 
# -e = sai imediatamente se algum comando falhar
# -u = trata variáveis não definidas como erro
# -o pipefail = considera falha em qualquer comando do pipeline
set -euo pipefail

# ----------------------------- CONFIGURAÇÕES ---------------------------------
K8S_VERSION="v1.30.0"           # Versão estável do Kubernetes
MINIKUBE_VERSION="v1.33.0"      # Versão do Minikube testada com Ubuntu 24.04
ISTIO_VERSION="1.22.0"          # Versão LTS do Istio
ARCH=$(uname -m)                # Arquitetura do sistema (x86_64, arm64, etc)
USERNAME=$(logname)             # Obtém o nome do usuário original (não root)

# Mapeamento de binários por arquitetura
case "$ARCH" in
x86_64)   MINIKUBE_BIN="minikube-linux-amd64" ;;
aarch64)  MINIKUBE_BIN="minikube-linux-arm64" ;;
*)        echo "Arquitetura não suportada: $ARCH"; exit 1 ;;
esac

# ----------------------------- FUNÇÕES ÚTEIS --------------------------------

# Exibe mensagens de log formatadas em azul
log() {
    printf "\n\033[1;34m>> %s\033[0m\n" "$*"
}

# Executa comandos como o usuário original (não como root)
run_as_user() {
    sudo -u "$USERNAME" "$@"
}

# -------------------------- ATUALIZAÇÃO DO SISTEMA --------------------------
log "Atualizando pacotes do sistema"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y \
    curl \
    wget \
    git \
    conntrack \
    jq \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# ------------------------- INSTALAÇÃO DO DOCKER -----------------------------
log "Instalando Docker Engine"
# Remove versões anteriores se existirem
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

# Configura repositório oficial do Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instala pacotes do Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Adiciona usuário ao grupo docker
log "Adicionando usuário ao grupo docker"
sudo usermod -aG docker "$USERNAME"

# ----------------------- INSTALAÇÃO DO KUBECTL ------------------------------
log "Instalando kubectl $K8S_VERSION"
curl -LO "https://dl.k8s.io/release/$K8S_VERSION/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
kubectl version --client --output=yaml

# ----------------------- INSTALAÇÃO DO MINIKUBE -----------------------------
log "Instalando Minikube $MINIKUBE_VERSION ($MINIKUBE_BIN)"
curl -LO "https://github.com/kubernetes/minikube/releases/download/$MINIKUBE_VERSION/$MINIKUBE_BIN"
sudo install -o root -g root -m 0755 "$MINIKUBE_BIN" /usr/local/bin/minikube
rm "$MINIKUBE_BIN"
minikube version

# ------------------------ CRIAÇÃO DO CLUSTER --------------------------------
log "Iniciando cluster Minikube (driver Docker)"
run_as_user minikube start --driver=docker --cpus=4 --memory=8192

# ----------------------- INSTALAÇÃO DO ISTIO --------------------------------
log "Instalando Istio $ISTIO_VERSION"
curl -L https://istio.io/downloadIstio | ISTIO_VERSION="$ISTIO_VERSION" sh -
sudo mv "istio-$ISTIO_VERSION" "/opt/istio-$ISTIO_VERSION"
echo "export PATH=\$PATH:/opt/istio-$ISTIO_VERSION/bin" | sudo tee /etc/profile.d/istio.sh > /dev/null
source /etc/profile.d/istio.sh

log "Instalando perfil 'demo' do Istio"
sudo -E istioctl install --set profile=demo -y
istioctl verify-install

# ------------------------ VALIDAÇÃO FINAL -----------------------------------
log "Configuração do laboratório Kubernetes concluída!"
log "Status do cluster:"
run_as_user minikube status
log "Nodes disponíveis:"
run_as_user kubectl get nodes

log "Para usar comandos do Istio em novos terminais, execute:"
echo "source /etc/profile.d/istio.sh"
