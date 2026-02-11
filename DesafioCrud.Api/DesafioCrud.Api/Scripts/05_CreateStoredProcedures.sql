-- =============================================
-- STORED PROCEDURES - DesafioCrud API
-- Procedures seguras com validações
-- =============================================

USE DesafioCrudDB;
GO

-- ========================================
-- 1. SP_LISTAR_CONTATOS
-- ========================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ListarContatos]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_ListarContatos]
GO

CREATE PROCEDURE [dbo].[sp_ListarContatos]
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            IdPessoa,
            Nome,
            DataNasc,
            Obs,
            Telefone,
            Email,
            DataCriacao,
            DataAtualizacao
        FROM Contatos WITH (NOLOCK)
        ORDER BY Nome;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- ========================================
-- 2. SP_BUSCAR_CONTATO_POR_ID
-- ========================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_BuscarContatoPorId]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_BuscarContatoPorId]
GO

CREATE PROCEDURE [dbo].[sp_BuscarContatoPorId]
    @IdPessoa INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Validação
        IF @IdPessoa IS NULL OR @IdPessoa <= 0
        BEGIN
            RAISERROR('ID inválido', 16, 1);
            RETURN;
        END
        
        SELECT 
            IdPessoa,
            Nome,
            DataNasc,
            Obs,
            Telefone,
            Email,
            DataCriacao,
            DataAtualizacao
        FROM Contatos WITH (NOLOCK)
        WHERE IdPessoa = @IdPessoa;
        
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Contato não encontrado', 16, 1);
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- ========================================
-- 3. SP_INSERIR_CONTATO
-- ========================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_InserirContato]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_InserirContato]
GO

CREATE PROCEDURE [dbo].[sp_InserirContato]
    @Nome NVARCHAR(200),
    @DataNasc DATE,
    @Obs NVARCHAR(1000) = NULL,
    @Telefone NVARCHAR(20),
    @Email NVARCHAR(200),
    @IdPessoa INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validações
        IF @Nome IS NULL OR LEN(RTRIM(@Nome)) < 3
        BEGIN
            RAISERROR('Nome deve ter no mínimo 3 caracteres', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF @Email IS NULL OR @Email NOT LIKE '%@%.%'
        BEGIN
            RAISERROR('Email inválido', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF @Telefone IS NULL OR LEN(RTRIM(@Telefone)) < 10
        BEGIN
            RAISERROR('Telefone inválido', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF @DataNasc IS NULL OR @DataNasc > GETDATE()
        BEGIN
            RAISERROR('Data de nascimento inválida', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Verificar email duplicado
        IF EXISTS (SELECT 1 FROM Contatos WHERE Email = @Email)
        BEGIN
            RAISERROR('Email já cadastrado no sistema', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Inserir contato
        INSERT INTO Contatos (Nome, DataNasc, Obs, Telefone, Email, DataCriacao)
        VALUES (@Nome, @DataNasc, @Obs, @Telefone, @Email, GETUTCDATE());
        
        -- Retornar ID gerado
        SET @IdPessoa = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        -- Retornar contato criado
        SELECT 
            IdPessoa,
            Nome,
            DataNasc,
            Obs,
            Telefone,
            Email,
            DataCriacao,
            DataAtualizacao
        FROM Contatos
        WHERE IdPessoa = @IdPessoa;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- ========================================
-- 4. SP_ATUALIZAR_CONTATO
-- ========================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_AtualizarContato]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_AtualizarContato]
GO

CREATE PROCEDURE [dbo].[sp_AtualizarContato]
    @IdPessoa INT,
    @Nome NVARCHAR(200),
    @DataNasc DATE,
    @Obs NVARCHAR(1000) = NULL,
    @Telefone NVARCHAR(20),
    @Email NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validações
        IF @IdPessoa IS NULL OR @IdPessoa <= 0
        BEGIN
            RAISERROR('ID inválido', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF NOT EXISTS (SELECT 1 FROM Contatos WHERE IdPessoa = @IdPessoa)
        BEGIN
            RAISERROR('Contato não encontrado', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF @Nome IS NULL OR LEN(RTRIM(@Nome)) < 3
        BEGIN
            RAISERROR('Nome deve ter no mínimo 3 caracteres', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF @Email IS NULL OR @Email NOT LIKE '%@%.%'
        BEGIN
            RAISERROR('Email inválido', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Verificar email duplicado (excluindo o próprio registro)
        IF EXISTS (SELECT 1 FROM Contatos WHERE Email = @Email AND IdPessoa <> @IdPessoa)
        BEGIN
            RAISERROR('Email já cadastrado para outro contato', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Atualizar contato
        UPDATE Contatos
        SET 
            Nome = @Nome,
            DataNasc = @DataNasc,
            Obs = @Obs,
            Telefone = @Telefone,
            Email = @Email,
            DataAtualizacao = GETUTCDATE()
        WHERE IdPessoa = @IdPessoa;
        
        COMMIT TRANSACTION;
        
        -- Retornar contato atualizado
        SELECT 
            IdPessoa,
            Nome,
            DataNasc,
            Obs,
            Telefone,
            Email,
            DataCriacao,
            DataAtualizacao
        FROM Contatos
        WHERE IdPessoa = @IdPessoa;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- ========================================
-- 5. SP_DELETAR_CONTATO
-- ========================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_DeletarContato]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_DeletarContato]
GO

CREATE PROCEDURE [dbo].[sp_DeletarContato]
    @IdPessoa INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validação
        IF @IdPessoa IS NULL OR @IdPessoa <= 0
        BEGIN
            RAISERROR('ID inválido', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF NOT EXISTS (SELECT 1 FROM Contatos WHERE IdPessoa = @IdPessoa)
        BEGIN
            RAISERROR('Contato não encontrado', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Deletar contato
        DELETE FROM Contatos
        WHERE IdPessoa = @IdPessoa;
        
        COMMIT TRANSACTION;
        
        -- Retornar sucesso
        SELECT 1 AS Sucesso;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- ========================================
-- 6. SP_VERIFICAR_EMAIL_EXISTE
-- ========================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_VerificarEmailExiste]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_VerificarEmailExiste]
GO

CREATE PROCEDURE [dbo].[sp_VerificarEmailExiste]
    @Email NVARCHAR(200),
    @IdPessoaExcluir INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF @IdPessoaExcluir IS NULL
        BEGIN
            SELECT CAST(COUNT(*) AS BIT) AS Existe
            FROM Contatos WITH (NOLOCK)
            WHERE Email = @Email;
        END
        ELSE
        BEGIN
            SELECT CAST(COUNT(*) AS BIT) AS Existe
            FROM Contatos WITH (NOLOCK)
            WHERE Email = @Email AND IdPessoa <> @IdPessoaExcluir;
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- ========================================
-- CONCEDER PERMISSÕES
-- ========================================
GRANT EXECUTE ON [dbo].[sp_ListarContatos] TO desafio_crud_user;
GRANT EXECUTE ON [dbo].[sp_BuscarContatoPorId] TO desafio_crud_user;
GRANT EXECUTE ON [dbo].[sp_InserirContato] TO desafio_crud_user;
GRANT EXECUTE ON [dbo].[sp_AtualizarContato] TO desafio_crud_user;
GRANT EXECUTE ON [dbo].[sp_DeletarContato] TO desafio_crud_user;
GRANT EXECUTE ON [dbo].[sp_VerificarEmailExiste] TO desafio_crud_user;
GO

-- ========================================
-- TESTES DAS STORED PROCEDURES
-- ========================================
PRINT '';
PRINT '========================================';
PRINT 'TESTANDO STORED PROCEDURES';
PRINT '========================================';
PRINT '';

-- Teste 1: Listar contatos
PRINT 'Teste 1: Listar contatos';
EXEC sp_ListarContatos;
PRINT '';

-- Teste 2: Inserir contato
PRINT 'Teste 2: Inserir contato';
DECLARE @NovoId INT;
EXEC sp_InserirContato 
    @Nome = 'Teste SP',
    @DataNasc = '1990-01-01',
    @Obs = 'Criado via Stored Procedure',
    @Telefone = '+55 11 99999-9999',
    @Email = 'teste.sp@email.com',
    @IdPessoa = @NovoId OUTPUT;
PRINT 'ID gerado: ' + CAST(@NovoId AS VARCHAR(10));
PRINT '';

-- Teste 3: Buscar por ID
PRINT 'Teste 3: Buscar por ID';
EXEC sp_BuscarContatoPorId @IdPessoa = @NovoId;
PRINT '';

-- Teste 4: Atualizar contato
PRINT 'Teste 4: Atualizar contato';
EXEC sp_AtualizarContato
    @IdPessoa = @NovoId,
    @Nome = 'Teste SP Atualizado',
    @DataNasc = '1990-01-01',
    @Obs = 'Atualizado via Stored Procedure',
    @Telefone = '+55 11 99999-9999',
    @Email = 'teste.sp@email.com';
PRINT '';

-- Teste 5: Verificar email
PRINT 'Teste 5: Verificar email existe';
EXEC sp_VerificarEmailExiste @Email = 'teste.sp@email.com';
PRINT '';

-- Teste 6: Deletar contato
PRINT 'Teste 6: Deletar contato';
EXEC sp_DeletarContato @IdPessoa = @NovoId;
PRINT '';

PRINT '========================================';
PRINT 'STORED PROCEDURES CRIADAS COM SUCESSO!';
PRINT '========================================';
PRINT '';
PRINT 'Procedures disponíveis:';
PRINT '  • sp_ListarContatos';
PRINT '  • sp_BuscarContatoPorId';
PRINT '  • sp_InserirContato';
PRINT '  • sp_AtualizarContato';
PRINT '  • sp_DeletarContato';
PRINT '  • sp_VerificarEmailExiste';
PRINT '';
GO
