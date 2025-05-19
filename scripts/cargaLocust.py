from locust import HttpUser, TaskSet, task, between
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
    wait_time = between(1, 2)
