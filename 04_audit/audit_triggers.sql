-- ============================================================
-- Audit Triggers - ISO 27001 A.8.15
-- ============================================================
-- Template: create audit trigger for any table.
-- Copy and adapt per table that needs auditing.
-- Priority: tables with sensitive data (Funcionario, SST, etc.)
-- ============================================================

-- ==================== EXAMPLE: ntl.usuario ====================

CREATE OR ALTER TRIGGER auditoria.tr_usuario_audit
ON ntl.usuario
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @operacao NVARCHAR(10);

    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        SET @operacao = 'UPDATE';
    ELSE IF EXISTS (SELECT 1 FROM inserted)
        SET @operacao = 'INSERT';
    ELSE
        SET @operacao = 'DELETE';

    -- Log changes
    IF @operacao = 'UPDATE'
    BEGIN
        INSERT INTO auditoria.log_alteracao
            (usuario, schema_nome, tabela_nome, operacao, registro_id,
             dados_anteriores, dados_novos)
        SELECT
            SYSTEM_USER,
            'ntl',
            'usuario',
            @operacao,
            CAST(d.id AS NVARCHAR(100)),
            (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
            (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        FROM deleted d
        JOIN inserted i ON d.id = i.id;
    END

    IF @operacao = 'INSERT'
    BEGIN
        INSERT INTO auditoria.log_alteracao
            (usuario, schema_nome, tabela_nome, operacao, registro_id,
             dados_novos)
        SELECT
            SYSTEM_USER,
            'ntl',
            'usuario',
            @operacao,
            CAST(i.id AS NVARCHAR(100)),
            (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        FROM inserted i;
    END

    IF @operacao = 'DELETE'
    BEGIN
        INSERT INTO auditoria.log_alteracao
            (usuario, schema_nome, tabela_nome, operacao, registro_id,
             dados_anteriores)
        SELECT
            SYSTEM_USER,
            'ntl',
            'usuario',
            @operacao,
            CAST(d.id AS NVARCHAR(100)),
            (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        FROM deleted d;
    END
END;
GO

-- ==================== TRIGGER GENERATOR ====================
-- Use this to generate triggers for other tables.
-- Replace [SCHEMA], [TABLE], and [PK_COLUMN] placeholders.

/*
CREATE OR ALTER TRIGGER auditoria.tr_[SCHEMA]_[TABLE]_audit
ON [SCHEMA].[TABLE]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @operacao NVARCHAR(10);

    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        SET @operacao = 'UPDATE';
    ELSE IF EXISTS (SELECT 1 FROM inserted)
        SET @operacao = 'INSERT';
    ELSE
        SET @operacao = 'DELETE';

    IF @operacao = 'UPDATE'
        INSERT INTO auditoria.log_alteracao
            (usuario, schema_nome, tabela_nome, operacao, registro_id,
             dados_anteriores, dados_novos)
        SELECT SYSTEM_USER, '[SCHEMA]', '[TABLE]', @operacao,
            CAST(d.[PK_COLUMN] AS NVARCHAR(100)),
            (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
            (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        FROM deleted d JOIN inserted i ON d.[PK_COLUMN] = i.[PK_COLUMN];

    IF @operacao = 'INSERT'
        INSERT INTO auditoria.log_alteracao
            (usuario, schema_nome, tabela_nome, operacao, registro_id, dados_novos)
        SELECT SYSTEM_USER, '[SCHEMA]', '[TABLE]', @operacao,
            CAST(i.[PK_COLUMN] AS NVARCHAR(100)),
            (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        FROM inserted i;

    IF @operacao = 'DELETE'
        INSERT INTO auditoria.log_alteracao
            (usuario, schema_nome, tabela_nome, operacao, registro_id, dados_anteriores)
        SELECT SYSTEM_USER, '[SCHEMA]', '[TABLE]', @operacao,
            CAST(d.[PK_COLUMN] AS NVARCHAR(100)),
            (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        FROM deleted d;
END;
GO
*/

PRINT 'Audit trigger for ntl.usuario created.';
PRINT 'Use template above to create triggers for other sensitive tables.';
