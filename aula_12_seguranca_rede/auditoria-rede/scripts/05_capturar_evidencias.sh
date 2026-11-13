#!/usr/bin/env bash
# PASSO 5 - Captura todas as saidas em .txt (para anexar junto dos prints).
# Gera arquivos em evidencias/ (ignorados pelo Git via .gitignore).
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

OUT="evidencias"
mkdir -p "$OUT"

echo "[1/4] Subindo e capturando cenario INSEGURO..."
bash scripts/01_subir_inseguro.sh > "$OUT/01_cenario_inseguro.txt" 2>&1

echo "[2/4] Capturando auditoria de portas..."
bash scripts/02_auditar_portas.sh > "$OUT/02_portas_expostas.txt" 2>&1

echo "[3/4] Subindo e capturando cenario SEGURO..."
bash scripts/03_subir_seguro.sh > "$OUT/03_cenario_seguro.txt" 2>&1

echo "[4/4] Capturando validacao de isolamento..."
sleep 3
bash scripts/04_validar_isolamento.sh > "$OUT/04_isolamento_validado.txt" 2>&1

echo
echo "===== Arquivos .txt gerados em $OUT/ ====="
ls -1 "$OUT"/*.txt
echo ">>> Tire os prints correspondentes rodando cada script manualmente (ver README, secao 5)."
