from locust import HttpUser, TaskSet, task, between
from random import choice
import time

class WebsiteTasks(TaskSet):

    PRODUCTS_IDS = [
        "OLJCESPC7Z",
        "L9ECAV7KIM",
        "66VCHSJNUP",
        "1YMWWN1N4O",
        "LS4PSXUNUM",
    ]

    def on_start(self):
        self.client.verify = False  # certificado autoassinado

    @task
    def test_pages(self):
        pages = [
            "/",
            "/product/*",
            "/cart",
             #"cart/checkout",
        ]
        for page in pages:
            if page == "/product/*":
                product_id = choice(self.PRODUCTS_IDS)
                page = page.replace("*", product_id)
            try:
                self.client.get(page, name=f"Access GET {page}")
            except Exception as e:
                print(f"Error accessing {page}: {e}")
            time.sleep(5)

class WebsiteUser(HttpUser):
    tasks = [WebsiteTasks]
    wait_time = between(1, 2)
