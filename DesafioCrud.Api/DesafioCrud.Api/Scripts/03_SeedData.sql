-- =============================================
-- Script de Dados de Teste
-- =============================================

USE DesafioCrudDB;
GO

-- Inserir dados de teste apenas se a tabela estiver vazia
IF NOT EXISTS (SELECT 1 FROM Contatos)
BEGIN
    INSERT INTO Contatos (Nome, DataNasc, Obs, Telefone, Email, DataCriacao)
    VALUES 
        ('João Silva', '1990-05-15', 'Cliente VIP', '+55 11 98765-4321', 'joao.silva@email.com', GETUTCDATE()),
        ('Maria Santos', '1985-08-22', 'Contato comercial', '+55 21 97654-3210', 'maria.santos@email.com', GETUTCDATE()),
        ('Pedro Oliveira', '1992-03-10', NULL, '+55 11 96543-2109', 'pedro.oliveira@email.com', GETUTCDATE()),
        ('Ana Costa', '1988-11-30', 'Fornecedor', '+55 31 95432-1098', 'ana.costa@email.com', GETUTCDATE()),
        ('Carlos Ferreira', '1995-07-18', 'Parceiro estratégico', '+55 41 94321-0987', 'carlos.ferreira@email.com', GETUTCDATE());

    PRINT 'Dados de teste inseridos com sucesso!';
    PRINT CAST(@@ROWCOUNT AS VARCHAR(10)) + ' registros criados.';
END
ELSE
BEGIN
    PRINT 'Tabela Contatos já contém dados. Seed ignorado.';
END
GO

-- Verificar dados inseridos
SELECT 
    IdPessoa,
    Nome,
    Email,
    Telefone,
    DataCriacao
FROM Contatos
ORDER BY IdPessoa;
GO
