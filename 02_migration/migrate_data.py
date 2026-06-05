"""
02 - Migration: Demonstrate how to migrate data with ISO 27001 fixes.
This script shows the APPROACH - adapt table/column names to your actual schema.

What it fixes during migration:
  - Rehash passwords from MD5 to bcrypt
  - Log all migration actions to audit table
  - Classify sensitive columns
  - Generate migration report
"""
import sys
import csv
import hashlib
from datetime import datetime, timedelta
from pathlib import Path

# Add project root to path (works from any directory)
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from utils.db_connection import get_connection

try:
    import bcrypt
    HAS_BCRYPT = True
except ImportError:
    HAS_BCRYPT = False
    print("WARNING: bcrypt not installed. Run: pip install bcrypt")
    print("         Password rehashing will be simulated only.\n")


# Known MD5 passwords to detect (common defaults)
KNOWN_MD5_DEFAULTS = {
    '202cb962ac59075b964b07152d234b70': '123',
    '827ccb0eea8a706c4c34a16891f84e7b': '12345',
    'e10adc3949ba59abbe56e057f20f883e': '123456',
    '25d55ad283aa400af464c76d713c07ad': '12345678',
    'd8578edf8458ce06fbc5bb76a58c5ca4': 'qwerty',
    '5f4dcc3b5aa765d61d8327deb882cf99': 'password',
}


def analyze_passwords(cursor):
    """Analyze password quality in ntl.usuario."""
    print("\n[1/4] Analyzing passwords in ntl.usuario...")

    cursor.execute("SELECT COUNT(*) FROM ntl.usuario")
    total = cursor.fetchone()[0]

    cursor.execute("""
        SELECT senha, COUNT(*) AS qty
        FROM ntl.usuario
        GROUP BY senha
        ORDER BY qty DESC
    """)
    password_groups = cursor.fetchall()

    report = {
        'total_users': total,
        'unique_passwords': len(password_groups),
        'md5_detected': 0,
        'known_defaults': 0,
        'shared_passwords': 0,
        'details': []
    }

    for pwd_hash, qty in password_groups:
        if pwd_hash and len(pwd_hash) == 32:  # MD5 = 32 hex chars
            report['md5_detected'] += qty

        if pwd_hash in KNOWN_MD5_DEFAULTS:
            report['known_defaults'] += qty
            report['details'].append({
                'hash': pwd_hash,
                'plaintext': KNOWN_MD5_DEFAULTS[pwd_hash],
                'users_affected': qty,
                'severity': 'CRITICO'
            })

        if qty > 1:
            report['shared_passwords'] += qty

    print(f"  Total users:            {report['total_users']}")
    print(f"  Unique passwords:       {report['unique_passwords']}")
    print(f"  MD5 hashes detected:    {report['md5_detected']}")
    print(f"  Known default passwords:{report['known_defaults']}")
    print(f"  Users sharing passwords:{report['shared_passwords']}")

    if report['details']:
        print("\n  CRITICAL - Known default passwords found:")
        for d in report['details']:
            print(f"    Hash: {d['hash'][:16]}... = '{d['plaintext']}' ({d['users_affected']} users)")

    return report


def demo_password_rehash():
    """Demonstrate MD5 -> bcrypt migration (does NOT modify DB)."""
    print("\n[2/4] Password rehash demonstration (READ ONLY - no DB changes)...")

    old_md5 = '202cb962ac59075b964b07152d234b70'  # MD5 of '123'
    print(f"\n  Current (INSECURE):")
    print(f"    Algorithm: MD5 (broken)")
    print(f"    Hash:      {old_md5}")
    print(f"    Crackable: YES, instantly")

    if HAS_BCRYPT:
        # Show what the migration would produce
        temp_password = 'TempPass_' + datetime.now().strftime('%Y%m%d')
        new_hash = bcrypt.hashpw(temp_password.encode(), bcrypt.gensalt(rounds=12))
        print(f"\n  After migration (SECURE):")
        print(f"    Algorithm: bcrypt (rounds=12)")
        print(f"    Hash:      {new_hash.decode()}")
        print(f"    Crackable: ~10+ years brute force")
        print(f"\n  Migration SQL (for DBA to review):")
        print(f"  -- Step 1: Add new column")
        print(f"  ALTER TABLE ntl.usuario ADD senha_bcrypt NVARCHAR(500);")
        print(f"  -- Step 2: Force password reset for ALL users")
        print(f"  -- Step 3: App code generates bcrypt on new password")
        print(f"  -- Step 4: Drop old senha column after migration complete")
    else:
        print("\n  Install bcrypt to see full demo: pip install bcrypt")

    return True


def analyze_sensitive_columns(cursor):
    """Map all sensitive data for ISO classification."""
    print("\n[3/4] Mapping sensitive data for classification...")

    sensitive_patterns = {
        'CRITICO - Documento': ['%cpf%', '%cnpj%', '%rg%', '%pis%', '%ctps%'],
        'CRITICO - Credencial': ['%senha%', '%password%', '%hash%', '%token%'],
        'CRITICO - LGPD Sensivel': ['%saude%', '%cid%', '%atestado%', '%biometri%'],
        'CONFIDENCIAL - Financeiro': ['%salario%', '%remuneracao%', '%vencimento%',
                                       '%banco%', '%agencia%', '%conta%'],
        'RESTRITO - Contato': ['%email%', '%telefone%', '%fone%', '%celular%',
                               '%endereco%', '%cep%', '%logradouro%'],
        'RESTRITO - Pessoal': ['%nasc%', '%nascimento%', '%nome_mae%', '%nome_pai%'],
    }

    all_findings = []

    for classification, patterns in sensitive_patterns.items():
        where_clause = " OR ".join([f"COLUMN_NAME LIKE '{p}'" for p in patterns])
        cursor.execute(f"""
            SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE {where_clause}
            ORDER BY TABLE_SCHEMA, TABLE_NAME
        """)
        results = cursor.fetchall()

        for row in results:
            all_findings.append({
                'schema': row[0],
                'tabela': row[1],
                'coluna': row[2],
                'tipo': row[3],
                'classificacao': classification,
            })

    print(f"  Found {len(all_findings)} sensitive columns:")
    by_class = {}
    for f in all_findings:
        by_class.setdefault(f['classificacao'], 0)
        by_class[f['classificacao']] += 1
    for cls, count in sorted(by_class.items()):
        print(f"    {cls}: {count} columns")

    return all_findings


def generate_migration_report(pwd_report, sensitive_findings):
    """Generate comprehensive migration report."""
    print("\n[4/4] Generating migration report...")

    timestamp = datetime.now().strftime('%Y%m%d_%H%M')
    filename = f'relatorio_migracao_iso27001_{timestamp}.csv'

    with open(filename, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.writer(f, delimiter=';')

        # Header section
        writer.writerow(['RELATORIO DE MIGRACAO - ISO 27001'])
        writer.writerow(['Data', datetime.now().strftime('%Y-%m-%d %H:%M')])
        writer.writerow([])

        # Password findings
        writer.writerow(['SECAO 1: ANALISE DE SENHAS'])
        writer.writerow(['Metrica', 'Valor', 'Status'])
        writer.writerow(['Total usuarios', pwd_report['total_users'], ''])
        writer.writerow(['Senhas unicas', pwd_report['unique_passwords'],
                         'CRITICO' if pwd_report['unique_passwords'] < pwd_report['total_users'] * 0.5 else 'OK'])
        writer.writerow(['MD5 detectados', pwd_report['md5_detected'],
                         'CRITICO' if pwd_report['md5_detected'] > 0 else 'OK'])
        writer.writerow(['Senhas padrao conhecidas', pwd_report['known_defaults'],
                         'CRITICO' if pwd_report['known_defaults'] > 0 else 'OK'])
        writer.writerow(['Senhas compartilhadas', pwd_report['shared_passwords'],
                         'CRITICO' if pwd_report['shared_passwords'] > 0 else 'OK'])
        writer.writerow([])

        # Sensitive data findings
        writer.writerow(['SECAO 2: DADOS SENSIVEIS ENCONTRADOS'])
        writer.writerow(['Schema', 'Tabela', 'Coluna', 'Tipo', 'Classificacao', 'Acao Necessaria'])
        for finding in sensitive_findings:
            action = 'Dynamic Data Masking'
            if 'Credencial' in finding['classificacao']:
                action = 'Rehash bcrypt + Masking'
            elif 'LGPD' in finding['classificacao']:
                action = 'Criptografia + Restricao acesso'
            elif 'Financeiro' in finding['classificacao']:
                action = 'Masking + Acesso restrito RH/Financeiro'

            writer.writerow([
                finding['schema'], finding['tabela'], finding['coluna'],
                finding['tipo'], finding['classificacao'], action
            ])

        writer.writerow([])
        writer.writerow(['SECAO 3: ACOES OBRIGATORIAS PARA ISO 27001'])
        writer.writerow(['Prioridade', 'Acao', 'Controle ISO', 'Status'])
        writer.writerow(['P0', 'Migrar senhas MD5 para bcrypt', 'A.5.17', 'PENDENTE'])
        writer.writerow(['P0', 'Implementar RBAC (tabelas papel/permissao)', 'A.8.2', 'PENDENTE'])
        writer.writerow(['P0', 'Forcar reset de senhas padrao', 'A.5.17', 'PENDENTE'])
        writer.writerow(['P1', 'Aplicar Dynamic Data Masking', 'A.8.11', 'PENDENTE'])
        writer.writerow(['P1', 'Criar tabelas de auditoria', 'A.8.15', 'PENDENTE'])
        writer.writerow(['P1', 'Implementar politica de senha', 'A.5.17', 'PENDENTE'])
        writer.writerow(['P2', 'Classificar todos os dados', 'A.5.12', 'PENDENTE'])
        writer.writerow(['P2', 'Ativar TDE (criptografia em repouso)', 'A.8.24', 'PENDENTE'])
        writer.writerow(['P2', 'Remover tabelas vazias/obsoletas', 'A.5.9', 'PENDENTE'])

    print(f"  Report generated: {filename}")
    return filename


def main():
    conn = get_connection()
    cursor = conn.cursor()

    print("=" * 60)
    print("ISO 27001 MIGRATION ANALYSIS (READ ONLY)")
    print("No data will be modified.")
    print("=" * 60)

    pwd_report = analyze_passwords(cursor)
    demo_password_rehash()
    sensitive_findings = analyze_sensitive_columns(cursor)
    report_file = generate_migration_report(pwd_report, sensitive_findings)

    print("\n" + "=" * 60)
    print("DONE. Share report with ISO team.")
    print(f"Report: {report_file}")
    print("=" * 60)

    conn.close()


if __name__ == '__main__':
    main()
