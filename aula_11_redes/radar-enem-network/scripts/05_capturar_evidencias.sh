#!/usr/bin/env bash
# Captura TODAS as evidencias em arquivos .txt dentro de evidencias/.
# Use quando quiser salvar as saidas em texto (alem dos prints de tela).
set -uo pipefail
cd "$(dirname "$0")/.."
OUT="evidencias"
mkdir -p "$OUT"

echo ">>> Gerando $OUT/evidencia1_inspecao_rede.txt"
bash scripts/02_evidencia1_inspecao_rede.sh > "$OUT/evidencia1_inspecao_rede.txt" 2>&1

echo ">>> Gerando $OUT/evidencia2_isolamento.txt"
bash scripts/03_evidencia2_isolamento.sh > "$OUT/evidencia2_isolamento.txt" 2>&1

echo ">>> Gerando $OUT/evidencia3_desafios.txt"
bash scripts/04_evidencia3_desafios.sh > "$OUT/evidencia3_desafios.txt" 2>&1

echo
echo "Pronto. Arquivos gerados em: $OUT/"
ls -la "$OUT"
