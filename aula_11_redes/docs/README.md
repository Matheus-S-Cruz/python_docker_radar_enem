# docs — Entrega da Aula 11

Pasta com o **entregável final** para submissão no AVA.

## Arquivos

| Arquivo | Descrição |
|---|---|
| `Entrega_Aula11_Redes_Docker.pdf` | **PDF final para enviar no AVA** (15 páginas). Capa + sumário + 4 evidências + relatório técnico, na ordem exigida pelo guia. |
| `entrega_aula11.html` | Template HTML usado para gerar o PDF (capa, legendas e layout). As imagens são referenciadas de `../radar-enem-network/evidencias/`. |

## Conteúdo do PDF (ordem dos entregáveis do AVA)

1. **Capa** + sumário dos entregáveis e arquitetura validada.
2. **Evidência 1 — Inspeção de rede:** `inspecao_rede_1.png` + `inspecao_rede_2.png`
   (CIDR `172.20.20.0/24`, `"Internal": true`, IPs de `radar-backend` e `radar-db`).
3. **Evidência 2 — Isolamento (Passo 5):** `evidencia_isolamento.png`
   (proxy 200 OK; `radar-proxy → radar-db` falha; `radar-backend → radar-db` conecta).
4. **Evidência 3 — Os 4 desafios (Passo 6):** `evidencia_desafios.png`,
   `evidencia_desafios_2.png`, `evidencia_desafios_3.png`, `evidencia_desafios_4.png`.
5. **Evidência 4 — Diagrama da VPC:** `04_diagrama_vpc.png` (VPC `10.20.0.0/16`).
6. **Relatório técnico:** conteúdo de `../RELATORIO.md` (desafios, Incremento 4 e questões discursivas).

## Como regenerar o PDF

O PDF foi gerado a partir do `RELATORIO.md` (convertido para HTML com `marked`) e das
capturas em `../radar-enem-network/evidencias/`, renderizado para PDF com o Chromium do
Playwright (formato A4, `printBackground`). Para refazer após atualizar evidências ou o
relatório, basta reexecutar esse fluxo (markdown → HTML → `page.pdf`).
