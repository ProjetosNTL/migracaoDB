import pyodbc
import csv
from datetime import datetime
from dotenv import load_dotenv
import os
load_dotenv()  # Carrega variáveis de ambiente do arquivo .env

conn = pyodbc.connect(
    f"DRIVER={{SQL Server}};"
    f"SERVER={os.getenv('DB_SERVER')};DATABASE={os.getenv('DB_NAME')};"
    f"UID={os.getenv('DB_USER')};PWD={os.getenv('DB_PASSWORD')}"
)
cursor = conn.cursor()

# Patterns that indicate sensitive data
SENSITIVE_PATTERNS = [
    '%cpf%', '%cnpj%', '%rg%', '%pis%', '%ctps%',
    '%senha%', '%password%', '%hash%',
    '%email%', '%mail%',
    '%telefone%', '%fone%', '%celular%',
    '%endereco%', '%cep%', '%logradouro%',
    '%salario%', '%remuneracao%', '%vencimento%',
    '%banco%', '%agencia%', '%conta_corrente%',
    '%nasc%', '%nascimento%',
    '%saude%', '%cid%', '%atestado%',
]

# Find all sensitive columns
query = """
SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE """ + " OR ".join([f"COLUMN_NAME LIKE '{p}'" for p in SENSITIVE_PATTERNS]) + """
ORDER BY TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME
"""

cursor.execute(query)
results = cursor.fetchall()

# Generate report
report = []
for row in results:
    schema, table, column, dtype = row
    
    # Check if column has data
    cursor.execute(f"SELECT COUNT(*) FROM [{schema}].[{table}] WHERE [{column}] IS NOT NULL")
    count = cursor.fetchone()[0]
    
    # Classify sensitivity
    col_lower = column.lower()
    if any(x in col_lower for x in ['senha', 'password']):
        classification = 'CRITICO'
        action = 'Hash com bcrypt + Dynamic Data Masking'
    elif any(x in col_lower for x in ['cpf', 'rg', 'pis', 'ctps']):
        classification = 'CRITICO'
        action = 'Dynamic Data Masking partial(3,***,2)'
    elif any(x in col_lower for x in ['salario', 'remuneracao', 'banco', 'conta']):
        classification = 'CONFIDENCIAL'
        action = 'Dynamic Data Masking default()'
    elif any(x in col_lower for x in ['email', 'telefone', 'fone', 'celular']):
        classification = 'RESTRITO'
        action = 'Dynamic Data Masking email()/partial()'
    elif any(x in col_lower for x in ['saude', 'cid', 'atestado']):
        classification = 'CRITICO - LGPD SENSIVEL'
        action = 'Criptografia + Acesso restrito'
    else:
        classification = 'INTERNO'
        action = 'Avaliar necessidade'
    
    report.append({
        'schema': schema,
        'tabela': table,
        'coluna': column,
        'tipo': dtype,
        'registros': count,
        'classificacao': classification,
        'acao_recomendada': action
    })

# Export CSV
filename = f'inventario_dados_sensiveis_{datetime.now():%Y%m%d}.csv'
with open(filename, 'w', newline='', encoding='utf-8-sig') as f:
    writer = csv.DictWriter(f, fieldnames=report[0].keys(), delimiter=';')
    writer.writeheader()
    writer.writerows(report)

print(f"Relatório gerado: {filename}")
print(f"Total colunas sensíveis encontradas: {len(report)}")

# Smart masking function based on column name and data type
def get_mask_function(col_name, data_type):
    col = col_name.lower()

    # Passwords — full mask
    if any(x in col for x in ['senha', 'password', 'hash']):
        return "default()"

    # CPF — show first 3 + last 2: 123.***.***-01
    if 'cpf' in col:
        return "partial(3,\".***.***-\",2)"

    # CNPJ — show first 2 + last 2: 12.***.***/****-01
    if 'cnpj' in col:
        return "partial(2,\".***.***/*****-\",2)"

    # RG/PIS/CTPS — partial mask
    if any(x in col for x in ['rg', 'pis', 'ctps']):
        return "partial(2,\"*****\",1)"

    # Email — built-in email mask: fXXX@XXXX.com
    if any(x in col for x in ['email', 'mail']):
        return "email()"

    # Phone — show area code: (11)****-****
    if any(x in col for x in ['telefone', 'fone', 'celular']):
        return "partial(4,\"****-\",0)"

    # Address — show first 5 chars
    if any(x in col for x in ['endereco', 'logradouro']):
        return "partial(5,\"XXXXX\",0)"

    # CEP — show first 5: 01310-***
    if 'cep' in col:
        return "partial(5,\"-***\",0)"

    # Salary/financial — zero out (numeric) or mask (string)
    if any(x in col for x in ['salario', 'remuneracao', 'vencimento']):
        if data_type in ('money', 'decimal', 'numeric', 'float', 'int', 'bigint', 'smallint'):
            return "default()"  # shows 0
        return "default()"

    # Bank info — full mask
    if any(x in col for x in ['banco', 'agencia', 'conta_corrente', 'conta']):
        return "default()"

    # Birth date — full mask
    if any(x in col for x in ['nasc', 'nascimento']):
        return "default()"  # shows 1900-01-01

    # Health data (LGPD sensitive) — full mask
    if any(x in col for x in ['saude', 'cid', 'atestado']):
        return "default()"

    return "default()"

# Generate masking SQL script
with open('script_masking.sql', 'w', encoding='utf-8') as f:
    f.write('-- Script de Dynamic Data Masking - ISO 27001 / LGPD\n')
    f.write('-- Gerado automaticamente em ' + datetime.now().strftime('%Y-%m-%d %H:%M') + '\n')
    f.write('-- REVISAR ANTES DE EXECUTAR: remover falsos positivos\n\n')

    current_schema = ''
    for r in report:
        if r['classificacao'] != 'INTERNO':
            # Section header per schema
            if r['schema'] != current_schema:
                current_schema = r['schema']
                f.write(f'\n-- ========== Schema: {current_schema} ==========\n\n')

            mask_fn = get_mask_function(r['coluna'], r['tipo'])
            f.write(f"-- [{r['classificacao']}] {r['coluna']} ({r['tipo']}) - {r['registros']} registros\n")
            f.write(f"ALTER TABLE [{r['schema']}].[{r['tabela']}]\n")
            f.write(f"ALTER COLUMN [{r['coluna']}] ADD MASKED WITH (FUNCTION = '{mask_fn}');\n\n")

print("Script SQL gerado: script_masking.sql")
conn.close()