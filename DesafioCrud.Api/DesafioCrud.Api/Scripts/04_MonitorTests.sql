-- =============================================
-- QUERIES PARA MONITORAR TESTES NO POSTMAN
-- Execute estas queries enquanto testa a API
-- =============================================

USE DesafioCrudDB;
GO

-- ========================================
-- 1. VER TODOS OS CONTATOS
-- ========================================
SELECT 
    IdPessoa,
    Nome,
    Email,
    Telefone,
    FORMAT(DataNasc, 'dd/MM/yyyy') AS DataNascimento,
    Obs,
    FORMAT(DataCriacao, 'dd/MM/yyyy HH:mm:ss') AS Criado,
    FORMAT(DataAtualizacao, 'dd/MM/yyyy HH:mm:ss') AS Atualizado
FROM Contatos
ORDER BY IdPessoa;
GO

-- ========================================
-- 2. CONTAR TOTAL DE CONTATOS
-- ========================================
SELECT 
    COUNT(*) AS TotalContatos,
    COUNT(CASE WHEN DataAtualizacao IS NOT NULL THEN 1 END) AS ContatosAtualizados,
    COUNT(CASE WHEN DataAtualizacao IS NULL THEN 1 END) AS ContatosNaoAtualizados
FROM Contatos;
GO

-- ========================================
-- 3. VER ÚLTIMOS 5 CONTATOS CRIADOS
-- ========================================
SELECT TOP 5
    IdPessoa,
    Nome,
    Email,
    FORMAT(DataCriacao, 'dd/MM/yyyy HH:mm:ss') AS Criado
FROM Contatos
ORDER BY DataCriacao DESC;
GO

-- ========================================
-- 4. VER CONTATOS ATUALIZADOS RECENTEMENTE
-- ========================================
SELECT 
    IdPessoa,
    Nome,
    Email,
    FORMAT(DataCriacao, 'dd/MM/yyyy HH:mm:ss') AS Criado,
    FORMAT(DataAtualizacao, 'dd/MM/yyyy HH:mm:ss') AS Atualizado,
    DATEDIFF(SECOND, DataCriacao, DataAtualizacao) AS SegundosAteAtualizacao
FROM Contatos
WHERE DataAtualizacao IS NOT NULL
ORDER BY DataAtualizacao DESC;
GO

-- ========================================
-- 5. BUSCAR POR EMAIL
-- ========================================
SELECT * FROM Contatos 
WHERE Email = 'joao.silva@email.com';
GO

-- ========================================
-- 6. BUSCAR POR NOME (LIKE)
-- ========================================
SELECT * FROM Contatos 
WHERE Nome LIKE '%Silva%'
ORDER BY Nome;
GO

-- ========================================
-- 7. VER CONTATOS SEM OBSERVAÇÃO
-- ========================================
SELECT 
    IdPessoa,
    Nome,
    Email,
    Obs
FROM Contatos
WHERE Obs IS NULL OR Obs = '';
GO

-- ========================================
-- 8. VER CONTATOS COM OBSERVAÇÃO
-- ========================================
SELECT 
    IdPessoa,
    Nome,
    Email,
    Obs
FROM Contatos
WHERE Obs IS NOT NULL AND Obs <> '';
GO

-- ========================================
-- 9. VERIFICAR ÍNDICES E PERFORMANCE
-- ========================================
SELECT 
    i.name AS NomeIndice,
    i.type_desc AS TipoIndice,
    i.is_unique AS Unico,
    COL_NAME(ic.object_id, ic.column_id) AS Coluna
FROM sys.indexes i
INNER JOIN sys.index_columns ic 
    ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE i.object_id = OBJECT_ID('Contatos')
ORDER BY i.index_id, ic.key_ordinal;
GO

-- ========================================
-- 10. ESTATÍSTICAS DE USO DOS ÍNDICES
-- ========================================
SELECT 
    OBJECT_NAME(s.object_id) AS Tabela,
    i.name AS Indice,
    s.user_seeks AS Buscas,
    s.user_scans AS Scans,
    s.user_lookups AS Lookups,
    s.user_updates AS Atualizacoes,
    s.last_user_seek AS UltimaBusca,
    s.last_user_update AS UltimaAtualizacao
FROM sys.dm_db_index_usage_stats s
INNER JOIN sys.indexes i 
    ON s.object_id = i.object_id AND s.index_id = i.index_id
WHERE OBJECT_NAME(s.object_id) = 'Contatos'
ORDER BY s.user_seeks DESC;
GO

-- ========================================
-- 11. VERIFICAR TAMANHO DA TABELA
-- ========================================
EXEC sp_spaceused 'Contatos';
GO

-- ========================================
-- 12. VER CONEXÕES ATIVAS DA API
-- ========================================
SELECT 
    session_id AS Sessao,
    login_name AS Usuario,
    program_name AS Programa,
    host_name AS Host,
    status AS Status,
    FORMAT(login_time, 'dd/MM/yyyy HH:mm:ss') AS HoraLogin,
    last_request_start_time AS UltimaRequisicao
FROM sys.dm_exec_sessions
WHERE database_id = DB_ID('DesafioCrudDB')
    AND is_user_process = 1
ORDER BY login_time DESC;
GO

-- ========================================
-- 13. VER QUERIES EXECUTADAS RECENTEMENTE
-- ========================================
SELECT TOP 10
    qs.execution_count AS Execucoes,
    SUBSTRING(qt.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(qt.text)
            ELSE qs.statement_end_offset
        END - qs.statement_start_offset)/2)+1) AS Query,
    qs.total_elapsed_time / 1000000.0 AS TempoTotalSegundos,
    qs.last_execution_time AS UltimaExecucao
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
WHERE qt.text LIKE '%Contatos%'
    AND qt.text NOT LIKE '%sys.dm_exec%'
ORDER BY qs.last_execution_time DESC;
GO

-- ========================================
-- 14. LIMPAR TODOS OS DADOS (CUIDADO!)
-- ========================================
-- DESCOMENTE APENAS SE QUISER RESETAR OS TESTES
/*
TRUNCATE TABLE Contatos;
PRINT 'Todos os contatos foram deletados!';
GO
*/

-- ========================================
-- 15. INSERIR DADOS DE TESTE NOVAMENTE
-- ========================================
-- DESCOMENTE SE PRECISAR REINSERIR DADOS
/*
IF NOT EXISTS (SELECT 1 FROM Contatos)
BEGIN
    INSERT INTO Contatos (Nome, DataNasc, Obs, Telefone, Email, DataCriacao)
    VALUES 
        ('João Silva', '1990-05-15', 'Cliente VIP', '+55 11 98765-4321', 'joao.silva@email.com', GETUTCDATE()),
        ('Maria Santos', '1985-08-22', 'Contato comercial', '+55 21 97654-3210', 'maria.santos@email.com', GETUTCDATE()),
        ('Pedro Oliveira', '1992-03-10', NULL, '+55 11 96543-2109', 'pedro.oliveira@email.com', GETUTCDATE()),
        ('Ana Costa', '1988-11-30', 'Fornecedor', '+55 31 95432-1098', 'ana.costa@email.com', GETUTCDATE()),
        ('Carlos Ferreira', '1995-07-18', 'Parceiro estratégico', '+55 41 94321-0987', 'carlos.ferreira@email.com', GETUTCDATE());
    
    PRINT CAST(@@ROWCOUNT AS VARCHAR(10)) + ' contatos inseridos!';
END
GO
*/

-- ========================================
-- 16. VERIFICAR INTEGRIDADE DOS DADOS
-- ========================================
SELECT 
    'Emails Duplicados' AS Verificacao,
    Email,
    COUNT(*) AS Quantidade
FROM Contatos
GROUP BY Email
HAVING COUNT(*) > 1

UNION ALL

SELECT 
    'Nomes Muito Curtos' AS Verificacao,
    Nome,
    LEN(Nome) AS Tamanho
FROM Contatos
WHERE LEN(Nome) < 3

UNION ALL

SELECT 
    'Emails Inválidos' AS Verificacao,
    Email,
    0 AS Quantidade
FROM Contatos
WHERE Email NOT LIKE '%@%'
    OR Email NOT LIKE '%.%';
GO

-- ========================================
-- 17. RELATÓRIO COMPLETO
-- ========================================
PRINT '========================================';
PRINT 'RELATÓRIO DE TESTES - ' + FORMAT(GETDATE(), 'dd/MM/yyyy HH:mm:ss');
PRINT '========================================';
PRINT '';

DECLARE @Total INT, @Atualizados INT;
SELECT @Total = COUNT(*), @Atualizados = COUNT(CASE WHEN DataAtualizacao IS NOT NULL THEN 1 END)
FROM Contatos;

PRINT 'Total de Contatos: ' + CAST(@Total AS VARCHAR(10));
PRINT 'Contatos Atualizados: ' + CAST(@Atualizados AS VARCHAR(10));
PRINT 'Contatos Não Atualizados: ' + CAST(@Total - @Atualizados AS VARCHAR(10));
PRINT '';

IF @Total > 0
BEGIN
    PRINT 'Últimos 3 contatos criados:';
    SELECT TOP 3
        CAST(IdPessoa AS VARCHAR(10)) + ' - ' + Nome + ' (' + Email + ')' AS Contato
    FROM Contatos
    ORDER BY DataCriacao DESC;
END
ELSE
BEGIN
    PRINT 'Nenhum contato cadastrado ainda.';
END
GO

-- ========================================
-- 18. MONITORAMENTO EM TEMPO REAL
-- Execute esta query repetidamente durante os testes
-- ========================================
SELECT 
    'RESUMO' AS Tipo,
    CAST(COUNT(*) AS VARCHAR(20)) AS Valor,
    'Total de Contatos' AS Descricao
FROM Contatos

UNION ALL

SELECT 
    'ÚLTIMO CRIADO',
    CAST(MAX(IdPessoa) AS VARCHAR(20)),
    'ID do último contato criado'
FROM Contatos

UNION ALL

SELECT 
    'ÚLTIMA CRIAÇÃO',
    FORMAT(MAX(DataCriacao), 'HH:mm:ss'),
    'Hora da última criação'
FROM Contatos

UNION ALL

SELECT 
    'ÚLTIMA ATUALIZAÇÃO',
    ISNULL(FORMAT(MAX(DataAtualizacao), 'HH:mm:ss'), 'Nenhuma'),
    'Hora da última atualização'
FROM Contatos;
GO

-- ========================================
-- DICA: Execute esta query a cada teste
-- ========================================
PRINT '';
PRINT '💡 DICA: Execute "SELECT * FROM Contatos ORDER BY IdPessoa" após cada teste no Postman!';
PRINT '';
GO
