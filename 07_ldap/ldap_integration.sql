-- ============================================================
-- LDAP Integration - MySQL Database Schema
-- ============================================================
-- Centralizar autenticacao via LDAP (AD/OpenLDAP).
-- Banco MySQL so guarda autorizacao (RBAC) e auditoria.
-- Senha SAI do banco. Login validado pelo LDAP.
-- ============================================================

USE neeo_ntl_iso;

-- ============================================================
-- SECTION 1: User table (LDAP-aware)
-- ============================================================

-- Drop senha column - authentication moves to LDAP
-- usuario table becomes a LOCAL REFERENCE only
ALTER TABLE usuario
    ADD COLUMN ldap_dn VARCHAR(500) NULL COMMENT 'Distinguished Name no LDAP (ex: cn=felipe,ou=TI,dc=neeo,dc=com)',
    ADD COLUMN ldap_uid VARCHAR(100) NULL COMMENT 'UID no LDAP (login centralizado)',
    ADD COLUMN auth_source ENUM('LDAP', 'LOCAL') NOT NULL DEFAULT 'LDAP' COMMENT 'Onde autentica: LDAP (padrao) ou LOCAL (fallback/servicos)',
    ADD COLUMN ultimo_sync_ldap DATETIME NULL COMMENT 'Ultimo sync com LDAP';

-- Index for LDAP lookups
CREATE INDEX idx_usuario_ldap_uid ON usuario(ldap_uid);
CREATE INDEX idx_usuario_ldap_dn ON usuario(ldap_dn);

-- ============================================================
-- SECTION 2: LDAP Group -> Role Mapping
-- ============================================================

-- Maps LDAP groups to local RBAC roles
CREATE TABLE IF NOT EXISTS ldap_grupo_papel (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ldap_grupo_dn VARCHAR(500) NOT NULL COMMENT 'DN do grupo no LDAP (ex: cn=RH,ou=Groups,dc=neeo,dc=com)',
    ldap_grupo_nome VARCHAR(200) NOT NULL COMMENT 'Nome do grupo LDAP',
    papel_id INT NOT NULL COMMENT 'Papel local correspondente',
    auto_sync TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Sincronizar automaticamente',
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (papel_id) REFERENCES papel(id) ON DELETE CASCADE,
    UNIQUE KEY uq_ldap_grupo_papel (ldap_grupo_dn, papel_id)
) ENGINE=InnoDB COMMENT='Mapeamento grupo LDAP -> papel local';

-- ============================================================
-- SECTION 3: LDAP Sync Log
-- ============================================================

CREATE TABLE IF NOT EXISTS log_sync_ldap (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tipo ENUM('FULL', 'INCREMENTAL', 'USER') NOT NULL,
    usuarios_criados INT NOT NULL DEFAULT 0,
    usuarios_atualizados INT NOT NULL DEFAULT 0,
    usuarios_desativados INT NOT NULL DEFAULT 0,
    papeis_atribuidos INT NOT NULL DEFAULT 0,
    papeis_removidos INT NOT NULL DEFAULT 0,
    erros INT NOT NULL DEFAULT 0,
    detalhes TEXT,
    duracao_ms INT,
    INDEX idx_sync_data (data_hora)
) ENGINE=InnoDB COMMENT='Log de sincronizacao LDAP';

-- ============================================================
-- SECTION 4: LDAP Configuration
-- ============================================================

CREATE TABLE IF NOT EXISTS config_ldap (
    id INT AUTO_INCREMENT PRIMARY KEY,
    chave VARCHAR(100) NOT NULL UNIQUE,
    valor VARCHAR(500) NOT NULL,
    descricao VARCHAR(500),
    sensivel TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Se sim, nao exibir valor em logs',
    atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='Configuracao LDAP';

-- Default LDAP config (adapt to your environment)
INSERT INTO config_ldap (chave, valor, descricao, sensivel) VALUES
('ldap_url',        'ldap://ldap.neeo.com:389',          'URL do servidor LDAP',              0),
('ldap_base_dn',    'dc=neeo,dc=com',                     'Base DN para buscas',              0),
('ldap_bind_dn',    'cn=admin,dc=neeo,dc=com',            'DN para bind (service account)',   0),
('ldap_bind_pass',  'CHANGE_ME',                           'Senha do service account',        1),
('ldap_user_base',  'ou=People,dc=neeo,dc=com',           'OU onde ficam os usuarios',       0),
('ldap_group_base', 'ou=Groups,dc=neeo,dc=com',           'OU onde ficam os grupos',         0),
('ldap_user_filter', '(&(objectClass=person)(uid={0}))',   'Filtro para buscar usuario',      0),
('ldap_uid_attr',   'uid',                                 'Atributo de login (uid ou sAMAccountName para AD)', 0),
('ldap_email_attr', 'mail',                                'Atributo de email',               0),
('ldap_name_attr',  'cn',                                  'Atributo de nome completo',       0),
('ldap_use_tls',    'true',                                'Usar STARTTLS',                   0),
('ldap_sync_interval_min', '30',                           'Intervalo de sync em minutos',    0);

-- ============================================================
-- SECTION 5: Sample Group-Role Mappings
-- ============================================================

-- Adapt these to your LDAP groups
INSERT INTO ldap_grupo_papel (ldap_grupo_dn, ldap_grupo_nome, papel_id) VALUES
('cn=Admins,ou=Groups,dc=neeo,dc=com',       'Admins',       (SELECT id FROM papel WHERE nome = 'admin_sistema')),
('cn=RH-Gestores,ou=Groups,dc=neeo,dc=com',  'RH-Gestores',  (SELECT id FROM papel WHERE nome = 'gestor_rh')),
('cn=RH-Analistas,ou=Groups,dc=neeo,dc=com', 'RH-Analistas', (SELECT id FROM papel WHERE nome = 'analista_rh')),
('cn=Financeiro,ou=Groups,dc=neeo,dc=com',   'Financeiro',    (SELECT id FROM papel WHERE nome = 'gestor_financeiro')),
('cn=SST,ou=Groups,dc=neeo,dc=com',          'SST',           (SELECT id FROM papel WHERE nome = 'gestor_sst')),
('cn=Auditoria,ou=Groups,dc=neeo,dc=com',    'Auditoria',     (SELECT id FROM papel WHERE nome = 'auditor'));
