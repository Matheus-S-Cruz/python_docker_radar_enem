from flask import Flask, jsonify
import os

app = Flask(__name__)

AMBIENTE = os.getenv("AMBIENTE", "desenvolvimento")
REGIAO = os.getenv("REGIAO", "Brasil")
VERSAO = os.getenv("VERSAO", "v2")

@app.route("/")
def home():
    return jsonify({
        "projeto": "Radar ENEM",
        "disciplina": "Computacao em Nuvem",
        "status": "online",
        "ambiente": AMBIENTE,
        "versao": VERSAO
    })

@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "servico": "radar-enem",
        "versao": VERSAO
    }), 200

@app.route("/status")
def status():
    return jsonify({
        "projeto": "Radar ENEM",
        "versao": VERSAO,
        "status": "funcionando",
        "ambiente": AMBIENTE,
        "regiao": REGIAO
    })

@app.route("/aluno/<nome>")
def aluno(nome):
    return jsonify({
        "aluno": nome,
        "ambiente": AMBIENTE,
        "mensagem": f"Bem-vindo {nome} ao Mini Radar ENEM"
    })

@app.route("/nota/<int:nota>")
def consultar_nota(nota):
    classificacao = "acima de 600" if nota >= 600 else "abaixo de 600"
    return jsonify({
        "nota": nota,
        "classificacao": classificacao
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
