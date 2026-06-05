# NTL - Auditoria e Adequacao ISO 27001

Projeto de auditoria do banco de dados `neeo_ntl` (SQL Server) para adequacao a **ISO 27001** e **LGPD**. Inclui scripts de descoberta, classificacao de dados sensiveis, proposta de RBAC (controle de acesso baseado em papeis), auditoria e mascaramento de dados.

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
└── 05_demo/
    └── demo_iso_sqlite.py           # Prova de conceito local com SQLite (RBAC + audit + masking)
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
DB_SERVER=endereco_do_servidor
DB_NAME=neeo_ntl
DB_USER=seu_usuario
DB_PASSWORD=sua_senha
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

#### 5. Scripts SQL para o DBA

Estes arquivos SQL sao **propostas** para o DBA revisar e executar no SQL Server:

| Arquivo | Descricao |
|---------|-----------|
| `02_migration/create_iso_database.sql` | Estrutura completa: schemas `seguranca` e `auditoria`, tabelas RBAC, logs, classificacao |
| `03_rbac/rbac_tables.sql` | Papeis iniciais (admin, gestor_rh, analista, auditor, etc.) e mapeamento de permissoes |
| `04_audit/audit_triggers.sql` | Template de trigger para log automatico de INSERT/UPDATE/DELETE |
| `script_masking.sql` | Dynamic Data Masking por coluna (gerado pelo `columns_check.py`) |

## Problemas Encontrados

### Criticos (P0)

1. **Senhas em MD5** — Todas as senhas em `ntl.usuario` usam MD5 (quebrado). Muitos usuarios com senha padrao `123`
2. **Sem controle de acesso** — Nao existe tabela de papeis/permissoes. Qualquer usuario acessa tudo
3. **Senhas compartilhadas** — Multiplos usuarios com a mesma senha

### Importantes (P1)

4. **Sem auditoria** — Nao ha registro de quem acessou ou alterou dados
5. **Dados sensiveis expostos** — CPF, salario, dados de saude visiveis para qualquer usuario com acesso ao banco
6. **Sem mascaramento** — Dynamic Data Masking nao esta habilitado

## Controles ISO 27001 Cobertos

| Controle | Descricao | Status |
|----------|-----------|--------|
| A.5.12 | Classificacao da informacao | Implementado (inventario + classificacao) |
| A.5.17 | Informacao de autenticacao | Proposta (migracao MD5 -> bcrypt) |
| A.8.2 | Gestao de acesso privilegiado | Proposta (RBAC) |
| A.8.3 | Restricao de acesso | Proposta (RBAC + masking) |
| A.8.5 | Autenticacao segura | Proposta (politica de senha + bloqueio) |
| A.8.11 | Mascaramento de dados | Proposta (Dynamic Data Masking) |
| A.8.15 | Log de eventos | Proposta (triggers de auditoria) |
| A.8.24 | Uso de criptografia | Pendente (TDE recomendado) |

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

- [ ] DBA revisar e executar `create_iso_database.sql`
- [ ] DBA revisar e executar `rbac_tables.sql`
- [ ] DBA revisar e aplicar `script_masking.sql` (remover falsos positivos antes)
- [ ] DBA criar triggers de auditoria nas tabelas sensiveis
- [ ] Equipe de desenvolvimento migrar senhas de MD5 para bcrypt
- [ ] Forcar reset de senha para todos os usuarios
- [ ] Implementar politica de senha na aplicacao
- [ ] Avaliar ativacao de TDE (Transparent Data Encryption)
- [ ] Agendar revisao periodica de acessos (ISO A.8.2)
