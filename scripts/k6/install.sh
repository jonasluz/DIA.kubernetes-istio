#!/usr/bin/env bash
set -euo pipefail

# ---- Parâmetros editáveis -----------------------------------------------
NAMESPACE="k6-operator"
RELEASE="k6-operator"
CHART_VERSION="*"
# -------------------------------------------------------------------------

echo "⏳ Adicionando repositório Grafana Helm Charts…"
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update                                                 # :contentReference[oaicite:2]{index=2}

echo "🔧 Criando namespace “$NAMESPACE”…"
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "🚀 Instalando k6-operator…"
helm upgrade --install "$RELEASE" grafana/k6-operator \
  --namespace "$NAMESPACE"                             \
  --version "$CHART_VERSION"                           \
  --set operator.image.tag="v0.0.18"

echo "✅ k6 Operator implantado.  Use CRD TestRun para executar testes."

