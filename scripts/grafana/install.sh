#!/usr/bin/env bash
set -euo pipefail

# ---- Parâmetros editáveis -----------------------------------------------
ISTIO_VERSION="1.23.0"
ISTIO_OS="linux-amd64"   
# -------------------------------------------------------------------------

TMP_DIR="$(mktemp -d)"
ARCHIVE="istio-${ISTIO_VERSION}-${ISTIO_OS}.tar.gz"
BASE_URL="https://github.com/istio/istio/releases/download/${ISTIO_VERSION}"

echo "⏳ Baixando Istio ${ISTIO_VERSION}…"
curl -sSL "${BASE_URL}/${ARCHIVE}" -o "${TMP_DIR}/${ARCHIVE}"
tar -xzf "${TMP_DIR}/${ARCHIVE}" -C "${TMP_DIR}"

echo "🚀 Aplicando addon Grafana do Istio…"
kubectl apply -f "${TMP_DIR}/istio-${ISTIO_VERSION}/samples/addons/grafana.yaml"  # :contentReference[oaicite:1]{index=1}

echo "✅ Grafana implantado no namespace istio-system."

