from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({
        "projeto": "Radar ENEM",
        "disciplina": "Computacao em Nuvem",
        "status": "online"
    })

@app.route("/health")
def health():
    return jsonify({"status": "healthy"})

@app.route("/aluno/<nome>")
def aluno(nome):
    ambiente = os.getenv("AMBIENTE", "desenvolvimento")
    return jsonify({
        "aluno": nome,
        "ambiente": ambiente,
        "mensagem": "Bem-vindo ao Mini Radar ENEM"
    })

@app.route("/nota/<int:nota>")
def consultar_nota(nota):
    if nota >= 600:
        classificacao = "acima de 600"
    else:
        classificacao = "abaixo de 600"
    return jsonify({
        "nota": nota,
        "classificacao": classificacao
    })

@app.route("/status")
def status():
    ambiente = os.getenv("AMBIENTE", "desenvolvimento")
    regiao = os.getenv("REGIAO", "Brasil")

    return jsonify({
        "projeto": "Radar ENEM",
        "versao": "v2",
        "status": "funcionando",
        "ambiente": ambiente,
        "regiao": regiao
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)