# DesafioCrud API

API RESTful para gerenciamento de contatos desenvolvida com ASP.NET Core 5.0 e SQL Server.

## 🚀 Tecnologias

- ASP.NET Core 5.0
- Entity Framework Core
- SQL Server
- Swagger/OpenAPI

## 📋 Pré-requisitos

- .NET 5.0 SDK
- SQL Server 2019+
- Visual Studio 2019+ ou VS Code

## ⚙️ Configuração

1. Clone o repositório
2. Configure a connection string em `appsettings.json`
3. Execute os scripts SQL em `Scripts/`
4. Execute: `dotnet run`

## 🔗 Endpoints

- `GET /api/contatos` - Lista todos os contatos
- `GET /api/contatos/{id}` - Busca contato por ID
- `POST /api/contatos` - Cria novo contato
- `PUT /api/contatos/{id}` - Atualiza contato
- `DELETE /api/contatos/{id}` - Remove contato

## 📊 Swagger

Acesse: `https://localhost:5001/swagger`

## 🔒 Segurança

- Proteção contra SQL Injection
- Validações de dados
- HTTPS obrigatório
- CORS configurado
