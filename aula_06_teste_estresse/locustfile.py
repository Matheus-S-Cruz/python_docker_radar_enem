from locust import HttpUser, between, task


class AlunoRadarEnem(HttpUser):
    wait_time = between(1, 3)

    @task
    def calcular_nota(self):
        payload = {"notas": [720.5, 680.0, 810.2, 640.8, 780.0]}
        with self.client.post(
            "/api/CalculaNota", json=payload, name="POST /api/CalculaNota", catch_response=True
        ) as resposta:
            if resposta.status_code != 200:
                resposta.failure(f"HTTP {resposta.status_code}")
            elif "nota_corte_calculada" not in resposta.json():
                resposta.failure("Resposta sem nota calculada")

