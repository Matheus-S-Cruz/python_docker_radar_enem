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

O diagrama representa a arquitetura utilizada na atividade, com acesso pela porta 5000, health check, logs e monitoramento de recursos.