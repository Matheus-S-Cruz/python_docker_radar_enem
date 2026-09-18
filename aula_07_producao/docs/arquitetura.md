# Arquitetura — Aula 07

```text
                  USUÁRIO
                     |
                     v
                Porta 5000
                     |
                     v
             +---------------+
             |   Radar ENEM  |
             |     Flask     |
             +---------------+
                |    |    |
                |    |    +----> Logs
                |    |
                |    +---------> Health Check (/health)
                |
                +-------------> Monitoramento
                                CPU / Memória
```

Este diagrama talvez seja substituido depois por algo mais elaborado para a entrega
