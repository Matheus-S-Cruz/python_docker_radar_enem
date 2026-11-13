# Evidências — Aula 12 (Auditoria de Segurança de Rede)

Salve aqui os prints de tela (`.png`) e/ou os `.txt` gerados pelo laboratório.
Entregáveis que comprovam a auditoria e o checklist do AVA:

| # | Arquivo sugerido | Conteúdo (o que o print deve mostrar) | Como capturar | Status |
|---|------------------|---------------------------------------|---------------|--------|
| 1 | `01_cenario_inseguro.png` | `docker compose ps` do stack vulnerável com `8080`, `8081`, `5432` e `6379` todos mapeados no host. | `bash scripts/01_subir_inseguro.sh` | ⬜ |
| 2 | `02_portas_expostas.png` | Varredura (`nmap`/`nc`) mostrando `5432` e `6379` **abertas** no host = exposição R-03/R-04. | `bash scripts/02_auditar_portas.sh` | ⬜ |
| 3 | `03_cenario_seguro.png` | `docker compose ps` do stack refatorado: **só o proxy** publica porta; `db`/`cache` sem portas. | `bash scripts/03_subir_seguro.sh` | ⬜ |
| 4 | `04_isolamento_validado.png` | Proxy OK em `localhost:8080`; `5432`/`6379` **fechadas** no host; backend ainda alcança `db`/`cache` pela rede interna. | `bash scripts/04_validar_isolamento.sh` | ⬜ |
| 5 | `05_diagrama_segmentacao.png` (opcional) | Diagrama da VPC alvo: 3 sub-redes (pública / privada / privada isolada), 3 Security Groups e setas do tráfego autorizado. | draw.io / Excalidraw / PowerPoint | ⬜ opcional |

> **Dica:** rode `bash scripts/05_capturar_evidencias.sh` para gerar as versões em `.txt`
> (`01_cenario_inseguro.txt`, `02_portas_expostas.txt`, `03_cenario_seguro.txt`,
> `04_isolamento_validado.txt`) e anexá-las junto dos prints. Os `.txt` são ignorados pelo Git;
> os `.png` devem ser versionados.

## Checklist do roteiro (resumo)

1. Suba o cenário inseguro → **print 1**.
2. Audite as portas → **print 2** (mostra o risco).
3. Suba o cenário seguro → **print 3**.
4. Valide o isolamento → **print 4** (mostra a correção).
5. (Opcional) Desenhe o diagrama → **print 5**.
6. Monte o PDF final na ordem acima + `RELATORIO.md`.
