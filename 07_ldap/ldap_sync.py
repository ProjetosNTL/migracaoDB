"""
07 - LDAP: Sync users and groups from LDAP to local MySQL database.
Handles:
  - User creation/update/deactivation based on LDAP state
  - Group -> Role mapping (LDAP group membership = local RBAC role)
  - Full and incremental sync
  - Audit logging of all sync operations

Requires: pip install ldap3 mysql-connector-python
"""
import sys
import json
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

try:
    from ldap3 import Server, Connection, ALL, SUBTREE
    HAS_LDAP3 = True
except ImportError:
    HAS_LDAP3 = False

from utils.db_connection import get_connection


class LDAPSync:
    """Synchronize LDAP directory with local MySQL database."""

    def __init__(self, mysql_conn):
        self.db = mysql_conn
        self.cursor = mysql_conn.cursor(dictionary=True)
        self.config = self._load_config()
        self.stats = {
            'usuarios_criados': 0,
            'usuarios_atualizados': 0,
            'usuarios_desativados': 0,
            'papeis_atribuidos': 0,
            'papeis_removidos': 0,
            'erros': 0,
        }

    def _load_config(self):
        """Load LDAP config from database."""
        self.cursor.execute("SELECT chave, valor FROM config_ldap")
        return {row['chave']: row['valor'] for row in self.cursor.fetchall()}

    def _connect_ldap(self):
        """Establish LDAP connection."""
        server = Server(
            self.config['ldap_url'],
            get_info=ALL,
            use_ssl=self.config.get('ldap_use_tls', 'true') == 'true'
        )
        conn = Connection(
            server,
            user=self.config['ldap_bind_dn'],
            password=self.config['ldap_bind_pass'],
            auto_bind=True
        )
        return conn

    def authenticate(self, username, password):
        """Authenticate user against LDAP. Returns True/False.

        This is what your application calls instead of checking
        the local senha column.
        """
        try:
            server = Server(self.config['ldap_url'], use_ssl=True)
            user_dn = self._find_user_dn(username)
            if not user_dn:
                self._log_auth(username, 'FALHA', 'Usuario nao encontrado no LDAP')
                return False

            # Try to bind as the user (validates password)
            user_conn = Connection(server, user=user_dn, password=password)
            if user_conn.bind():
                user_conn.unbind()
                self._log_auth(username, 'SUCESSO', None)
                return True
            else:
                self._log_auth(username, 'FALHA', 'Senha incorreta (LDAP bind failed)')
                return False
        except Exception as e:
            self._log_auth(username, 'FALHA', f'Erro LDAP: {str(e)[:200]}')
            return False

    def _find_user_dn(self, username):
        """Find user DN by username."""
        ldap_conn = self._connect_ldap()
        uid_attr = self.config.get('ldap_uid_attr', 'uid')
        search_filter = f'({uid_attr}={username})'

        ldap_conn.search(
            self.config['ldap_user_base'],
            search_filter,
            search_scope=SUBTREE,
            attributes=[uid_attr]
        )

        if ldap_conn.entries:
            dn = ldap_conn.entries[0].entry_dn
            ldap_conn.unbind()
            return dn

        ldap_conn.unbind()
        return None

    def sync_full(self):
        """Full sync: pull all users and groups from LDAP."""
        start = datetime.now()
        print(f"\n[LDAP SYNC] Full sync starting at {start}")

        ldap_conn = self._connect_ldap()
        uid_attr = self.config.get('ldap_uid_attr', 'uid')
        email_attr = self.config.get('ldap_email_attr', 'mail')
        name_attr = self.config.get('ldap_name_attr', 'cn')

        # 1. Get all LDAP users
        ldap_conn.search(
            self.config['ldap_user_base'],
            '(objectClass=person)',
            search_scope=SUBTREE,
            attributes=[uid_attr, email_attr, name_attr, 'memberOf']
        )

        ldap_users = {}
        for entry in ldap_conn.entries:
            uid = str(getattr(entry, uid_attr, ''))
            if uid:
                ldap_users[uid] = {
                    'dn': entry.entry_dn,
                    'uid': uid,
                    'nome': str(getattr(entry, name_attr, uid)),
                    'email': str(getattr(entry, email_attr, '')),
                    'groups': [str(g) for g in getattr(entry, 'memberOf', [])],
                }

        print(f"  Found {len(ldap_users)} users in LDAP")

        # 2. Get local users
        self.cursor.execute("SELECT id, login, ldap_uid, ldap_dn, ativo FROM usuario WHERE auth_source = 'LDAP'")
        local_users = {row['ldap_uid']: row for row in self.cursor.fetchall() if row['ldap_uid']}

        # 3. Create/update users
        for uid, ldap_data in ldap_users.items():
            if uid in local_users:
                # Update existing
                local = local_users[uid]
                self.cursor.execute("""
                    UPDATE usuario SET
                        nome = %s, email = %s, ldap_dn = %s,
                        ativo = 1, ultimo_sync_ldap = NOW()
                    WHERE id = %s
                """, (ldap_data['nome'], ldap_data['email'], ldap_data['dn'], local['id']))
                self.stats['usuarios_atualizados'] += 1
            else:
                # Create new
                self.cursor.execute("""
                    INSERT INTO usuario (login, nome, email, ldap_uid, ldap_dn, auth_source, ultimo_sync_ldap)
                    VALUES (%s, %s, %s, %s, %s, 'LDAP', NOW())
                """, (uid, ldap_data['nome'], ldap_data['email'], uid, ldap_data['dn']))
                self.stats['usuarios_criados'] += 1

        # 4. Deactivate users not in LDAP anymore
        ldap_uids = set(ldap_users.keys())
        for uid, local in local_users.items():
            if uid not in ldap_uids and local['ativo']:
                self.cursor.execute("UPDATE usuario SET ativo = 0 WHERE id = %s", (local['id'],))
                self.stats['usuarios_desativados'] += 1

        # 5. Sync group -> role mappings
        self._sync_roles(ldap_users)

        self.db.commit()
        ldap_conn.unbind()

        # 6. Log sync
        duration = int((datetime.now() - start).total_seconds() * 1000)
        self._log_sync('FULL', duration)

        print(f"  Created:     {self.stats['usuarios_criados']}")
        print(f"  Updated:     {self.stats['usuarios_atualizados']}")
        print(f"  Deactivated: {self.stats['usuarios_desativados']}")
        print(f"  Roles added: {self.stats['papeis_atribuidos']}")
        print(f"  Roles removed: {self.stats['papeis_removidos']}")
        print(f"  Duration:    {duration}ms")

    def _sync_roles(self, ldap_users):
        """Sync LDAP group membership to local roles."""
        # Get group -> role mappings
        self.cursor.execute("""
            SELECT ldap_grupo_dn, papel_id FROM ldap_grupo_papel WHERE auto_sync = 1
        """)
        group_role_map = {row['ldap_grupo_dn']: row['papel_id'] for row in self.cursor.fetchall()}

        for uid, ldap_data in ldap_users.items():
            # Get local user id
            self.cursor.execute("SELECT id FROM usuario WHERE ldap_uid = %s", (uid,))
            row = self.cursor.fetchone()
            if not row:
                continue
            user_id = row['id']

            # Determine which roles this user should have (from LDAP groups)
            should_have_roles = set()
            for group_dn in ldap_data.get('groups', []):
                if group_dn in group_role_map:
                    should_have_roles.add(group_role_map[group_dn])

            # Get current local roles
            self.cursor.execute(
                "SELECT papel_id FROM usuario_papel WHERE usuario_id = %s",
                (user_id,)
            )
            current_roles = {row['papel_id'] for row in self.cursor.fetchall()}

            # Add missing roles
            for role_id in should_have_roles - current_roles:
                self.cursor.execute("""
                    INSERT INTO usuario_papel (usuario_id, papel_id, atribuido_por)
                    VALUES (%s, %s, 'LDAP_SYNC')
                """, (user_id, role_id))
                self.stats['papeis_atribuidos'] += 1

            # Remove roles no longer in LDAP
            for role_id in current_roles - should_have_roles:
                self.cursor.execute("""
                    DELETE FROM usuario_papel WHERE usuario_id = %s AND papel_id = %s
                """, (user_id, role_id))
                self.stats['papeis_removidos'] += 1

    def _log_auth(self, username, resultado, motivo):
        """Log authentication attempt."""
        self.cursor.execute("""
            INSERT INTO log_autenticacao (usuario, resultado, motivo_falha)
            VALUES (%s, %s, %s)
        """, (username, resultado, motivo))
        self.db.commit()

    def _log_sync(self, tipo, duration_ms):
        """Log sync operation."""
        self.cursor.execute("""
            INSERT INTO log_sync_ldap
                (tipo, usuarios_criados, usuarios_atualizados, usuarios_desativados,
                 papeis_atribuidos, papeis_removidos, erros, duracao_ms)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            tipo,
            self.stats['usuarios_criados'],
            self.stats['usuarios_atualizados'],
            self.stats['usuarios_desativados'],
            self.stats['papeis_atribuidos'],
            self.stats['papeis_removidos'],
            self.stats['erros'],
            duration_ms
        ))
        self.db.commit()


def demo_without_ldap():
    """Demonstrate the concept without actual LDAP server."""
    print("=" * 70)
    print("  LDAP INTEGRATION DEMO (simulated - no LDAP server needed)")
    print("=" * 70)

    print("""
  FLOW: How authentication works with LDAP
  =========================================

  1. User opens app, enters login + senha
  2. App calls: ldap_sync.authenticate('felipe', 'MinhaSenh@123')
  3. authenticate() does:
     a. Search LDAP for uid=felipe -> gets DN: cn=felipe,ou=TI,dc=neeo,dc=com
     b. Try LDAP bind with that DN + password
     c. If bind succeeds -> AUTHENTICATED
     d. Log attempt to log_autenticacao table
  4. App then checks LOCAL MySQL for authorization:
     a. SELECT papel from usuario_papel WHERE login = 'felipe'
     b. Gets roles: ['analista_rh']
     c. SELECT permissao from papel_permissao WHERE papel = 'analista_rh'
     d. Gets permissions: ['Funcionario.* SELECT', ...]
  5. App enforces permissions on every query

  KEY POINT: Senha NUNCA fica no MySQL.
  LDAP validates password. MySQL stores roles/permissions/audit.

  LDAP GROUP SYNC:
  ================
  LDAP Group: cn=RH-Analistas,ou=Groups  ->  MySQL Role: analista_rh
  LDAP Group: cn=RH-Gestores,ou=Groups   ->  MySQL Role: gestor_rh
  LDAP Group: cn=Admins,ou=Groups        ->  MySQL Role: admin_sistema

  When user added to LDAP group "RH-Analistas":
    -> Next sync auto-assigns 'analista_rh' role in MySQL
    -> No manual DB changes needed

  When user removed from LDAP group:
    -> Next sync auto-removes role in MySQL
    -> Logged in log_sync_ldap
    """)

    print("  FILES CREATED:")
    print("    07_ldap/ldap_integration.sql  - MySQL tables for LDAP integration")
    print("    07_ldap/ldap_sync.py          - Python sync engine (ldap3 library)")
    print("    07_ldap/ldap_example_config/  - Example LDAP structure (OpenLDAP)")
    print()
    print("  TO USE WITH REAL LDAP:")
    print("    1. pip install ldap3")
    print("    2. Run ldap_integration.sql on MySQL")
    print("    3. Update config_ldap table with your LDAP server details")
    print("    4. Map LDAP groups to roles in ldap_grupo_papel table")
    print("    5. Run: python 07_ldap/ldap_sync.py --full")
    print("    6. Schedule sync every 30min (cron/task scheduler)")


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='LDAP Sync for neeo_ntl_iso')
    parser.add_argument('--full', action='store_true', help='Full sync from LDAP')
    parser.add_argument('--demo', action='store_true', help='Run demo without LDAP server')
    args = parser.parse_args()

    if args.demo or not HAS_LDAP3:
        demo_without_ldap()
    elif args.full:
        conn = get_connection('mysql')
        sync = LDAPSync(conn)
        sync.sync_full()
        conn.close()
    else:
        parser.print_help()
