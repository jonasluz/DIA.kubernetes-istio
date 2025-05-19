#!/bin/bash
#
# Prepara o ambiente básico para executar o teste de carga com Locust
#
# Autor: Pedro Jardelino - pedro@jardelino.com.br


#Definindo a execução
#============================================

echo "Preparação do Locust:"
echo "1 - Instalação e configuração completa."
echo "2 - Gerar apenar o script para Locust"
read -r opcao


case $opcao in
    1)
        #Pacotes necessários:
        #
        apt update && apt install -y python3-locust python3-numpy

        #Ajuste do ambiente
        #
        echo 'root            soft    nofile          100000' >> /etc/security/limits.conf

        #Redefinir a variável de sistema para o super usuário. Será redefinida quando o usuário logar novamente.
        #
        sysctl -p

        echo "#### Locust instalado e script carga.py criado em `pwd` para teste de carga. ####"

        echo "#### Execute:  locust -f carga.py --host=https://www.jardelino.local  ####"
        ;;
    2)
        # 
        echo "#### Script carga.py criado no diretório local `pwd` ####"
        ;;
    *)
        # Caso a opção seja inválida - Encerrar o script
        echo "#### Opção inválida. Por favor, escolha entre 1 ou 2. ####"
        exit 0
        ;;
esac



#Cria o script de Locust
#
echo 'from locust import HttpUser, TaskSet, task, between
import time

class WebsiteTasks(TaskSet):
    def on_start(self):
        # certificado autoassinado
        self.client.verify = False

    @task
    def test_pages(self):
        # Seis URLs a serem acessadas
        pages = [
            "/",
            "/?p=152",
            "/?p=151",
            "/?p=136",
            "/?p=132",
            "/?p=128"
        ]
        
        # Itera sobre cada página
        for page in pages:
            # Realiza o GET para a página atual
            self.client.get(page, name=f"Access {page}")
            # Aguarda em segundos antes de acessar a próxima página
            time.sleep(5)

class WebsiteUser(HttpUser):
    tasks = [WebsiteTasks]
    # Tempo de espera entre as tarefas (mantém o intervalo de 1 a 2 segundos)
    wait_time = between(1, 2)' > carga.py
