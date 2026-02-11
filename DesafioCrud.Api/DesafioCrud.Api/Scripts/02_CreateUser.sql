-- =============================================
-- Script de Criação de Usuário com Privilégios Mínimos
-- Princípio de Least Privilege
-- =============================================

USE master;
GO

-- Criar login se não existir
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'desafio_crud_user')
BEGIN
    CREATE LOGIN desafio_crud_user 
    WITH PASSWORD = 'Crud@Secure2026!',
    DEFAULT_DATABASE = DesafioCrudDB,
    CHECK_EXPIRATION = ON,
    CHECK_POLICY = ON;
    
    PRINT 'Login desafio_crud_user criado com sucesso!';
END
ELSE
BEGIN
    PRINT 'Login desafio_crud_user já existe.';
END
GO

USE DesafioCrudDB;
GO

-- Criar usuário no banco
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'desafio_crud_user')
BEGIN
    CREATE USER desafio_crud_user FOR LOGIN desafio_crud_user;
    PRINT 'Usuário desafio_crud_user criado no banco!';
END
GO

-- Conceder apenas permissões necessárias (Least Privilege)
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO desafio_crud_user;
GRANT EXECUTE ON SCHEMA::dbo TO desafio_crud_user;
GO

-- Adicionar ao role db_datareader e db_datawriter
ALTER ROLE db_datareader ADD MEMBER desafio_crud_user;
ALTER ROLE db_datawriter ADD MEMBER desafio_crud_user;
GO

PRINT 'Permissões configuradas com sucesso!';
PRINT 'IMPORTANTE: Atualize a connection string com estas credenciais:';
PRINT 'User Id=desafio_crud_user;Password=Crud@Secure2026!';
GO
