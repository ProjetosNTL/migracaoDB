-- ============================================================
-- RBAC (Role-Based Access Control) - ISO 27001 A.8
-- ============================================================
-- Run AFTER create_iso_database.sql
-- This seeds initial roles and permissions based on typical
-- ERP/HR system needs matching the neeo_ntl schemas.
-- ============================================================

-- ==================== ROLES ====================
-- Based on ISO 27001 least-privilege principle

INSERT INTO seguranca.papel (nome, descricao, nivel_acesso) VALUES
('admin_sistema',    'Administrador do sistema. Acesso total.',                    3),
('gestor_rh',        'Gestor RH. Acesso dados funcionario, contratacao, beneficio.', 2),
('analista_rh',      'Analista RH. Consulta dados, sem alterar salario.',          1),
('gestor_financeiro','Gestor financeiro. Acesso faturamento, SCF.',                2),
('analista_financeiro','Analista financeiro. Consulta faturamento.',               1),
('gestor_estoque',   'Gestor estoque. Acesso completo ao estoque.',                2),
('operador_estoque', 'Operador. Consulta e movimentacao.',                         1),
('gestor_sst',       'Gestor SST. Acesso dados saude e seguranca.',                2),
('medico_trabalho',  'Medico. Acesso dados saude (LGPD sensivel).',                2),
('auditor',          'Auditor ISO. Leitura de auditoria e classificacao.',         1),
('viewer',           'Visualizador. Apenas consulta dados nao sensiveis.',         0);

-- ==================== PERMISSIONS ====================
-- Mapped to actual schemas in neeo_ntl

-- Funcionario schema
INSERT INTO seguranca.permissao (recurso, acao, descricao) VALUES
('Funcionario.*',           'SELECT',  'Consultar dados de funcionarios'),
('Funcionario.*',           'INSERT',  'Cadastrar funcionarios'),
('Funcionario.*',           'UPDATE',  'Alterar dados de funcionarios'),
('Funcionario.*',           'DELETE',  'Remover funcionarios'),
('Funcionario.*.salario',   'SELECT',  'Visualizar salario (restrito)'),
('Funcionario.*.cpf',       'UNMASK',  'Ver CPF sem mascara'),

-- Contratacao schema
('Contratacao.*',           'SELECT',  'Consultar contratacoes'),
('Contratacao.*',           'INSERT',  'Criar contratacoes'),
('Contratacao.*',           'UPDATE',  'Alterar contratacoes'),

-- Beneficio schema
('Beneficio.*',             'SELECT',  'Consultar beneficios'),
('Beneficio.*',             'INSERT',  'Cadastrar beneficios'),
('Beneficio.*',             'UPDATE',  'Alterar beneficios'),

-- Faturamento schema
('Faturamento.*',           'SELECT',  'Consultar faturamento'),
('Faturamento.*',           'INSERT',  'Lancar faturamento'),
('Faturamento.*',           'UPDATE',  'Alterar faturamento'),

-- Estoque schema
('Estoque.*',               'SELECT',  'Consultar estoque'),
('Estoque.*',               'INSERT',  'Entrada de estoque'),
('Estoque.*',               'UPDATE',  'Movimentar estoque'),

-- SaudeSegurancaTrabalho schema (LGPD sensitive!)
('SaudeSegurancaTrabalho.*','SELECT',  'Consultar dados SST (sensivel)'),
('SaudeSegurancaTrabalho.*','INSERT',  'Cadastrar dados SST'),
('SaudeSegurancaTrabalho.*','UPDATE',  'Alterar dados SST'),

-- Audit schemas (read-only for auditors)
('auditoria.*',             'SELECT',  'Consultar logs de auditoria'),
('seguranca.*',             'SELECT',  'Consultar configuracoes de seguranca'),

-- Ntl schema (system)
('Ntl.*',                   'SELECT',  'Consultar dados sistema'),
('Ntl.usuario',             'UPDATE',  'Alterar usuarios'),

-- Mensageria
('Mensageria.*',            'SELECT',  'Consultar mensagens'),

-- SAF/SAT
('Saf.*',                   'SELECT',  'Consultar SAF'),
('Sat.*',                   'SELECT',  'Consultar SAT'),
('Solicitacao.*',           'SELECT',  'Consultar solicitacoes'),
('Solicitacao.*',           'INSERT',  'Criar solicitacoes');

-- ==================== ROLE-PERMISSION MAPPING ====================

-- Admin: everything
INSERT INTO seguranca.papel_permissao (papel_id, permissao_id, concedido_por)
SELECT
    (SELECT id FROM seguranca.papel WHERE nome = 'admin_sistema'),
    id,
    'SETUP_INICIAL'
FROM seguranca.permissao;

-- Gestor RH: Funcionario + Contratacao + Beneficio (full) + salary view
INSERT INTO seguranca.papel_permissao (papel_id, permissao_id, concedido_por)
SELECT
    (SELECT id FROM seguranca.papel WHERE nome = 'gestor_rh'),
    id,
    'SETUP_INICIAL'
FROM seguranca.permissao
WHERE recurso LIKE 'Funcionario%'
   OR recurso LIKE 'Contratacao%'
   OR recurso LIKE 'Beneficio%';

-- Analista RH: Funcionario + Contratacao + Beneficio (SELECT only, no salary)
INSERT INTO seguranca.papel_permissao (papel_id, permissao_id, concedido_por)
SELECT
    (SELECT id FROM seguranca.papel WHERE nome = 'analista_rh'),
    id,
    'SETUP_INICIAL'
FROM seguranca.permissao
WHERE (recurso LIKE 'Funcionario%' OR recurso LIKE 'Contratacao%' OR recurso LIKE 'Beneficio%')
  AND acao = 'SELECT'
  AND recurso NOT LIKE '%.salario'
  AND recurso NOT LIKE '%.cpf';

-- Gestor Financeiro: Faturamento + SCF
INSERT INTO seguranca.papel_permissao (papel_id, permissao_id, concedido_por)
SELECT
    (SELECT id FROM seguranca.papel WHERE nome = 'gestor_financeiro'),
    id,
    'SETUP_INICIAL'
FROM seguranca.permissao
WHERE recurso LIKE 'Faturamento%';

-- Gestor SST + Medico: SaudeSegurancaTrabalho
INSERT INTO seguranca.papel_permissao (papel_id, permissao_id, concedido_por)
SELECT
    (SELECT id FROM seguranca.papel WHERE nome = 'gestor_sst'),
    id,
    'SETUP_INICIAL'
FROM seguranca.permissao
WHERE recurso LIKE 'SaudeSegurancaTrabalho%';

INSERT INTO seguranca.papel_permissao (papel_id, permissao_id, concedido_por)
SELECT
    (SELECT id FROM seguranca.papel WHERE nome = 'medico_trabalho'),
    id,
    'SETUP_INICIAL'
FROM seguranca.permissao
WHERE recurso LIKE 'SaudeSegurancaTrabalho%'
  AND acao IN ('SELECT', 'INSERT');

-- Auditor: audit + security schemas (read only)
INSERT INTO seguranca.papel_permissao (papel_id, permissao_id, concedido_por)
SELECT
    (SELECT id FROM seguranca.papel WHERE nome = 'auditor'),
    id,
    'SETUP_INICIAL'
FROM seguranca.permissao
WHERE recurso LIKE 'auditoria%'
   OR recurso LIKE 'seguranca%';

-- Estoque roles
INSERT INTO seguranca.papel_permissao (papel_id, permissao_id, concedido_por)
SELECT
    (SELECT id FROM seguranca.papel WHERE nome = 'gestor_estoque'),
    id,
    'SETUP_INICIAL'
FROM seguranca.permissao
WHERE recurso LIKE 'Estoque%';

INSERT INTO seguranca.papel_permissao (papel_id, permissao_id, concedido_por)
SELECT
    (SELECT id FROM seguranca.papel WHERE nome = 'operador_estoque'),
    id,
    'SETUP_INICIAL'
FROM seguranca.permissao
WHERE recurso LIKE 'Estoque%'
  AND acao IN ('SELECT', 'INSERT');

PRINT 'RBAC tables seeded successfully.';
PRINT 'Next: assign users to roles via seguranca.usuario_papel';
