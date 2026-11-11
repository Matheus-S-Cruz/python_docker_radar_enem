-- Aula 9 — Passo 6: inserir dados de teste (FICTÍCIOS)

INSERT INTO provas (ano, nome) VALUES
  (2025, 'ENEM regular'),
  (2024, 'ENEM regular');

INSERT INTO questoes
  (prova_id, assunto, enunciado, dificuldade)
VALUES
  (1, 'Ecologia',
   'Questão demonstrativa sobre ecossistemas', 'média'),
  (1, 'Matemática',
   'Questão demonstrativa sobre funções', 'alta'),
  (2, 'Ecologia',
   'Questão demonstrativa sobre cadeias alimentares', 'baixa');