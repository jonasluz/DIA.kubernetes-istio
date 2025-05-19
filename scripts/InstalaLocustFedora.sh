#!/bin/bash
#
# Prepara o ambiente básico para executar o teste de carga com Locust (Fedora)
#
# Autor: Pedro Jardelino - pedro@jardelino.com.br

set -euo pipefail

echo "Preparação do Locust:"
echo "1 - Instalação e configuração completa."
echo "2 - Gerar apenas o script para Locust"
read -r opcao

case $opcao in
    1)
        echo "### Instalando pacotes necessários com DNF..."
        dnf update -y
        dnf install -y python3-locust python3-numpy

        echo "### Ajustando limites de arquivos para o root..."
        echo 'root            soft    nofile          100000' >> /etc/security/limits.conf

        echo "### Aplicando configurações do sysctl..."
        sysctl -p

        echo "#### Locust instalado e script carga.py criado em $(pwd) para teste de carga. ####"
        echo "#### Execute: locust -f carga.py --host=https://www.jardelino.local ####"
        ;;
    2)
        echo "#### Script carga.py criado no diretório local $(pwd) ####"
        ;;
    *)
        echo "#### Opção inválida. Por favor, escolha entre 1 ou 2. ####"
        exit 1
        ;;
esac

# Cria o script de teste de carga
cat <<'EOF' > carga.py
from locust import HttpUser, TaskSet, task, between
import time

class WebsiteTasks(TaskSet):
    def on_start(self):
        self.client.verify = False  # certificado autoassinado

    @task
    def test_pages(self):
        pages = [
            "/",
            "/?p=152",
            "/?p=151",
            "/?p=136",
            "/?p=132",
            "/?p=128"
        ]
        for page in pages:
            self.client.get(page, name=f"Access {page}")
            time.sleep(5)

class WebsiteUser(HttpUser):
    tasks = [WebsiteTasks]
    wait_time = between(1, 2)
EOF
