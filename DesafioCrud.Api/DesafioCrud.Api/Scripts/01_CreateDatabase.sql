-- =============================================
-- Script de Criação do Banco de Dados
-- Database: DesafioCrudDB
-- Autor: Dev Team
-- Data: 2026-02-10
-- =============================================

USE master;
GO

-- Verifica se o banco existe e cria se necessário
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'DesafioCrudDB')
BEGIN
    CREATE DATABASE DesafioCrudDB
    COLLATE Latin1_General_CI_AS;
    PRINT 'Database DesafioCrudDB criado com sucesso!';
END
ELSE
BEGIN
    PRINT 'Database DesafioCrudDB já existe.';
END
GO

USE DesafioCrudDB;
GO

-- Configurações de segurança do banco
ALTER DATABASE DesafioCrudDB SET RECOVERY SIMPLE;
ALTER DATABASE DesafioCrudDB SET AUTO_CLOSE OFF;
ALTER DATABASE DesafioCrudDB SET AUTO_SHRINK OFF;
GO

PRINT 'Configurações de segurança aplicadas com sucesso!';
GO
