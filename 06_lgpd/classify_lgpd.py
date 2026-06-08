"""
06 - LGPD: Classify existing SQL Server columns with LGPD base legal.
Connects to source (SQL Server), analyzes columns, generates:
  1. CSV report with LGPD classification
  2. INSERT statements for lgpd_base_legal table (MySQL target)
  3. INSERT statements for lgpd_retencao table (MySQL target)
"""
import sys
import csv
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from utils.db_connection import get_connection


# LGPD classification rules based on column name patterns
LGPD_RULES = {
    # Pattern: (base_legal, finalidade, retencao_dias, tipo_pessoal)
    'cpf': (
        'OBRIGACAO_LEGAL',
        'Identificacao do funcionario para obrigacoes trabalhistas (eSocial, RAIS, CAGED)',
        3650,  # 10 anos apos desligamento (CLT Art. 11)
        'PII'
    ),
    'cnpj': (
        'OBRIGACAO_LEGAL',
        'Identificacao de pessoa juridica para obrigacoes fiscais',
        3650,
        None
    ),
    'rg': (
        'OBRIGACAO_LEGAL',
        'Identificacao para registros trabalhistas',
        3650,
        'PII'
    ),
    'pis': (
        'OBRIGACAO_LEGAL',
        'Cadastro PIS/PASEP para obrigacoes trabalhistas',
        3650,
        'PII'
    ),
    'ctps': (
        'OBRIGACAO_LEGAL',
        'Registro em carteira de trabalho - obrigacao legal',
        3650,
        'PII'
    ),
    'nome': (
        'EXECUCAO_CONTRATO',
        'Identificacao do funcionario no contrato de trabalho',
        3650,
        'PII'
    ),
    'email': (
        'EXECUCAO_CONTRATO',
        'Comunicacao necessaria para execucao do contrato',
        365,  # 1 ano apos desligamento
        'PII'
    ),
    'telefone': (
        'EXECUCAO_CONTRATO',
        'Contato para comunicacoes do contrato de trabalho',
        365,
        'PII'
    ),
    'fone': (
        'EXECUCAO_CONTRATO',
        'Contato para comunicacoes do contrato de trabalho',
        365,
        'PII'
    ),
    'celular': (
        'EXECUCAO_CONTRATO',
        'Contato para comunicacoes do contrato de trabalho',
        365,
        'PII'
    ),
    'endereco': (
        'EXECUCAO_CONTRATO',
        'Endereco para correspondencia e vale-transporte',
        365,
        'PII'
    ),
    'logradouro': (
        'EXECUCAO_CONTRATO',
        'Endereco para correspondencia e vale-transporte',
        365,
        'PII'
    ),
    'cep': (
        'EXECUCAO_CONTRATO',
        'Endereco para correspondencia e vale-transporte',
        365,
        'PII'
    ),
    'salario': (
        'EXECUCAO_CONTRATO',
        'Remuneracao conforme contrato de trabalho',
        3650,
        'FINANCEIRO'
    ),
    'remuneracao': (
        'EXECUCAO_CONTRATO',
        'Remuneracao conforme contrato de trabalho',
        3650,
        'FINANCEIRO'
    ),
    'vencimento': (
        'EXECUCAO_CONTRATO',
        'Remuneracao conforme contrato de trabalho',
        3650,
        'FINANCEIRO'
    ),
    'banco': (
        'EXECUCAO_CONTRATO',
        'Dados bancarios para deposito de salario',
        365,
        'FINANCEIRO'
    ),
    'agencia': (
        'EXECUCAO_CONTRATO',
        'Dados bancarios para deposito de salario',
        365,
        'FINANCEIRO'
    ),
    'conta_corrente': (
        'EXECUCAO_CONTRATO',
        'Dados bancarios para deposito de salario',
        365,
        'FINANCEIRO'
    ),
    'conta': (
        'EXECUCAO_CONTRATO',
        'Dados bancarios para deposito de salario',
        365,
        'FINANCEIRO'
    ),
    'nascimento': (
        'OBRIGACAO_LEGAL',
        'Data de nascimento para registros trabalhistas',
        3650,
        'PII'
    ),
    'nasc': (
        'OBRIGACAO_LEGAL',
        'Data de nascimento para registros trabalhistas',
        3650,
        'PII'
    ),
    'senha': (
        'INTERESSE_LEGITIMO',
        'Autenticacao de acesso ao sistema',
        0,  # Rotacionar, nao reter
        'CREDENCIAL'
    ),
    'password': (
        'INTERESSE_LEGITIMO',
        'Autenticacao de acesso ao sistema',
        0,
        'CREDENCIAL'
    ),
    'saude': (
        'TUTELA_SAUDE',
        'Dados de saude ocupacional - NR-7, PCMSO',
        7300,  # 20 anos (NR-7)
        'SENSIVEL_LGPD'
    ),
    'cid': (
        'TUTELA_SAUDE',
        'Codigo CID para atestados e afastamentos',
        7300,
        'SENSIVEL_LGPD'
    ),
    'atestado': (
        'TUTELA_SAUDE',
        'Atestados medicos para abono de faltas',
        7300,
        'SENSIVEL_LGPD'
    ),
    'biometri': (
        'CONSENTIMENTO',
        'Biometria para controle de ponto (requer consentimento)',
        365,
        'SENSIVEL_LGPD'
    ),
}

# Retention policy per schema (used for lgpd_retencao)
SCHEMA_RETENTION = {
    'Funcionario': ('data_admissao', 3650, 'ANONIMIZAR'),
    'Contratacao': ('data_contratacao', 1825, 'ANONIMIZAR'),
    'Beneficio': ('data_inicio', 1825, 'EXCLUIR'),
    'SaudeSegurancaTrabalho': ('data_registro', 7300, 'ANONIMIZAR'),
    'Faturamento': ('data_faturamento', 3650, 'ARQUIVAR'),
    'Estoque': ('data_movimentacao', 1825, 'ARQUIVAR'),
}


def classify_column(col_name):
    """Match column name to LGPD rule."""
    col_lower = col_name.lower()
    for pattern, rule in LGPD_RULES.items():
        if pattern in col_lower:
            return rule
    return None


def main():
    conn = get_connection('sqlserver')
    cursor = conn.cursor()
    timestamp = datetime.now().strftime('%Y%m%d_%H%M')

    print("=" * 70)
    print("  LGPD DATA CLASSIFICATION - Source: SQL Server (neeo_ntl)")
    print("=" * 70)

    # Get all columns
    cursor.execute("""
        SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE
        FROM INFORMATION_SCHEMA.COLUMNS
        ORDER BY TABLE_SCHEMA, TABLE_NAME, ORDINAL_POSITION
    """)
    all_columns = cursor.fetchall()

    classified = []
    unclassified_personal = []

    for schema, table, column, dtype in all_columns:
        rule = classify_column(column)
        if rule:
            base_legal, finalidade, retencao, tipo = rule
            classified.append({
                'schema': schema,
                'tabela': table,
                'coluna': column,
                'tipo_dado': dtype,
                'base_legal': base_legal,
                'finalidade': finalidade,
                'retencao_dias': retencao,
                'tipo_pessoal': tipo or '',
                'responsavel': f'Gestor {schema}',
            })

    # Report
    print(f"\n  Total columns scanned:  {len(all_columns)}")
    print(f"  Classified (LGPD):      {len(classified)}")

    by_base = {}
    for c in classified:
        by_base.setdefault(c['base_legal'], 0)
        by_base[c['base_legal']] += 1
    print("\n  By base legal:")
    for base, count in sorted(by_base.items()):
        print(f"    {base}: {count} columns")

    by_tipo = {}
    for c in classified:
        if c['tipo_pessoal']:
            by_tipo.setdefault(c['tipo_pessoal'], 0)
            by_tipo[c['tipo_pessoal']] += 1
    print("\n  By data type:")
    for tipo, count in sorted(by_tipo.items()):
        print(f"    {tipo}: {count} columns")

    # Export CSV
    csv_file = f'lgpd_classificacao_{timestamp}.csv'
    with open(csv_file, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=classified[0].keys(), delimiter=';')
        writer.writeheader()
        writer.writerows(classified)
    print(f"\n  CSV report: {csv_file}")

    # Generate MySQL INSERT statements
    sql_file = f'lgpd_inserts_mysql_{timestamp}.sql'
    with open(sql_file, 'w', encoding='utf-8') as f:
        f.write('-- LGPD Base Legal - Generated from SQL Server analysis\n')
        f.write(f'-- Date: {datetime.now().strftime("%Y-%m-%d %H:%M")}\n')
        f.write('-- Target: MySQL neeo_ntl_iso\n\n')
        f.write('USE neeo_ntl_iso;\n\n')

        # lgpd_base_legal inserts
        f.write('-- ========== lgpd_base_legal ==========\n\n')
        seen = set()
        for c in classified:
            key = (c['tabela'], c['coluna'])
            if key in seen:
                continue
            seen.add(key)

            finalidade_escaped = c['finalidade'].replace("'", "\\'")
            f.write(
                f"INSERT INTO lgpd_base_legal "
                f"(tabela_nome, coluna_nome, base_legal, finalidade, "
                f"periodo_retencao_dias, responsavel) VALUES\n"
                f"('{c['tabela']}', '{c['coluna']}', '{c['base_legal']}', "
                f"'{finalidade_escaped}', {c['retencao_dias']}, "
                f"'{c['responsavel']}');\n\n"
            )

        # lgpd_retencao inserts
        f.write('\n-- ========== lgpd_retencao ==========\n\n')
        for schema, (col_data, dias, acao) in SCHEMA_RETENTION.items():
            f.write(
                f"INSERT INTO lgpd_retencao "
                f"(tabela_nome, coluna_data_referencia, periodo_dias, "
                f"acao_pos_retencao, ativo) VALUES\n"
                f"('{schema}', '{col_data}', {dias}, '{acao}', 1);\n\n"
            )

        # classificacao_dados inserts
        f.write('\n-- ========== classificacao_dados ==========\n\n')
        seen_class = set()
        for c in classified:
            key = (c['tabela'], c['coluna'])
            if key in seen_class:
                continue
            seen_class.add(key)

            # Map to classification level
            if c['tipo_pessoal'] in ('SENSIVEL_LGPD', 'CREDENCIAL'):
                classificacao = 'CRITICO'
            elif c['tipo_pessoal'] == 'FINANCEIRO':
                classificacao = 'CONFIDENCIAL'
            elif c['tipo_pessoal'] == 'PII':
                classificacao = 'RESTRITO'
            else:
                classificacao = 'INTERNO'

            f.write(
                f"INSERT INTO classificacao_dados "
                f"(tabela_nome, coluna_nome, classificacao, tipo_dado_pessoal, "
                f"base_legal_lgpd, responsavel, periodo_retencao_dias) VALUES\n"
                f"('{c['tabela']}', '{c['coluna']}', '{classificacao}', "
                f"'{c['tipo_pessoal']}', '{c['base_legal']}', "
                f"'{c['responsavel']}', {c['retencao_dias']});\n\n"
            )

    print(f"  MySQL inserts: {sql_file}")

    # Summary of LGPD sensitive data (Art. 5, II)
    sensitive = [c for c in classified if c['tipo_pessoal'] == 'SENSIVEL_LGPD']
    if sensitive:
        print(f"\n  !! ATENCAO: {len(sensitive)} colunas com dados sensiveis LGPD (Art. 5, II):")
        for s in sensitive:
            print(f"     {s['schema']}.{s['tabela']}.{s['coluna']} ({s['base_legal']})")

    print(f"\n  Files generated. Review and load into MySQL target.")
    conn.close()


if __name__ == '__main__':
    main()
