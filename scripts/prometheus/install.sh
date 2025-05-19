#!/usr/bin/env bash
set -euo pipefail

# ---- Parâmetros editáveis -----------------------------------------------
NAMESPACE="monitoring"
RELEASE="prom-lab"
CHART_VERSION="*"
# -------------------------------------------------------------------------

echo "⏳ Adicionando repositório Prometheus Community…"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update                                                # :contentReference[oaicite:0]{index=0}

echo "🔧 Criando namespace “$NAMESPACE” (se ainda não existir)…"
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "🚀 Instalando Prometheus (Helm $CHART_VERSION)…"
helm upgrade --install "$RELEASE" prometheus-community/prometheus \
  --namespace "$NAMESPACE"                                       \
  --version "$CHART_VERSION"                                     \
  --set alertmanager.enabled=false                               \
  --set pushgateway.enabled=false                                \
  --set server.resources.limits.cpu=2                            \
  --set server.resources.limits.memory=4Gi

echo "✅ Prometheus pronto em namespace “$NAMESPACE”."

