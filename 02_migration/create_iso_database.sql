-- ============================================================
-- ISO 27001 Compliant Database Structure
-- Migration template: neeo_ntl -> neeo_ntl_iso
-- ============================================================
-- REVISAR ANTES DE EXECUTAR
-- This is a TEMPLATE showing the target state.
-- Adapt table/column names based on discovery results.
-- ============================================================

-- 1. Create new database (DBA executes this)
-- CREATE DATABASE neeo_ntl_iso;
-- GO
-- USE neeo_ntl_iso;
-- GO

-- ============================================================
-- SECTION 1: RBAC Tables (ISO A.8 - Access Control)
-- ============================================================

CREATE SCHEMA seguranca;
GO

-- Roles table
CREATE TABLE seguranca.papel (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nome NVARCHAR(100) NOT NULL UNIQUE,
    descricao NVARCHAR(500),
    nivel_acesso INT NOT NULL DEFAULT 0,  -- 0=viewer, 1=operator, 2=manager, 3=admin
    ativo BIT NOT NULL DEFAULT 1,
    criado_em DATETIME2 NOT NULL DEFAULT GETDATE(),
    atualizado_em DATETIME2 NOT NULL DEFAULT GETDATE()
);

-- Permissions table
CREATE TABLE seguranca.permissao (
    id INT IDENTITY(1,1) PRIMARY KEY,
    recurso NVARCHAR(200) NOT NULL,       -- schema.table or feature name
    acao NVARCHAR(50) NOT NULL,           -- SELECT, INSERT, UPDATE, DELETE, EXECUTE
    descricao NVARCHAR(500),
    criado_em DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_permissao_recurso_acao UNIQUE (recurso, acao)
);

-- Role-Permission mapping (many-to-many)
CREATE TABLE seguranca.papel_permissao (
    papel_id INT NOT NULL REFERENCES seguranca.papel(id),
    permissao_id INT NOT NULL REFERENCES seguranca.permissao(id),
    concedido_por NVARCHAR(100),
    concedido_em DATETIME2 NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (papel_id, permissao_id)
);

-- User-Role mapping (many-to-many)
CREATE TABLE seguranca.usuario_papel (
    usuario_id INT NOT NULL,              -- FK to ntl.usuario
    papel_id INT NOT NULL REFERENCES seguranca.papel(id),
    atribuido_por NVARCHAR(100),
    atribuido_em DATETIME2 NOT NULL DEFAULT GETDATE(),
    valido_ate DATETIME2 NULL,            -- optional expiration (ISO: periodic review)
    PRIMARY KEY (usuario_id, papel_id)
);

-- ============================================================
-- SECTION 2: Audit Log Tables (ISO A.8.15 - Logging)
-- ============================================================

CREATE SCHEMA auditoria;
GO

-- Main audit log - tracks all data changes
CREATE TABLE auditoria.log_alteracao (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    data_hora DATETIME2 NOT NULL DEFAULT GETDATE(),
    usuario NVARCHAR(100) NOT NULL DEFAULT SYSTEM_USER,
    ip_origem NVARCHAR(50),
    schema_nome NVARCHAR(100) NOT NULL,
    tabela_nome NVARCHAR(100) NOT NULL,
    operacao NVARCHAR(10) NOT NULL,       -- INSERT, UPDATE, DELETE
    registro_id NVARCHAR(100),            -- PK of affected row
    dados_anteriores NVARCHAR(MAX),       -- JSON of old values
    dados_novos NVARCHAR(MAX),            -- JSON of new values
    aplicacao NVARCHAR(100) DEFAULT APP_NAME()
);

-- Access audit - tracks who queried sensitive data
CREATE TABLE auditoria.log_acesso (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    data_hora DATETIME2 NOT NULL DEFAULT GETDATE(),
    usuario NVARCHAR(100) NOT NULL DEFAULT SYSTEM_USER,
    ip_origem NVARCHAR(50),
    schema_nome NVARCHAR(100),
    tabela_nome NVARCHAR(100),
    tipo_acesso NVARCHAR(50),             -- SELECT, EXPORT, REPORT
    qtd_registros INT,
    filtros_usados NVARCHAR(MAX),
    aplicacao NVARCHAR(100) DEFAULT APP_NAME()
);

-- Login audit - tracks authentication attempts
CREATE TABLE auditoria.log_autenticacao (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    data_hora DATETIME2 NOT NULL DEFAULT GETDATE(),
    usuario NVARCHAR(100) NOT NULL,
    ip_origem NVARCHAR(50),
    resultado NVARCHAR(20) NOT NULL,      -- SUCESSO, FALHA, BLOQUEADO
    motivo_falha NVARCHAR(200),
    user_agent NVARCHAR(500)
);

-- Index for performance on audit queries
CREATE INDEX IX_log_alteracao_data ON auditoria.log_alteracao(data_hora);
CREATE INDEX IX_log_alteracao_usuario ON auditoria.log_alteracao(usuario);
CREATE INDEX IX_log_alteracao_tabela ON auditoria.log_alteracao(schema_nome, tabela_nome);
CREATE INDEX IX_log_acesso_data ON auditoria.log_acesso(data_hora);
CREATE INDEX IX_log_autenticacao_data ON auditoria.log_autenticacao(data_hora);
CREATE INDEX IX_log_autenticacao_usuario ON auditoria.log_autenticacao(usuario);

-- ============================================================
-- SECTION 3: Password Policy Table (ISO A.5.17)
-- ============================================================

CREATE TABLE seguranca.politica_senha (
    id INT IDENTITY(1,1) PRIMARY KEY,
    usuario_id INT NOT NULL,
    senha_hash NVARCHAR(500) NOT NULL,    -- bcrypt/argon2 hash (NOT MD5!)
    algoritmo NVARCHAR(50) NOT NULL DEFAULT 'bcrypt',
    criado_em DATETIME2 NOT NULL DEFAULT GETDATE(),
    expira_em DATETIME2 NOT NULL,         -- force rotation
    tentativas_falha INT NOT NULL DEFAULT 0,
    bloqueado_ate DATETIME2 NULL,
    ultimo_login DATETIME2,
    senha_anterior1 NVARCHAR(500),        -- prevent reuse
    senha_anterior2 NVARCHAR(500),
    senha_anterior3 NVARCHAR(500)
);

-- ============================================================
-- SECTION 4: Data Classification (ISO A.5.12 - Information Classification)
-- ============================================================

CREATE TABLE seguranca.classificacao_dados (
    id INT IDENTITY(1,1) PRIMARY KEY,
    schema_nome NVARCHAR(100) NOT NULL,
    tabela_nome NVARCHAR(100) NOT NULL,
    coluna_nome NVARCHAR(100) NOT NULL,
    classificacao NVARCHAR(50) NOT NULL,   -- PUBLICO, INTERNO, CONFIDENCIAL, RESTRITO, CRITICO
    tipo_dado_pessoal NVARCHAR(50),        -- PII, SENSIVEL_LGPD, FINANCEIRO, NULL
    base_legal_lgpd NVARCHAR(200),         -- legal basis for processing
    responsavel NVARCHAR(200),             -- data owner
    periodo_retencao NVARCHAR(100),        -- how long to keep
    observacao NVARCHAR(500),
    criado_em DATETIME2 NOT NULL DEFAULT GETDATE(),
    atualizado_em DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_classificacao UNIQUE (schema_nome, tabela_nome, coluna_nome)
);

-- ============================================================
-- SECTION 5: User table improvements (migrate from ntl.usuario)
-- ============================================================

-- Example: improved user table structure
-- CREATE TABLE seguranca.usuario (
--     id INT IDENTITY(1,1) PRIMARY KEY,
--     login NVARCHAR(100) NOT NULL UNIQUE,
--     nome NVARCHAR(200) NOT NULL,
--     email NVARCHAR(200) NOT NULL,
--     ativo BIT NOT NULL DEFAULT 1,
--     criado_em DATETIME2 NOT NULL DEFAULT GETDATE(),
--     atualizado_em DATETIME2 NOT NULL DEFAULT GETDATE(),
--     -- NOTE: password NOT stored here. See seguranca.politica_senha
--     -- NOTE: CPF/sensitive data masked via Dynamic Data Masking
-- );

PRINT 'ISO 27001 database structure created successfully.';
PRINT 'Next steps:';
PRINT '  1. Review and adapt table names to match your system';
PRINT '  2. Run 03_rbac scripts to seed initial roles';
PRINT '  3. Run 04_audit scripts to create triggers';
PRINT '  4. Migrate data using 02_migration/migrate_data.py';
