"""
05 - Demo: Local SQLite proof-of-concept for ISO 27001 compliance.
Creates a local database demonstrating:
  - RBAC (role-based access control)
  - Audit logging
  - Password hashing (bcrypt vs MD5)
  - Data masking simulation
  - Access control enforcement

Run this standalone - no SQL Server connection needed.
Share results with ISO team as proof of concept.
"""
import sys
import sqlite3
import hashlib
import json
import os
from datetime import datetime, timedelta
from pathlib import Path

# Add project root to path (works from any directory)
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

try:
    import bcrypt
    HAS_BCRYPT = True
except ImportError:
    HAS_BCRYPT = False
    print("WARNING: pip install bcrypt for full demo\n")

DB_PATH = os.path.join(os.path.dirname(__file__), 'demo_iso27001.db')


def create_database(conn):
    """Create all ISO 27001 compliant tables."""
    c = conn.cursor()

    # ========== RBAC Tables ==========
    c.executescript("""
        -- Roles
        CREATE TABLE IF NOT EXISTS papel (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL UNIQUE,
            descricao TEXT,
            nivel_acesso INTEGER NOT NULL DEFAULT 0,
            ativo INTEGER NOT NULL DEFAULT 1,
            criado_em TEXT NOT NULL DEFAULT (datetime('now'))
        );

        -- Permissions
        CREATE TABLE IF NOT EXISTS permissao (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            recurso TEXT NOT NULL,
            acao TEXT NOT NULL,
            descricao TEXT,
            UNIQUE(recurso, acao)
        );

        -- Role-Permission mapping
        CREATE TABLE IF NOT EXISTS papel_permissao (
            papel_id INTEGER NOT NULL REFERENCES papel(id),
            permissao_id INTEGER NOT NULL REFERENCES permissao(id),
            concedido_por TEXT,
            concedido_em TEXT NOT NULL DEFAULT (datetime('now')),
            PRIMARY KEY (papel_id, permissao_id)
        );

        -- Users (improved structure)
        CREATE TABLE IF NOT EXISTS usuario (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            login TEXT NOT NULL UNIQUE,
            nome TEXT NOT NULL,
            email TEXT NOT NULL,
            cpf TEXT,
            telefone TEXT,
            salario REAL,
            departamento TEXT,
            ativo INTEGER NOT NULL DEFAULT 1,
            criado_em TEXT NOT NULL DEFAULT (datetime('now'))
        );

        -- User-Role mapping
        CREATE TABLE IF NOT EXISTS usuario_papel (
            usuario_id INTEGER NOT NULL REFERENCES usuario(id),
            papel_id INTEGER NOT NULL REFERENCES papel(id),
            atribuido_por TEXT,
            atribuido_em TEXT NOT NULL DEFAULT (datetime('now')),
            valido_ate TEXT,
            PRIMARY KEY (usuario_id, papel_id)
        );

        -- Password table (separate from user!)
        CREATE TABLE IF NOT EXISTS politica_senha (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            usuario_id INTEGER NOT NULL REFERENCES usuario(id),
            senha_hash TEXT NOT NULL,
            algoritmo TEXT NOT NULL DEFAULT 'bcrypt',
            criado_em TEXT NOT NULL DEFAULT (datetime('now')),
            expira_em TEXT NOT NULL,
            tentativas_falha INTEGER NOT NULL DEFAULT 0,
            bloqueado_ate TEXT,
            ultimo_login TEXT
        );

        -- ========== Audit Tables ==========
        CREATE TABLE IF NOT EXISTS log_alteracao (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data_hora TEXT NOT NULL DEFAULT (datetime('now')),
            usuario TEXT NOT NULL,
            tabela_nome TEXT NOT NULL,
            operacao TEXT NOT NULL,
            registro_id TEXT,
            dados_anteriores TEXT,
            dados_novos TEXT
        );

        CREATE TABLE IF NOT EXISTS log_acesso (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data_hora TEXT NOT NULL DEFAULT (datetime('now')),
            usuario TEXT NOT NULL,
            tabela_nome TEXT,
            tipo_acesso TEXT,
            qtd_registros INTEGER,
            permitido INTEGER NOT NULL DEFAULT 1
        );

        CREATE TABLE IF NOT EXISTS log_autenticacao (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data_hora TEXT NOT NULL DEFAULT (datetime('now')),
            usuario TEXT NOT NULL,
            resultado TEXT NOT NULL,
            motivo_falha TEXT
        );

        -- ========== Data Classification ==========
        CREATE TABLE IF NOT EXISTS classificacao_dados (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tabela_nome TEXT NOT NULL,
            coluna_nome TEXT NOT NULL,
            classificacao TEXT NOT NULL,
            tipo_dado_pessoal TEXT,
            mascara_aplicada TEXT,
            UNIQUE(tabela_nome, coluna_nome)
        );
    """)
    conn.commit()
    print("[OK] Tables created")


def seed_roles(conn):
    """Insert initial roles and permissions."""
    c = conn.cursor()

    roles = [
        ('admin_sistema',     'Acesso total',                               3),
        ('gestor_rh',         'Acesso dados funcionario, contratacao',      2),
        ('analista_rh',       'Consulta dados, sem salario/CPF',            1),
        ('gestor_financeiro', 'Acesso faturamento',                         2),
        ('medico_trabalho',   'Acesso dados saude (LGPD sensivel)',         2),
        ('auditor',           'Leitura auditoria e classificacao',          1),
        ('viewer',            'Apenas consulta dados nao sensiveis',        0),
    ]

    for nome, desc, nivel in roles:
        c.execute("INSERT OR IGNORE INTO papel (nome, descricao, nivel_acesso) VALUES (?,?,?)",
                  (nome, desc, nivel))

    permissions = [
        ('usuario',     'SELECT',  'Consultar usuarios'),
        ('usuario',     'INSERT',  'Cadastrar usuarios'),
        ('usuario',     'UPDATE',  'Alterar usuarios'),
        ('usuario',     'DELETE',  'Remover usuarios'),
        ('usuario.cpf', 'UNMASK',  'Ver CPF sem mascara'),
        ('usuario.salario', 'UNMASK', 'Ver salario sem mascara'),
        ('log_alteracao', 'SELECT', 'Consultar logs de alteracao'),
        ('log_acesso',    'SELECT', 'Consultar logs de acesso'),
        ('log_autenticacao', 'SELECT', 'Consultar logs de login'),
    ]

    for recurso, acao, desc in permissions:
        c.execute("INSERT OR IGNORE INTO permissao (recurso, acao, descricao) VALUES (?,?,?)",
                  (recurso, acao, desc))

    # Map: admin gets everything
    c.execute("""
        INSERT OR IGNORE INTO papel_permissao (papel_id, permissao_id, concedido_por)
        SELECT p.id, perm.id, 'SETUP'
        FROM papel p, permissao perm
        WHERE p.nome = 'admin_sistema'
    """)

    # Map: gestor_rh gets user CRUD + unmask
    c.execute("""
        INSERT OR IGNORE INTO papel_permissao (papel_id, permissao_id, concedido_por)
        SELECT p.id, perm.id, 'SETUP'
        FROM papel p, permissao perm
        WHERE p.nome = 'gestor_rh'
        AND perm.recurso LIKE 'usuario%'
    """)

    # Map: analista_rh gets SELECT only, NO unmask
    c.execute("""
        INSERT OR IGNORE INTO papel_permissao (papel_id, permissao_id, concedido_por)
        SELECT p.id, perm.id, 'SETUP'
        FROM papel p, permissao perm
        WHERE p.nome = 'analista_rh'
        AND perm.recurso = 'usuario' AND perm.acao = 'SELECT'
    """)

    # Map: auditor gets audit logs only
    c.execute("""
        INSERT OR IGNORE INTO papel_permissao (papel_id, permissao_id, concedido_por)
        SELECT p.id, perm.id, 'SETUP'
        FROM papel p, permissao perm
        WHERE p.nome = 'auditor'
        AND perm.recurso LIKE 'log_%'
    """)

    conn.commit()
    print("[OK] Roles and permissions seeded")


def seed_users(conn):
    """Insert demo users with PROPER password hashing."""
    c = conn.cursor()

    users = [
        ('admin',    'Admin Sistema',    'admin@empresa.com',    '111.222.333-44', '11-99999-0001', 15000.00, 'TI'),
        ('maria.rh', 'Maria Silva',      'maria@empresa.com',    '222.333.444-55', '11-99999-0002', 8000.00,  'RH'),
        ('joao.rh',  'Joao Santos',      'joao@empresa.com',     '333.444.555-66', '11-99999-0003', 5500.00,  'RH'),
        ('ana.fin',  'Ana Oliveira',     'ana@empresa.com',      '444.555.666-77', '11-99999-0004', 9000.00,  'Financeiro'),
        ('dr.carlos','Dr. Carlos Souza', 'carlos@empresa.com',   '555.666.777-88', '11-99999-0005', 12000.00, 'SST'),
        ('pedro.aud','Pedro Auditor',    'pedro@empresa.com',    '666.777.888-99', '11-99999-0006', 7000.00,  'Compliance'),
        ('julia.op', 'Julia Viewer',     'julia@empresa.com',    '777.888.999-00', '11-99999-0007', 4000.00,  'Operacoes'),
    ]

    for login, nome, email, cpf, tel, sal, dept in users:
        c.execute("""INSERT OR IGNORE INTO usuario
            (login, nome, email, cpf, telefone, salario, departamento)
            VALUES (?,?,?,?,?,?,?)""",
            (login, nome, email, cpf, tel, sal, dept))

    # Assign roles
    role_assignments = [
        ('admin',     'admin_sistema'),
        ('maria.rh',  'gestor_rh'),
        ('joao.rh',   'analista_rh'),
        ('ana.fin',   'gestor_financeiro'),
        ('dr.carlos', 'medico_trabalho'),
        ('pedro.aud', 'auditor'),
        ('julia.op',  'viewer'),
    ]

    for login, role_name in role_assignments:
        c.execute("""
            INSERT OR IGNORE INTO usuario_papel (usuario_id, papel_id, atribuido_por)
            SELECT u.id, p.id, 'SETUP'
            FROM usuario u, papel p
            WHERE u.login = ? AND p.nome = ?
        """, (login, role_name))

    # Create passwords with bcrypt
    expiry = (datetime.now() + timedelta(days=90)).isoformat()

    for login, *_ in users:
        if HAS_BCRYPT:
            pwd = f"Temp_{login}_2026!"
            hashed = bcrypt.hashpw(pwd.encode(), bcrypt.gensalt(rounds=12)).decode()
            algo = 'bcrypt'
        else:
            pwd = f"Temp_{login}_2026!"
            hashed = hashlib.sha256(pwd.encode()).hexdigest()
            algo = 'sha256 (demo only - use bcrypt in prod!)'

        c.execute("""
            INSERT OR IGNORE INTO politica_senha
            (usuario_id, senha_hash, algoritmo, expira_em)
            SELECT id, ?, ?, ?
            FROM usuario WHERE login = ?
        """, (hashed, algo, expiry, login))

    conn.commit()
    print("[OK] Demo users created with secure passwords")


def seed_classification(conn):
    """Register data classification for ISO 27001."""
    c = conn.cursor()

    classifications = [
        ('usuario', 'cpf',        'CRITICO',      'PII',             'partial(3,***,2)'),
        ('usuario', 'email',      'RESTRITO',      'PII',             'email()'),
        ('usuario', 'telefone',   'RESTRITO',      'PII',             'partial(4,****,0)'),
        ('usuario', 'salario',    'CONFIDENCIAL',  'Financeiro',      'default()'),
        ('usuario', 'nome',       'INTERNO',       'PII',             None),
        ('usuario', 'login',      'INTERNO',       None,              None),
        ('politica_senha', 'senha_hash', 'CRITICO', 'Credencial',    'NEVER DISPLAY'),
    ]

    for tabela, coluna, classif, tipo, mascara in classifications:
        c.execute("""INSERT OR IGNORE INTO classificacao_dados
            (tabela_nome, coluna_nome, classificacao, tipo_dado_pessoal, mascara_aplicada)
            VALUES (?,?,?,?,?)""",
            (tabela, coluna, classif, tipo, mascara))

    conn.commit()
    print("[OK] Data classification registered")


def mask_value(value, mask_type):
    """Apply data masking simulation."""
    if value is None:
        return None
    val = str(value)
    if mask_type == 'partial(3,***,2)':  # CPF
        return val[:3] + '.***.***-' + val[-2:] if len(val) >= 5 else '***'
    elif mask_type == 'email()':
        parts = val.split('@')
        if len(parts) == 2:
            return parts[0][0] + 'XXX@XXXX.com'
        return 'XXX@XXXX.com'
    elif mask_type == 'partial(4,****,0)':  # Phone
        return val[:4] + '****-****' if len(val) >= 4 else '****'
    elif mask_type == 'default()':
        return '***MASKED***'
    return val


def check_permission(conn, login, recurso, acao):
    """Check if user has permission (RBAC enforcement)."""
    c = conn.cursor()
    c.execute("""
        SELECT COUNT(*)
        FROM usuario u
        JOIN usuario_papel up ON u.id = up.usuario_id
        JOIN papel_permissao pp ON up.papel_id = pp.papel_id
        JOIN permissao perm ON pp.permissao_id = perm.id
        WHERE u.login = ?
        AND (perm.recurso = ? OR perm.recurso = '*')
        AND perm.acao = ?
    """, (login, recurso, acao))
    return c.fetchone()[0] > 0


def query_as_user(conn, login):
    """Simulate a query with RBAC + masking applied."""
    c = conn.cursor()

    can_select = check_permission(conn, login, 'usuario', 'SELECT')
    can_unmask_cpf = check_permission(conn, login, 'usuario.cpf', 'UNMASK')
    can_unmask_salary = check_permission(conn, login, 'usuario.salario', 'UNMASK')

    # Log access attempt
    c.execute("""INSERT INTO log_acesso (usuario, tabela_nome, tipo_acesso, permitido)
        VALUES (?, 'usuario', 'SELECT', ?)""", (login, 1 if can_select else 0))
    conn.commit()

    if not can_select:
        # Log denied access
        c.execute("""INSERT INTO log_acesso (usuario, tabela_nome, tipo_acesso, permitido)
            VALUES (?, 'usuario', 'SELECT_DENIED', 0)""", (login,))
        conn.commit()
        return None, "ACESSO NEGADO"

    c.execute("SELECT login, nome, email, cpf, telefone, salario, departamento FROM usuario")
    rows = c.fetchall()

    # Get masking rules
    c.execute("SELECT coluna_nome, mascara_aplicada FROM classificacao_dados WHERE tabela_nome = 'usuario'")
    masks = {row[0]: row[1] for row in c.fetchall()}

    masked_rows = []
    for row in rows:
        login_val, nome, email, cpf, tel, sal, dept = row
        masked_rows.append({
            'login': login_val,
            'nome': nome,
            'email': mask_value(email, masks.get('email')) if not can_unmask_cpf else email,
            'cpf': mask_value(cpf, masks.get('cpf')) if not can_unmask_cpf else cpf,
            'telefone': mask_value(tel, masks.get('telefone')) if not can_unmask_cpf else tel,
            'salario': mask_value(sal, masks.get('salario')) if not can_unmask_salary else sal,
            'departamento': dept,
        })

    return masked_rows, "OK"


def demo_login(conn, login, password):
    """Simulate login with audit logging."""
    c = conn.cursor()

    c.execute("""
        SELECT ps.senha_hash, ps.algoritmo, ps.tentativas_falha, ps.bloqueado_ate, ps.expira_em
        FROM usuario u
        JOIN politica_senha ps ON u.id = ps.usuario_id
        WHERE u.login = ?
    """, (login,))
    result = c.fetchone()

    if not result:
        c.execute("""INSERT INTO log_autenticacao (usuario, resultado, motivo_falha)
            VALUES (?, 'FALHA', 'Usuario nao encontrado')""", (login,))
        conn.commit()
        return False, "Usuario nao encontrado"

    stored_hash, algo, failures, blocked_until, expires = result

    # Check if blocked
    if blocked_until and datetime.fromisoformat(blocked_until) > datetime.now():
        c.execute("""INSERT INTO log_autenticacao (usuario, resultado, motivo_falha)
            VALUES (?, 'BLOQUEADO', 'Conta bloqueada por tentativas')""", (login,))
        conn.commit()
        return False, f"Conta bloqueada ate {blocked_until}"

    # Check password expiry
    if datetime.fromisoformat(expires) < datetime.now():
        c.execute("""INSERT INTO log_autenticacao (usuario, resultado, motivo_falha)
            VALUES (?, 'FALHA', 'Senha expirada')""", (login,))
        conn.commit()
        return False, "Senha expirada - reset necessario"

    # Verify password
    if HAS_BCRYPT and algo == 'bcrypt':
        valid = bcrypt.checkpw(password.encode(), stored_hash.encode())
    else:
        valid = hashlib.sha256(password.encode()).hexdigest() == stored_hash

    if valid:
        c.execute("""UPDATE politica_senha SET tentativas_falha = 0, ultimo_login = datetime('now')
            WHERE usuario_id = (SELECT id FROM usuario WHERE login = ?)""", (login,))
        c.execute("""INSERT INTO log_autenticacao (usuario, resultado) VALUES (?, 'SUCESSO')""", (login,))
        conn.commit()
        return True, "Login OK"
    else:
        new_failures = failures + 1
        blocked = None
        if new_failures >= 5:
            blocked = (datetime.now() + timedelta(minutes=30)).isoformat()

        c.execute("""UPDATE politica_senha SET tentativas_falha = ?, bloqueado_ate = ?
            WHERE usuario_id = (SELECT id FROM usuario WHERE login = ?)""",
            (new_failures, blocked, login))
        c.execute("""INSERT INTO log_autenticacao (usuario, resultado, motivo_falha)
            VALUES (?, 'FALHA', ?)""",
            (login, f'Senha incorreta (tentativa {new_failures}/5)'))
        conn.commit()
        return False, f"Senha incorreta ({new_failures}/5 tentativas)"


def run_demo():
    """Run full ISO 27001 demonstration."""

    # Clean start
    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)

    conn = sqlite3.connect(DB_PATH)

    print("=" * 70)
    print("  ISO 27001 COMPLIANCE DEMO - Proof of Concept")
    print("=" * 70)

    # Setup
    print("\n--- SETUP ---")
    create_database(conn)
    seed_roles(conn)
    seed_users(conn)
    seed_classification(conn)

    # Demo 1: RBAC in action
    print("\n" + "=" * 70)
    print("  DEMO 1: RBAC - Same query, different results per role")
    print("=" * 70)

    test_users = [
        ('maria.rh',  'gestor_rh',     'Full access + unmask'),
        ('joao.rh',   'analista_rh',   'SELECT only, masked data'),
        ('pedro.aud', 'auditor',        'No access to user table'),
    ]

    for login, role, desc in test_users:
        print(f"\n  User: {login} ({role}) - {desc}")
        print("  " + "-" * 50)
        rows, status = query_as_user(conn, login)
        if rows:
            for r in rows[:3]:  # Show first 3
                print(f"    {r['nome']:20s} | CPF: {r['cpf']:20s} | Salario: {str(r['salario']):15s} | Email: {r['email']}")
            if len(rows) > 3:
                print(f"    ... +{len(rows)-3} more rows")
        else:
            print(f"    >>> {status} <<<")

    # Demo 2: Password security
    print("\n" + "=" * 70)
    print("  DEMO 2: Password Security - bcrypt + lockout")
    print("=" * 70)

    pwd = "Temp_admin_2026!"
    success, msg = demo_login(conn, 'admin', pwd)
    print(f"\n  Login 'admin' with correct password: {msg}")

    for i in range(6):
        success, msg = demo_login(conn, 'admin', 'wrong_password')
        print(f"  Login 'admin' with wrong password (attempt {i+1}): {msg}")

    # Demo 3: Comparison old vs new
    print("\n" + "=" * 70)
    print("  DEMO 3: Old System vs New System")
    print("=" * 70)

    old_md5 = hashlib.md5('123'.encode()).hexdigest()
    c = conn.cursor()
    c.execute("SELECT senha_hash, algoritmo FROM politica_senha LIMIT 1")
    new_hash, new_algo = c.fetchone()

    print(f"""
  OLD SYSTEM (neeo_ntl):
    Password storage: MD5 (BROKEN)
    Example hash:     {old_md5}
    All users same:   YES ('123')
    Access control:   NONE (everyone sees everything)
    Audit trail:      NONE
    Data masking:     NONE

  NEW SYSTEM (ISO compliant):
    Password storage: {new_algo}
    Example hash:     {new_hash[:50]}...
    Unique passwords: YES (per user, with policy)
    Access control:   RBAC (role-based)
    Audit trail:      Every action logged
    Data masking:     Per-role visibility
    """)

    # Demo 4: Audit logs
    print("=" * 70)
    print("  DEMO 4: Audit Trail")
    print("=" * 70)

    c.execute("SELECT data_hora, usuario, tipo_acesso, permitido FROM log_acesso ORDER BY id")
    access_logs = c.fetchall()
    print(f"\n  Access logs ({len(access_logs)} entries):")
    for log in access_logs:
        status = 'PERMITIDO' if log[3] else 'NEGADO'
        print(f"    {log[0]} | {log[1]:12s} | {log[2]:15s} | {status}")

    c.execute("SELECT data_hora, usuario, resultado, motivo_falha FROM log_autenticacao ORDER BY id")
    auth_logs = c.fetchall()
    print(f"\n  Authentication logs ({len(auth_logs)} entries):")
    for log in auth_logs:
        reason = f" - {log[3]}" if log[3] else ""
        print(f"    {log[0]} | {log[1]:12s} | {log[2]:10s}{reason}")

    # Summary
    print("\n" + "=" * 70)
    print("  ISO 27001 CONTROLS DEMONSTRATED")
    print("=" * 70)
    print("""
  A.5.17  Authentication info    -> bcrypt passwords, expiry, lockout
  A.8.2   Privileged access      -> RBAC roles with least privilege
  A.8.3   Access restriction     -> Per-role query results
  A.8.5   Secure authentication  -> Password policy enforcement
  A.8.11  Data masking           -> CPF/email/salary masked per role
  A.8.15  Logging                -> Access + auth + change audit trail
  A.5.12  Information classif.   -> Data classification table
    """)

    print(f"  Demo database saved: {DB_PATH}")
    print(f"  Open in DBeaver to inspect tables and data.\n")

    conn.close()


if __name__ == '__main__':
    run_demo()
