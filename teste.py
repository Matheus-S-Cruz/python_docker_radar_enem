preco_hora = float(input("Preço por hora: R$ "))
horas_dia = float(input("Horas de uso por dia: "))
dias_mes = int(input("Dias de uso no mês: "))
custo = preco_hora * horas_dia * dias_mes
print(f"Custo mensal: R$ {custo:.2f}")