# NTL - Auditoria e Adequacao ISO 27001

Projeto de auditoria e migracao do banco de dados `neeo_ntl` (SQL Server -> MySQL) para adequacao a **ISO 27001** e **LGPD**. Inclui scripts de descoberta, classificacao de dados sensiveis, proposta de RBAC (controle de acesso baseado em papeis), auditoria, mascaramento de dados e conformidade LGPD.

**Fluxo de migracao:** SQL Server (legado) -> MySQL (novo banco ISO/LGPD compliant)

## Estrutura do Projeto

```
ntl/
├── .env                              # Credenciais do banco (NAO versionar)
├── .gitignore
├── requirements.txt
├── columns_check.py                  # Scanner de colunas sensiveis + gerador de masking SQL
├── script_masking.sql                # Script SQL de Dynamic Data Masking (gerado)
├── utils/
│   ├── __init__.py
│   └── db_connection.py              # Modulo compartilhado de conexao com o banco
├── 01_discovery/
│   └── map_schemas.py                # Mapeamento completo do banco (schemas, tabelas, colunas, FKs)
├── 02_migration/
│   ├── create_iso_database.sql       # Estrutura SQL para banco compativel com ISO 27001
│   └── migrate_data.py              # Analise de senhas, dados sensiveis e relatorio de migracao
├── 03_rbac/
│   └── rbac_tables.sql              # Papeis, permissoes e mapeamento papel-permissao
├── 04_audit/
│   └── audit_triggers.sql           # Triggers de auditoria para rastreamento de alteracoes
├── 05_demo/
│   └── demo_iso_sqlite.py           # Prova de conceito local com SQLite (RBAC + audit + masking)
├── 06_lgpd/
│   ├── create_mysql_iso_database.sql # Banco MySQL completo: RBAC + audit + LGPD tables
│   └── classify_lgpd.py             # Classificacao LGPD automatica das colunas do SQL Server
└── 07_ldap/
    ├── ldap_integration.sql         # Tabelas MySQL para integracao LDAP
    ├── ldap_sync.py                 # Engine de sincronizacao LDAP -> MySQL
    └── ldap_example_config/
        └── base.ldif                # Estrutura LDAP exemplo (OpenLDAP)
```

## Pre-requisitos

- Python 3.10+
- Acesso ao banco SQL Server `neeo_ntl`
- DBeaver ou outro client SQL (opcional, para visualizacao)

## Instalacao

```bash
# Criar e ativar ambiente virtual
python -m venv .venv
.venv\Scripts\activate        # Windows
# source .venv/bin/activate   # Linux/Mac

# Instalar dependencias
pip install -r requirements.txt
```

## Configuracao

Criar arquivo `.env` na raiz do projeto com as credenciais do banco:

```env
# SQL Server (fonte - legado)
DB_SERVER=endereco_do_servidor
DB_NAME=neeo_ntl
DB_USER=seu_usuario
DB_PASSWORD=sua_senha

# MySQL (destino - novo banco ISO/LGPD)
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=sua_senha_mysql
MYSQL_DATABASE=neeo_ntl_iso
```

**IMPORTANTE:** O `.env` ja esta no `.gitignore`. Nunca versione credenciais.

## Como Usar

### Ordem de Execucao Recomendada

Todos os scripts Python sao **somente leitura** — nenhum modifica dados no banco de producao.

#### 1. Descoberta do Banco (`01_discovery/`)

Mapeia toda a estrutura do banco e gera CSVs com o dicionario de dados completo.

```bash
python 01_discovery/map_schemas.py
```

**Saida gerada:**
- `data_dictionary_tables_YYYYMMDD_HHMM.csv` — Todas as tabelas com contagem de registros
- `data_dictionary_columns_YYYYMMDD_HHMM.csv` — Todas as colunas com tipos de dados
- `data_dictionary_relationships_YYYYMMDD_HHMM.csv` — Chaves estrangeiras (relacionamentos)

#### 2. Scanner de Colunas Sensiveis (`columns_check.py`)

Identifica colunas com dados sensiveis (CPF, email, senha, salario, etc.) e gera script de mascaramento.

```bash
python columns_check.py
```

**Saida gerada:**
- `inventario_dados_sensiveis_YYYYMMDD.csv` — Inventario de colunas sensiveis com classificacao
- `script_masking.sql` — Script SQL de Dynamic Data Masking pronto para revisao

#### 3. Analise de Migracao (`02_migration/`)

Analisa senhas (detecta MD5, senhas padrao), classifica dados sensiveis e gera relatorio para a equipe ISO.

```bash
python 02_migration/migrate_data.py
```

**Saida gerada:**
- `relatorio_migracao_iso27001_YYYYMMDD_HHMM.csv` — Relatorio completo com achados e acoes

#### 4. Demo Local (`05_demo/`)

Prova de conceito que demonstra RBAC, auditoria e mascaramento funcionando em SQLite local. Nao precisa de conexao com SQL Server.

```bash
python 05_demo/demo_iso_sqlite.py
```

**O que demonstra:**
- Mesmo SELECT retorna dados diferentes conforme o papel do usuario
- Mascaramento de CPF, email e salario por nivel de acesso
- Bloqueio de conta apos 5 tentativas de login
- Log de auditoria de acessos e autenticacao
- Comparacao sistema atual (MD5, sem controle) vs sistema proposto

**Saida:** Banco `05_demo/demo_iso27001.db` — abra no DBeaver para inspecionar.

#### 5. Classificacao LGPD (`06_lgpd/`)

Classifica automaticamente todas as colunas do SQL Server com base legal LGPD (Art. 7) e gera INSERTs para MySQL.

```bash
python 06_lgpd/classify_lgpd.py
```

**Saida gerada:**
- `lgpd_classificacao_YYYYMMDD_HHMM.csv` — Classificacao completa de colunas com base legal
- `lgpd_inserts_mysql_YYYYMMDD_HHMM.sql` — INSERTs prontos para carregar no MySQL

#### 6. Criar Banco MySQL (DBA)

Executar no MySQL para criar o banco de destino com todas as tabelas ISO + LGPD:

```bash
mysql -u root -p < 06_lgpd/create_mysql_iso_database.sql
```

#### 7. Scripts SQL Legados (SQL Server)

Estes arquivos SQL sao **propostas** para o DBA (referencia SQL Server, antes da migracao):

| Arquivo | Descricao |
|---------|-----------|
| `02_migration/create_iso_database.sql` | Estrutura SQL Server: schemas `seguranca` e `auditoria` (referencia) |
| `03_rbac/rbac_tables.sql` | Papeis e permissoes (SQL Server syntax - adaptar para MySQL) |
| `04_audit/audit_triggers.sql` | Triggers SQL Server (referencia - MySQL version em `06_lgpd/`) |
| `script_masking.sql` | Dynamic Data Masking SQL Server (MySQL usa views - ver `06_lgpd/`) |
| **`06_lgpd/create_mysql_iso_database.sql`** | **PRINCIPAL: Banco MySQL completo com RBAC + audit + LGPD** |

## Problemas Encontrados

### Criticos (P0)

1. **Senhas em MD5** — Todas as senhas em `ntl.usuario` usam MD5 (quebrado). Muitos usuarios com senha padrao `123`
2. **Sem controle de acesso** — Nao existe tabela de papeis/permissoes. Qualquer usuario acessa tudo
3. **Senhas compartilhadas** — Multiplos usuarios com a mesma senha

### Importantes (P1)

4. **Sem auditoria** — Nao ha registro de quem acessou ou alterou dados
5. **Dados sensiveis expostos** — CPF, salario, dados de saude visiveis para qualquer usuario com acesso ao banco
6. **Sem mascaramento** — Dynamic Data Masking nao esta habilitado

## Controles ISO 27001 + LGPD Cobertos

| Controle | Descricao | Status |
|----------|-----------|--------|
| A.5.12 | Classificacao da informacao | Implementado (inventario + classificacao) |
| A.5.17 | Informacao de autenticacao | Proposta (migracao MD5 -> bcrypt) |
| A.8.2 | Gestao de acesso privilegiado | Proposta (RBAC) |
| A.8.3 | Restricao de acesso | Proposta (RBAC + views mascaradas) |
| A.8.5 | Autenticacao segura | Proposta (politica de senha + bloqueio) |
| A.8.11 | Mascaramento de dados | Proposta (views MySQL + grants) |
| A.8.15 | Log de eventos | Proposta (triggers de auditoria MySQL) |
| A.8.24 | Uso de criptografia | Pendente (encryption at rest) |

| LGPD | Descricao | Status |
|------|-----------|--------|
| Art. 7 | Base legal para tratamento | Implementado (classify_lgpd.py) |
| Art. 8 | Consentimento | Proposta (tabela lgpd_consentimento) |
| Art. 16 | Retencao de dados | Proposta (tabela lgpd_retencao) |
| Art. 18 | Direitos do titular | Proposta (tabela lgpd_solicitacao) |
| Art. 46 | Seguranca dos dados | Proposta (RBAC + audit + masking) |
| Art. 48 | Incidentes de seguranca | Proposta (tabela lgpd_incidente) |

## Permissoes Necessarias no SQL Server

Para executar os scripts Python de descoberta:

```sql
GRANT VIEW DEFINITION TO [usuario];
GRANT VIEW DATABASE STATE TO [usuario];
-- Para Dynamic Data Masking:
GRANT ALTER ANY MASK TO [usuario];
-- Para criar schemas/tabelas:
GRANT CREATE SCHEMA TO [usuario];
GRANT CREATE TABLE TO [usuario];
```

## Proximos Passos

### Migracao SQL Server -> MySQL
- [ ] Instalar MySQL local
- [ ] Executar `06_lgpd/create_mysql_iso_database.sql` para criar banco destino
- [ ] Rodar `06_lgpd/classify_lgpd.py` para gerar INSERTs LGPD
- [ ] Carregar INSERTs gerados no MySQL
- [ ] Migrar dados de producao (com anonimizacao de dados sensiveis)

### ISO 27001
- [ ] DBA revisar e aplicar RBAC (tabelas ja criadas no MySQL)
- [ ] Configurar triggers de auditoria nas tabelas sensiveis
- [ ] Equipe de desenvolvimento migrar senhas de MD5 para bcrypt
- [ ] Forcar reset de senha para todos os usuarios
- [ ] Implementar politica de senha na aplicacao
- [ ] Criar views mascaradas e configurar GRANTs por papel
- [ ] Agendar revisao periodica de acessos (ISO A.8.2)

### LGPD
- [ ] Validar base legal de cada coluna (output do classify_lgpd.py)
- [ ] Definir encarregado (DPO) e responsaveis por schema
- [ ] Implementar fluxo de solicitacoes do titular (Art. 18)
- [ ] Configurar politica de retencao e purga automatica
- [ ] Documentar RIPD (Relatorio de Impacto - Art. 38)
- [ ] Treinar equipe sobre procedimento de incidentes (Art. 48)

### LDAP (Centralizacao de Autenticacao)
- [ ] Escolher solucao: Active Directory / OpenLDAP / Keycloak
- [ ] Instalar e configurar servidor LDAP
- [ ] Criar estrutura de OUs e grupos (ver `07_ldap/ldap_example_config/`)
- [ ] Executar `07_ldap/ldap_integration.sql` no MySQL
- [ ] Configurar tabela `config_ldap` com dados do servidor
- [ ] Mapear grupos LDAP para papeis na tabela `ldap_grupo_papel`
- [ ] Adaptar aplicacoes para autenticar via LDAP (remover login local)
- [ ] Rodar primeira sincronizacao: `python 07_ldap/ldap_sync.py --full`
- [ ] Agendar sync automatico a cada 30min (cron/task scheduler)
- [ ] Remover coluna `senha` das tabelas de usuario dos sistemas legados
