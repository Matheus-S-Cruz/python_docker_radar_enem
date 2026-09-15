import os

import requests
from flask import Flask, jsonify, render_template, request


app = Flask(__name__)
CALCULADORA_URL = os.getenv(
    "CALCULADORA_URL", "http://localhost:8000/api/CalculaNota"
)


@app.get("/")
def index():
    return render_template("index.html")


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/exibir_nota")
def exibir_nota():
    dados_aluno = request.get_json(silent=True) or {}
    notas = dados_aluno.get("notas")

    if not isinstance(notas, list) or not notas:
        return jsonify({"erro": "Informe ao menos uma nota."}), 400

    payload = {"notas": notas}
    if "atraso" in dados_aluno:
        payload["atraso"] = dados_aluno["atraso"]

    try:
        resposta = requests.post(CALCULADORA_URL, json=payload, timeout=2.0)
        resposta.raise_for_status()
        resultado = resposta.json()
        return jsonify(
            {"mensagem": f"Sua nota de corte é: {resultado['nota_corte_calculada']}"}
        )
    except requests.exceptions.Timeout:
        return jsonify({
            "erro": "A calculadora está com alta demanda neste momento. Tente novamente em instantes."
        }), 503
    except requests.exceptions.ConnectionError:
        return jsonify({
            "erro": "Calculadora temporariamente indisponível. As outras áreas do site continuam funcionando."
        }), 503
    except requests.exceptions.HTTPError as erro:
        detalhe = "A calculadora rejeitou os dados informados."
        try:
            detalhe = erro.response.json().get("detail", detalhe)
        except ValueError:
            pass
        return jsonify({"erro": detalhe}), erro.response.status_code
    except (ValueError, KeyError):
        return jsonify({"erro": "A calculadora retornou uma resposta inválida."}), 502


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

