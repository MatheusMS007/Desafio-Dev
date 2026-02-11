# Sistema de Gerenciamento de Contatos

Sistema CRUD completo para gerenciamento de contatos, desenvolvido com Angular (frontend) e .NET 5 (backend).

## Tecnologias Utilizadas

### Frontend
- Angular 10
- Bootstrap 5
- TypeScript
- RxJS

### Backend
- .NET 5
- ASP.NET Core Web API
- Entity Framework Core
- SQL Server

## Estrutura do Projeto

```
├── Angular/
│   └── contatos-frontend/     # Aplicação Angular
│       ├── src/
│       │   └── app/
│       │       └── contatos/  # Módulo de contatos
│       └── package.json
│
└── DesafioCrud.Api/
    └── DesafioCrud.Api/       # API .NET
        ├── Controllers/       # Controllers da API
        ├── Data/             # Repositórios e DbContext
        ├── Model/            # Modelos de dados
        └── Startup.cs        # Configuração da API
```

## Funcionalidades

- ✅ Listar todos os contatos
- ✅ Buscar contato por ID
- ✅ Criar novo contato
- ✅ Atualizar contato existente
- ✅ Deletar contato
- ✅ Pesquisa local de contatos

## Como Executar

### Pré-requisitos
- Node.js (v12 ou superior)
- .NET 5 SDK
- SQL Server (opcional - projeto configurado com dados em memória para testes)

### Frontend (Angular)

```bash
cd Angular/contatos-frontend
npm install
ng serve --port 4201
```

Acesse: http://localhost:4201

### Backend (.NET API)

```bash
cd DesafioCrud.Api/DesafioCrud.Api
dotnet restore
dotnet run
```

API disponível em:
- HTTP: http://localhost:5000
- HTTPS: https://localhost:5001

## Configuração

### CORS
A API está configurada para aceitar requisições das seguintes origens:
- http://localhost:3000
- http://localhost:4200
- http://localhost:4201

Para adicionar novas origens, edite o arquivo `appsettings.Development.json`.

### Banco de Dados
O projeto está configurado com um controller de teste que usa dados em memória. Para usar SQL Server:
1. Configure a connection string em `appsettings.Development.json`
2. Renomeie `contatosControllers.cs.bak` para `contatosControllers.cs`
3. Delete `ContatosTestController.cs`
4. Execute as migrations do Entity Framework

## API Endpoints

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | /api/contatos | Lista todos os contatos |
| GET | /api/contatos/{id} | Busca contato por ID |
| POST | /api/contatos | Cria novo contato |
| PUT | /api/contatos/{id} | Atualiza contato |
| DELETE | /api/contatos/{id} | Deleta contato |

## Modelo de Dados

```typescript
interface Contato {
  idPessoa?: number;
  nome: string;
  telefone: string;
  email: string;
}
```

## Autor

Desenvolvido como projeto de estudo CRUD com Angular e .NET.
