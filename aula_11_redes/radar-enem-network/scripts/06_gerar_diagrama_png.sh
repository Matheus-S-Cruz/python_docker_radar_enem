#!/usr/bin/env bash
# Converte o diagrama da VPC (SVG) em PNG -> evidencias/04_diagrama_vpc.png
# Tenta, em ordem: rsvg-convert, inkscape, ImageMagick (convert), Chrome/Chromium headless.
set -uo pipefail
cd "$(dirname "$0")/.."
SVG="evidencias/diagrama_vpc.svg"
PNG="evidencias/04_diagrama_vpc.png"

if [ ! -f "$SVG" ]; then
  echo "ERRO: nao encontrei $SVG"; exit 1
fi

try() { command -v "$1" >/dev/null 2>&1; }

if try rsvg-convert; then
  rsvg-convert -w 1920 "$SVG" -o "$PNG" && echo "Gerado com rsvg-convert: $PNG" && exit 0
fi
if try inkscape; then
  inkscape "$SVG" --export-type=png --export-filename="$PNG" -w 1920 && echo "Gerado com inkscape: $PNG" && exit 0
fi
if try convert; then
  convert -density 150 -background white "$SVG" "$PNG" && echo "Gerado com ImageMagick: $PNG" && exit 0
fi
for BR in google-chrome chromium chromium-browser; do
  if try "$BR"; then
    "$BR" --headless --disable-gpu --screenshot="$PNG" --window-size=1920,1520 "$SVG" \
      && echo "Gerado com $BR: $PNG" && exit 0
  fi
done

echo "Nenhum conversor encontrado. Alternativas:"
echo "  1) Instale um: sudo apt-get update && sudo apt-get install -y librsvg2-bin"
echo "     depois rode novamente este script."
echo "  2) Abra evidencias/diagrama_vpc.svg no navegador e salve como PNG."
echo "  3) Abra evidencias/diagrama_vpc.mmd em https://mermaid.live e exporte PNG."
exit 1
