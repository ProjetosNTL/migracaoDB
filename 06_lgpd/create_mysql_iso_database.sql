-- ============================================================
-- MySQL Database Structure - ISO 27001 + LGPD Compliant
-- Migration target: SQL Server (neeo_ntl) -> MySQL (neeo_ntl_iso)
-- ============================================================
-- REVISAR ANTES DE EXECUTAR
-- ============================================================

CREATE DATABASE IF NOT EXISTS neeo_ntl_iso
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE neeo_ntl_iso;

-- ============================================================
-- SECTION 1: RBAC (ISO A.8 - Access Control)
-- ============================================================

CREATE TABLE IF NOT EXISTS papel (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao VARCHAR(500),
    nivel_acesso INT NOT NULL DEFAULT 0 COMMENT '0=viewer, 1=operator, 2=manager, 3=admin',
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='Papeis do sistema (RBAC) - ISO A.8.2';

CREATE TABLE IF NOT EXISTS permissao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    recurso VARCHAR(200) NOT NULL COMMENT 'tabela ou funcionalidade',
    acao VARCHAR(50) NOT NULL COMMENT 'SELECT, INSERT, UPDATE, DELETE, UNMASK',
    descricao VARCHAR(500),
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_permissao (recurso, acao)
) ENGINE=InnoDB COMMENT='Permissoes granulares - ISO A.8.2';

CREATE TABLE IF NOT EXISTS papel_permissao (
    papel_id INT NOT NULL,
    permissao_id INT NOT NULL,
    concedido_por VARCHAR(100),
    concedido_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (papel_id, permissao_id),
    FOREIGN KEY (papel_id) REFERENCES papel(id) ON DELETE CASCADE,
    FOREIGN KEY (permissao_id) REFERENCES permissao(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Mapeamento papel-permissao - ISO A.8.2';

CREATE TABLE IF NOT EXISTS usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    login VARCHAR(100) NOT NULL UNIQUE,
    nome VARCHAR(200) NOT NULL,
    email VARCHAR(200) NOT NULL,
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    -- NOTA: senha NAO fica aqui. Ver tabela politica_senha
    -- NOTA: CPF e dados sensiveis com acesso controlado via views
) ENGINE=InnoDB COMMENT='Usuarios do sistema - ISO A.8.2';

CREATE TABLE IF NOT EXISTS usuario_papel (
    usuario_id INT NOT NULL,
    papel_id INT NOT NULL,
    atribuido_por VARCHAR(100),
    atribuido_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valido_ate DATETIME NULL COMMENT 'Expiracao para revisao periodica - ISO A.8.2',
    PRIMARY KEY (usuario_id, papel_id),
    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
    FOREIGN KEY (papel_id) REFERENCES papel(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Mapeamento usuario-papel - ISO A.8.2';

-- ============================================================
-- SECTION 2: Password Policy (ISO A.5.17)
-- ============================================================

CREATE TABLE IF NOT EXISTS politica_senha (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    senha_hash VARCHAR(500) NOT NULL COMMENT 'bcrypt hash ONLY. NUNCA MD5/SHA1',
    algoritmo VARCHAR(50) NOT NULL DEFAULT 'bcrypt',
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expira_em DATETIME NOT NULL COMMENT 'Rotacao obrigatoria',
    tentativas_falha INT NOT NULL DEFAULT 0,
    bloqueado_ate DATETIME NULL,
    ultimo_login DATETIME NULL,
    senha_anterior1 VARCHAR(500) COMMENT 'Impedir reutilizacao',
    senha_anterior2 VARCHAR(500),
    senha_anterior3 VARCHAR(500),
    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
    INDEX idx_politica_usuario (usuario_id)
) ENGINE=InnoDB COMMENT='Politica de senha - ISO A.5.17';

-- ============================================================
-- SECTION 3: Audit Logs (ISO A.8.15)
-- ============================================================

CREATE TABLE IF NOT EXISTS log_alteracao (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(100) NOT NULL,
    ip_origem VARCHAR(50),
    tabela_nome VARCHAR(100) NOT NULL,
    operacao ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    registro_id VARCHAR(100) COMMENT 'PK do registro afetado',
    dados_anteriores JSON COMMENT 'Valores antes da alteracao',
    dados_novos JSON COMMENT 'Valores apos a alteracao',
    aplicacao VARCHAR(100),
    INDEX idx_log_data (data_hora),
    INDEX idx_log_usuario (usuario),
    INDEX idx_log_tabela (tabela_nome)
) ENGINE=InnoDB COMMENT='Log de alteracoes - ISO A.8.15';

CREATE TABLE IF NOT EXISTS log_acesso (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(100) NOT NULL,
    ip_origem VARCHAR(50),
    tabela_nome VARCHAR(100),
    tipo_acesso VARCHAR(50) COMMENT 'SELECT, EXPORT, REPORT',
    qtd_registros INT,
    filtros_usados TEXT,
    aplicacao VARCHAR(100),
    INDEX idx_acesso_data (data_hora),
    INDEX idx_acesso_usuario (usuario)
) ENGINE=InnoDB COMMENT='Log de acesso a dados - ISO A.8.15';

CREATE TABLE IF NOT EXISTS log_autenticacao (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(100) NOT NULL,
    ip_origem VARCHAR(50),
    resultado ENUM('SUCESSO', 'FALHA', 'BLOQUEADO') NOT NULL,
    motivo_falha VARCHAR(200),
    user_agent VARCHAR(500),
    INDEX idx_auth_data (data_hora),
    INDEX idx_auth_usuario (usuario)
) ENGINE=InnoDB COMMENT='Log de autenticacao - ISO A.8.15';

-- ============================================================
-- SECTION 4: Data Classification (ISO A.5.12)
-- ============================================================

CREATE TABLE IF NOT EXISTS classificacao_dados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tabela_nome VARCHAR(100) NOT NULL,
    coluna_nome VARCHAR(100) NOT NULL,
    classificacao ENUM('PUBLICO', 'INTERNO', 'CONFIDENCIAL', 'RESTRITO', 'CRITICO') NOT NULL,
    tipo_dado_pessoal VARCHAR(50) COMMENT 'PII, SENSIVEL_LGPD, FINANCEIRO, NULL',
    base_legal_lgpd VARCHAR(200) COMMENT 'Base legal para tratamento - LGPD Art.7',
    responsavel VARCHAR(200) COMMENT 'Data owner',
    periodo_retencao_dias INT COMMENT 'Dias para reter antes de purgar',
    mascara_aplicada VARCHAR(100) COMMENT 'Tipo de mascaramento',
    observacao VARCHAR(500),
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_classificacao (tabela_nome, coluna_nome)
) ENGINE=InnoDB COMMENT='Classificacao de dados - ISO A.5.12 + LGPD';

-- ============================================================
-- SECTION 5: LGPD Tables
-- ============================================================

-- Base legal por tabela/coluna (LGPD Art. 7)
CREATE TABLE IF NOT EXISTS lgpd_base_legal (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tabela_nome VARCHAR(100) NOT NULL,
    coluna_nome VARCHAR(100) NOT NULL,
    base_legal ENUM(
        'CONSENTIMENTO',
        'OBRIGACAO_LEGAL',
        'EXECUCAO_CONTRATO',
        'INTERESSE_LEGITIMO',
        'PROTECAO_VIDA',
        'TUTELA_SAUDE',
        'EXERCICIO_DIREITOS',
        'PESQUISA',
        'CREDITO',
        'PREVENCAO_FRAUDE'
    ) NOT NULL COMMENT 'LGPD Art. 7',
    finalidade VARCHAR(500) NOT NULL COMMENT 'Para que este dado e tratado',
    periodo_retencao_dias INT NOT NULL COMMENT 'Quanto tempo manter',
    responsavel VARCHAR(200) NOT NULL COMMENT 'Quem responde por este dado',
    observacao VARCHAR(500),
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_base_legal (tabela_nome, coluna_nome)
) ENGINE=InnoDB COMMENT='Base legal por dado pessoal - LGPD Art. 7';

-- Consentimento do titular (LGPD Art. 8)
CREATE TABLE IF NOT EXISTS lgpd_consentimento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titular_id INT NOT NULL COMMENT 'ID da pessoa (funcionario, candidato, etc)',
    titular_tipo VARCHAR(50) NOT NULL COMMENT 'funcionario, candidato, fornecedor',
    finalidade VARCHAR(500) NOT NULL COMMENT 'Para que consentiu',
    consentido_em DATETIME NOT NULL,
    revogado_em DATETIME NULL,
    canal VARCHAR(100) NOT NULL COMMENT 'app, web, papel, email',
    evidencia TEXT COMMENT 'Link ou descricao do comprovante',
    ip_origem VARCHAR(50),
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_consent_titular (titular_id, titular_tipo),
    INDEX idx_consent_data (consentido_em)
) ENGINE=InnoDB COMMENT='Registro de consentimento - LGPD Art. 8';

-- Solicitacoes do titular (LGPD Art. 18)
CREATE TABLE IF NOT EXISTS lgpd_solicitacao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titular_id INT NOT NULL,
    titular_tipo VARCHAR(50) NOT NULL,
    titular_nome VARCHAR(200) NOT NULL,
    titular_email VARCHAR(200) NOT NULL,
    tipo_solicitacao ENUM(
        'ACESSO',
        'CORRECAO',
        'ANONIMIZACAO',
        'EXCLUSAO',
        'PORTABILIDADE',
        'REVOGACAO_CONSENTIMENTO',
        'INFORMACAO_COMPARTILHAMENTO',
        'OPOSICAO'
    ) NOT NULL COMMENT 'LGPD Art. 18',
    descricao TEXT,
    status ENUM('RECEBIDA', 'EM_ANALISE', 'ATENDIDA', 'NEGADA', 'CANCELADA') NOT NULL DEFAULT 'RECEBIDA',
    prazo_resposta DATE NOT NULL COMMENT '15 dias uteis - LGPD Art. 18 §5',
    respondido_em DATETIME NULL,
    resposta TEXT,
    responsavel VARCHAR(200),
    motivo_negativa VARCHAR(500) COMMENT 'Se negada, justificativa obrigatoria',
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_solic_titular (titular_id, titular_tipo),
    INDEX idx_solic_status (status),
    INDEX idx_solic_prazo (prazo_resposta)
) ENGINE=InnoDB COMMENT='Solicitacoes do titular - LGPD Art. 18';

-- Politica de retencao e purga automatica
CREATE TABLE IF NOT EXISTS lgpd_retencao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tabela_nome VARCHAR(100) NOT NULL,
    coluna_data_referencia VARCHAR(100) NOT NULL COMMENT 'Coluna de data para calcular retencao',
    periodo_dias INT NOT NULL,
    acao_pos_retencao ENUM('ANONIMIZAR', 'EXCLUIR', 'ARQUIVAR') NOT NULL DEFAULT 'ANONIMIZAR',
    ultima_purga DATETIME NULL,
    proxima_purga DATETIME NULL,
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_retencao (tabela_nome)
) ENGINE=InnoDB COMMENT='Politica de retencao de dados - LGPD Art. 16';

-- Registro de incidentes de seguranca (LGPD Art. 48)
CREATE TABLE IF NOT EXISTS lgpd_incidente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    data_ocorrencia DATETIME NOT NULL,
    data_deteccao DATETIME NOT NULL,
    descricao TEXT NOT NULL,
    dados_afetados TEXT NOT NULL COMMENT 'Tipos de dados comprometidos',
    titulares_afetados INT COMMENT 'Qtd estimada de pessoas afetadas',
    risco_relevante TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Se sim, comunicar ANPD',
    comunicado_anpd TINYINT(1) NOT NULL DEFAULT 0,
    comunicado_anpd_em DATETIME NULL,
    comunicado_titulares TINYINT(1) NOT NULL DEFAULT 0,
    comunicado_titulares_em DATETIME NULL,
    medidas_adotadas TEXT,
    responsavel VARCHAR(200),
    status ENUM('ABERTO', 'EM_ANALISE', 'COMUNICADO', 'ENCERRADO') NOT NULL DEFAULT 'ABERTO',
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='Registro de incidentes - LGPD Art. 48';

-- ============================================================
-- SECTION 6: Audit Triggers (MySQL syntax)
-- ============================================================

-- Template trigger for usuario table
DELIMITER //

CREATE TRIGGER tr_usuario_after_insert
AFTER INSERT ON usuario
FOR EACH ROW
BEGIN
    INSERT INTO log_alteracao (usuario, tabela_nome, operacao, registro_id, dados_novos)
    VALUES (
        COALESCE(@app_user, USER()),
        'usuario',
        'INSERT',
        NEW.id,
        JSON_OBJECT('login', NEW.login, 'nome', NEW.nome, 'email', NEW.email, 'ativo', NEW.ativo)
    );
END //

CREATE TRIGGER tr_usuario_after_update
AFTER UPDATE ON usuario
FOR EACH ROW
BEGIN
    INSERT INTO log_alteracao (usuario, tabela_nome, operacao, registro_id, dados_anteriores, dados_novos)
    VALUES (
        COALESCE(@app_user, USER()),
        'usuario',
        'UPDATE',
        NEW.id,
        JSON_OBJECT('login', OLD.login, 'nome', OLD.nome, 'email', OLD.email, 'ativo', OLD.ativo),
        JSON_OBJECT('login', NEW.login, 'nome', NEW.nome, 'email', NEW.email, 'ativo', NEW.ativo)
    );
END //

CREATE TRIGGER tr_usuario_after_delete
AFTER DELETE ON usuario
FOR EACH ROW
BEGIN
    INSERT INTO log_alteracao (usuario, tabela_nome, operacao, registro_id, dados_anteriores)
    VALUES (
        COALESCE(@app_user, USER()),
        'usuario',
        'DELETE',
        OLD.id,
        JSON_OBJECT('login', OLD.login, 'nome', OLD.nome, 'email', OLD.email, 'ativo', OLD.ativo)
    );
END //

DELIMITER ;

-- ============================================================
-- SECTION 7: Views with Masking (MySQL alternative to Dynamic Data Masking)
-- ============================================================
-- MySQL Community nao tem Dynamic Data Masking nativo.
-- Alternativa: views que mascaram dados + controle via GRANT.

-- View para usuarios sem permissao de ver dados sensiveis
CREATE OR REPLACE VIEW vw_funcionario_masked AS
SELECT
    id,
    nome,
    CONCAT(LEFT(cpf, 3), '.***.***-', RIGHT(cpf, 2)) AS cpf,
    CONCAT(LEFT(email, 1), '***@***.com') AS email,
    CONCAT(LEFT(telefone, 4), '****-****') AS telefone,
    0.00 AS salario,
    departamento,
    ativo
FROM funcionario;

-- View para gestores RH (dados reais)
CREATE OR REPLACE VIEW vw_funcionario_rh AS
SELECT * FROM funcionario;

-- Controle de acesso via GRANT:
-- GRANT SELECT ON neeo_ntl_iso.vw_funcionario_masked TO 'analista'@'%';
-- GRANT SELECT ON neeo_ntl_iso.vw_funcionario_rh TO 'gestor_rh'@'%';
-- REVOKE SELECT ON neeo_ntl_iso.funcionario FROM 'analista'@'%';
