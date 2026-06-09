"""
Extract personal data fields from SQL Server for LDAP schema modeling.
Generates SPLIT files by category - one file per data type.
"""
import sys
import os
from datetime import datetime
from pathlib import Path
from collections import defaultdict

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from utils.db_connection import get_connection

# Patterns that indicate personal/employee data
PERSONAL_PATTERNS = [
    '%nome%', '%name%',
    '%cpf%', '%cnpj%', '%rg%', '%pis%', '%ctps%', '%cnh%',
    '%matricula%', '%registro%',
    '%email%', '%mail%',
    '%telefone%', '%fone%', '%celular%', '%ddd%',
    '%endereco%', '%logradouro%', '%bairro%', '%cidade%', '%uf%',
    '%cep%', '%municipio%', '%estado%', '%numero%', '%complemento%',
    '%nasc%', '%nascimento%', '%admiss%', '%contrat%', '%demiss%',
    '%ferias%', '%folga%',
    '%cargo%', '%funcao%', '%departamento%', '%setor%', '%lotacao%',
    '%salario%', '%remuneracao%', '%vencimento%',
    '%jornada%', '%horario%', '%turno%',
    '%cliente%', '%alocacao%',
    '%banco%', '%agencia%', '%conta%', '%pix%',
    '%pai%', '%mae%', '%conjuge%', '%dependente%', '%filho%',
    '%saude%', '%cid%', '%atestado%', '%exame%', '%aso%',
    '%senha%', '%password%', '%login%', '%usuario%',
    '%foto%', '%imagem%', '%avatar%',
    '%sexo%', '%genero%', '%estado_civil%', '%nacionalidade%',
    '%escolaridade%', '%formacao%', '%raca%', '%cor%', '%deficien%',
]

# Categories with their patterns and LDAP destination
CATEGORIES = {
    '01_identificacao_pessoal': {
        'titulo': 'IDENTIFICACAO PESSOAL',
        'destino_ldap': 'SIM - Centralizar no LDAP',
        'patterns': ['nome', 'name', 'cpf', 'rg', 'cnh', 'matricula',
                     'registro', 'sexo', 'genero', 'estado_civil',
                     'nacionalidade', 'raca', 'cor', 'foto', 'imagem',
                     'avatar', 'escolaridade', 'formacao', 'deficien'],
        'ldap_attrs': {
            'nome/nomeCompleto': 'cn / displayName',
            'nome (primeiro)': 'givenName',
            'nome (sobrenome)': 'sn (surname)',
            'cpf': 'employeeNumber',
            'rg': 'custom: rgNumber',
            'cnh': 'custom: cnhNumber',
            'matricula': 'employeeNumber',
            'foto': 'jpegPhoto',
            'sexo/genero': 'custom: gender',
            'nacionalidade': 'custom: nationality',
            'escolaridade': 'custom: educationLevel',
        }
    },
    '02_contato': {
        'titulo': 'DADOS DE CONTATO',
        'destino_ldap': 'SIM - Centralizar no LDAP',
        'patterns': ['email', 'mail', 'telefone', 'fone', 'celular', 'ddd'],
        'ldap_attrs': {
            'email': 'mail',
            'email corporativo': 'mail (primary)',
            'email pessoal': 'custom: personalEmail',
            'telefone': 'telephoneNumber',
            'celular': 'mobile',
        }
    },
    '03_endereco': {
        'titulo': 'ENDERECO',
        'destino_ldap': 'SIM - Centralizar no LDAP',
        'patterns': ['endereco', 'logradouro', 'bairro', 'cidade', 'uf', 'cep',
                     'municipio', 'estado', 'numero', 'complemento'],
        'ldap_attrs': {
            'endereco completo': 'postalAddress',
            'cep': 'postalCode',
            'cidade': 'l (locality)',
            'uf/estado': 'st (state)',
        }
    },
    '04_dados_profissionais': {
        'titulo': 'DADOS PROFISSIONAIS',
        'destino_ldap': 'SIM - Centralizar no LDAP',
        'patterns': ['cargo', 'funcao', 'departamento', 'setor', 'lotacao',
                     'jornada', 'horario', 'turno', 'cliente', 'alocacao'],
        'ldap_attrs': {
            'cargo': 'title',
            'departamento': 'departmentNumber / ou',
            'funcao': 'custom: jobFunction',
            'setor': 'custom: sector',
            'clienteAlocacao': 'custom: clientAllocation',
        }
    },
    '05_datas': {
        'titulo': 'DATAS IMPORTANTES',
        'destino_ldap': 'PARCIAL - nascimento e contratacao no LDAP',
        'patterns': ['nasc', 'nascimento', 'admiss', 'contrat', 'demiss',
                     'ferias', 'folga'],
        'ldap_attrs': {
            'dataNascimento': 'custom: birthDate',
            'dataAdmissao/Contratacao': 'custom: hireDate',
            'dataDemissao': 'NAO - manter no MySQL',
            'ferias/folga': 'NAO - manter no MySQL',
        }
    },
    '06_documentos_trabalhistas': {
        'titulo': 'DOCUMENTOS TRABALHISTAS',
        'destino_ldap': 'SIM - PIS/CTPS no LDAP',
        'patterns': ['pis', 'ctps'],
        'ldap_attrs': {
            'pis': 'custom: pisNumber',
            'ctps': 'custom: ctpsNumber',
        }
    },
    '07_dados_financeiros': {
        'titulo': 'DADOS FINANCEIROS',
        'destino_ldap': 'NAO - Manter APENAS no MySQL (acesso restrito)',
        'patterns': ['salario', 'remuneracao', 'vencimento', 'banco',
                     'agencia', 'conta', 'pix'],
        'ldap_attrs': {}
    },
    '08_familia': {
        'titulo': 'DADOS DE FAMILIA',
        'destino_ldap': 'NAO - Manter APENAS no MySQL',
        'patterns': ['pai', 'mae', 'conjuge', 'dependente', 'filho'],
        'ldap_attrs': {}
    },
    '09_saude_lgpd_sensivel': {
        'titulo': 'SAUDE - LGPD DADO SENSIVEL (Art. 5, II)',
        'destino_ldap': 'NAO - NUNCA colocar no LDAP. Acesso ultra-restrito',
        'patterns': ['saude', 'cid', 'atestado', 'exame', 'aso'],
        'ldap_attrs': {}
    },
    '10_credenciais': {
        'titulo': 'CREDENCIAIS DE ACESSO',
        'destino_ldap': 'SIM - Senha migra pro LDAP. Remover do banco.',
        'patterns': ['senha', 'password', 'login', 'usuario'],
        'ldap_attrs': {
            'login': 'uid',
            'senha': 'userPassword (bcrypt/SSHA, NUNCA MD5)',
        }
    },
}


def categorize(col_name):
    col_lower = col_name.lower()
    for cat_key, cat_info in CATEGORIES.items():
        if any(p in col_lower for p in cat_info['patterns']):
            return cat_key
    return None


def main():
    conn = get_connection('sqlserver')
    cursor = conn.cursor()

    where = " OR ".join([f"COLUMN_NAME LIKE '{p}'" for p in PERSONAL_PATTERNS])
    cursor.execute(f"""
        SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE,
               CHARACTER_MAXIMUM_LENGTH
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE {where}
        ORDER BY TABLE_SCHEMA, TABLE_NAME, ORDINAL_POSITION
    """)
    results = cursor.fetchall()

    # Group by category
    by_category = defaultdict(list)
    for schema, table, column, dtype, max_len in results:
        cat = categorize(column)
        if cat:
            by_category[cat].append((schema, table, column, dtype))

    # Create output directory
    output_dir = os.path.join(os.path.dirname(__file__), 'fichas_dados_pessoais')
    os.makedirs(output_dir, exist_ok=True)

    print("=" * 60)
    print("  GERANDO FICHAS DE DADOS PESSOAIS")
    print("=" * 60)

    # Generate one file per category
    for cat_key, cat_info in CATEGORIES.items():
        items = by_category.get(cat_key, [])
        filename = os.path.join(output_dir, f'{cat_key}.txt')

        with open(filename, 'w', encoding='utf-8') as f:
            f.write(f"{'=' * 60}\n")
            f.write(f"  {cat_info['titulo']}\n")
            f.write(f"{'=' * 60}\n\n")
            f.write(f"  Destino LDAP: {cat_info['destino_ldap']}\n")
            f.write(f"  Colunas encontradas: {len(items)}\n\n")

            # LDAP mapping (if applicable)
            if cat_info['ldap_attrs']:
                f.write(f"  MAPEAMENTO PARA LDAP:\n")
                f.write(f"  {'Campo':<30s} -> {'Atributo LDAP':<30s}\n")
                f.write(f"  {'-' * 62}\n")
                for campo, ldap_attr in cat_info['ldap_attrs'].items():
                    f.write(f"  {campo:<30s} -> {ldap_attr:<30s}\n")
                f.write(f"\n")

            # Unique field names (clean list for LDAP modeling)
            seen_fields = {}
            for schema, table, column, dtype in items:
                col_key = column.lower()
                if col_key not in seen_fields:
                    seen_fields[col_key] = {
                        'column': column,
                        'dtype': dtype,
                        'sources': []
                    }
                seen_fields[col_key]['sources'].append(f"{schema}.{table}")

            f.write(f"  CAMPOS UNICOS ENCONTRADOS ({len(seen_fields)}):\n")
            f.write(f"  {'-' * 60}\n\n")
            for col_key in sorted(seen_fields.keys()):
                info = seen_fields[col_key]
                f.write(f"  {info['column']}\n")
                f.write(f"    Tipo: {info['dtype']}\n")
                f.write(f"    Presente em {len(info['sources'])} tabelas:\n")
                for src in sorted(set(info['sources'])):
                    f.write(f"      - {src}\n")
                f.write(f"\n")

        print(f"  [{cat_key}] {cat_info['titulo']}: {len(items)} colunas -> {len(seen_fields)} campos unicos")

    # Generate summary file
    summary_file = os.path.join(output_dir, '00_resumo.txt')
    with open(summary_file, 'w', encoding='utf-8') as f:
        f.write(f"{'=' * 60}\n")
        f.write(f"  RESUMO - DADOS PESSOAIS NO BANCO neeo_ntl\n")
        f.write(f"  Data: {datetime.now():%Y-%m-%d %H:%M}\n")
        f.write(f"  Total colunas analisadas: {len(results)}\n")
        f.write(f"{'=' * 60}\n\n")

        f.write(f"  ARQUIVOS GERADOS:\n")
        f.write(f"  {'-' * 50}\n\n")

        total_unique = 0
        for cat_key, cat_info in CATEGORIES.items():
            items = by_category.get(cat_key, [])
            unique = len(set(col.lower() for _, _, col, _ in items))
            total_unique += unique
            destino = "LDAP" if "SIM" in cat_info['destino_ldap'] else "MySQL"
            f.write(f"  {cat_key}.txt\n")
            f.write(f"    {cat_info['titulo']}\n")
            f.write(f"    {len(items)} colunas / {unique} campos unicos\n")
            f.write(f"    Destino: {destino}\n\n")

        f.write(f"\n  {'=' * 50}\n")
        f.write(f"  RESUMO POR DESTINO:\n")
        f.write(f"  {'=' * 50}\n\n")

        ldap_count = 0
        mysql_count = 0
        for cat_key, cat_info in CATEGORIES.items():
            items = by_category.get(cat_key, [])
            unique = len(set(col.lower() for _, _, col, _ in items))
            if "SIM" in cat_info['destino_ldap']:
                ldap_count += unique
                f.write(f"  LDAP  <- {cat_info['titulo']}: {unique} campos\n")
            else:
                mysql_count += unique
                f.write(f"  MySQL <- {cat_info['titulo']}: {unique} campos\n")

        f.write(f"\n  Total campos para LDAP:  {ldap_count}\n")
        f.write(f"  Total campos no MySQL:   {mysql_count}\n")

    print(f"\n  Resumo: {summary_file}")
    print(f"  Pasta: {output_dir}")
    print(f"  Total: {len(results)} colunas em {len(by_category)} categorias")

    conn.close()


if __name__ == '__main__':
    main()
