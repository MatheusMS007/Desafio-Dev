-- =============================================
-- SCRIPT COMPLETO DE CONFIGURAÇÃO
-- Execute este script para configurar tudo de uma vez
-- =============================================

USE master;
GO

-- ========== PASSO 1: CRIAR BANCO ==========
PRINT '========================================';
PRINT 'PASSO 1: Criando banco de dados...';
PRINT '========================================';

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'DesafioCrudDB')
BEGIN
    CREATE DATABASE DesafioCrudDB
    COLLATE Latin1_General_CI_AS;
    PRINT '✓ Database DesafioCrudDB criado!';
END
ELSE
BEGIN
    PRINT '✓ Database DesafioCrudDB já existe.';
END
GO

-- Configurações de segurança
ALTER DATABASE DesafioCrudDB SET RECOVERY SIMPLE;
ALTER DATABASE DesafioCrudDB SET AUTO_CLOSE OFF;
ALTER DATABASE DesafioCrudDB SET AUTO_SHRINK OFF;
GO

-- ========== PASSO 2: CRIAR USUÁRIO ==========
PRINT '';
PRINT '========================================';
PRINT 'PASSO 2: Criando usuário seguro...';
PRINT '========================================';

-- Criar login
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'desafio_crud_user')
BEGIN
    CREATE LOGIN desafio_crud_user 
    WITH PASSWORD = 'Crud@Secure2026!',
    DEFAULT_DATABASE = DesafioCrudDB,
    CHECK_EXPIRATION = ON,
    CHECK_POLICY = ON;
    
    PRINT '✓ Login desafio_crud_user criado!';
END
ELSE
BEGIN
    PRINT '✓ Login desafio_crud_user já existe.';
END
GO

USE DesafioCrudDB;
GO

-- Criar usuário no banco
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'desafio_crud_user')
BEGIN
    CREATE USER desafio_crud_user FOR LOGIN desafio_crud_user;
    PRINT '✓ Usuário criado no banco!';
END
GO

-- Conceder permissões (Least Privilege)
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO desafio_crud_user;
GRANT EXECUTE ON SCHEMA::dbo TO desafio_crud_user;
ALTER ROLE db_datareader ADD MEMBER desafio_crud_user;
ALTER ROLE db_datawriter ADD MEMBER desafio_crud_user;
GO

PRINT '✓ Permissões configuradas!';
GO

-- ========== PASSO 3: CRIAR TABELA ==========
PRINT '';
PRINT '========================================';
PRINT 'PASSO 3: Criando tabela Contatos...';
PRINT '========================================';

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Contatos]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Contatos] (
        [IdPessoa] INT IDENTITY(1,1) NOT NULL,
        [Nome] NVARCHAR(200) NOT NULL,
        [DataNasc] DATE NOT NULL,
        [Obs] NVARCHAR(1000) NULL,
        [Telefone] NVARCHAR(20) NOT NULL,
        [Email] NVARCHAR(200) NOT NULL,
        [DataCriacao] DATETIME2(7) NOT NULL DEFAULT (GETUTCDATE()),
        [DataAtualizacao] DATETIME2(7) NULL,
        
        CONSTRAINT [PK_Contatos] PRIMARY KEY CLUSTERED ([IdPessoa] ASC)
    );
    
    PRINT '✓ Tabela Contatos criada!';
END
ELSE
BEGIN
    PRINT '✓ Tabela Contatos já existe.';
END
GO

-- ========== PASSO 4: CRIAR ÍNDICES ==========
PRINT '';
PRINT '========================================';
PRINT 'PASSO 4: Criando índices...';
PRINT '========================================';

-- Índice único para email
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Contatos_Email' AND object_id = OBJECT_ID('Contatos'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [IX_Contatos_Email]
    ON [dbo].[Contatos] ([Email] ASC);
    PRINT '✓ Índice único em Email criado!';
END
ELSE
BEGIN
    PRINT '✓ Índice em Email já existe.';
END
GO

-- Índice para telefone
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Contatos_Telefone' AND object_id = OBJECT_ID('Contatos'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Contatos_Telefone]
    ON [dbo].[Contatos] ([Telefone] ASC);
    PRINT '✓ Índice em Telefone criado!';
END
ELSE
BEGIN
    PRINT '✓ Índice em Telefone já existe.';
END
GO

-- ========== PASSO 5: INSERIR DADOS DE TESTE ==========
PRINT '';
PRINT '========================================';
PRINT 'PASSO 5: Inserindo dados de teste...';
PRINT '========================================';

IF NOT EXISTS (SELECT 1 FROM Contatos)
BEGIN
    INSERT INTO Contatos (Nome, DataNasc, Obs, Telefone, Email, DataCriacao)
    VALUES 
        ('João Silva', '1990-05-15', 'Cliente VIP', '+55 11 98765-4321', 'joao.silva@email.com', GETUTCDATE()),
        ('Maria Santos', '1985-08-22', 'Contato comercial', '+55 21 97654-3210', 'maria.santos@email.com', GETUTCDATE()),
        ('Pedro Oliveira', '1992-03-10', NULL, '+55 11 96543-2109', 'pedro.oliveira@email.com', GETUTCDATE()),
        ('Ana Costa', '1988-11-30', 'Fornecedor', '+55 31 95432-1098', 'ana.costa@email.com', GETUTCDATE()),
        ('Carlos Ferreira', '1995-07-18', 'Parceiro estratégico', '+55 41 94321-0987', 'carlos.ferreira@email.com', GETUTCDATE());

    PRINT '✓ ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' registros de teste inseridos!';
END
ELSE
BEGIN
    PRINT '✓ Dados de teste já existem.';
END
GO

-- ========== VERIFICAÇÃO FINAL ==========
PRINT '';
PRINT '========================================';
PRINT 'VERIFICAÇÃO FINAL';
PRINT '========================================';

-- Verificar contatos
DECLARE @TotalContatos INT;
SELECT @TotalContatos = COUNT(*) FROM Contatos;
PRINT '✓ Total de contatos no banco: ' + CAST(@TotalContatos AS VARCHAR(10));

-- Verificar índices
DECLARE @TotalIndices INT;
SELECT @TotalIndices = COUNT(*) 
FROM sys.indexes 
WHERE object_id = OBJECT_ID('Contatos') AND name IS NOT NULL;
PRINT '✓ Total de índices criados: ' + CAST(@TotalIndices AS VARCHAR(10));

-- Mostrar dados
PRINT '';
PRINT 'Contatos cadastrados:';
SELECT 
    IdPessoa,
    Nome,
    Email,
    Telefone,
    FORMAT(DataNasc, 'dd/MM/yyyy') AS DataNascimento
FROM Contatos
ORDER BY IdPessoa;
GO

-- ========== INFORMAÇÕES IMPORTANTES ==========
PRINT '';
PRINT '========================================';
PRINT '✅ CONFIGURAÇÃO CONCLUÍDA COM SUCESSO!';
PRINT '========================================';
PRINT '';
PRINT 'Connection String para usar na aplicação:';
PRINT 'Server=localhost;Database=DesafioCrudDB;User Id=desafio_crud_user;Password=Crud@Secure2026!;TrustServerCertificate=True';
PRINT '';
PRINT 'Próximos passos:';
PRINT '1. Atualize appsettings.Development.json com a connection string acima';
PRINT '2. Execute: dotnet run';
PRINT '3. Acesse: https://localhost:5001/swagger';
PRINT '4. Teste os endpoints!';
PRINT '';
GO
