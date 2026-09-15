import time
from typing import List

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field


class Notas(BaseModel):
    notas: List[float] = Field(min_length=1, max_length=5)
    atraso: float = Field(default=0.05, ge=0, le=10)


app = FastAPI(title="Calculadora Radar ENEM", version="1.0.0")


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/api/CalculaNota")
def calcular(payload: Notas):
    if any(nota < 0 or nota > 1000 for nota in payload.notas):
        raise HTTPException(status_code=400, detail="Cada nota deve estar entre 0 e 1000.")

    time.sleep(payload.atraso)
    nota_corte = sum(payload.notas) / len(payload.notas)
    return {"nota_corte_calculada": round(nota_corte, 2)}

