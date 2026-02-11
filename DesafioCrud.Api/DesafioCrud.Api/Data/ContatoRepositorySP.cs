using DesafioCrud.Api.Model;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace DesafioCrud.Api.Data
{
    /// <summary>
    /// Implementação do Repository usando Stored Procedures com ADO.NET
    /// Alternativa ao Entity Framework Core para maior controle e performance
    /// </summary>
    public class ContatoRepositorySP : IContatoRepository
    {
        private readonly string _connectionString;
        private readonly ILogger<ContatoRepositorySP> _logger;

        public ContatoRepositorySP(IConfiguration configuration, ILogger<ContatoRepositorySP> logger)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection") 
                ?? throw new ArgumentNullException(nameof(configuration));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        public async Task<IEnumerable<Contato>> GetAllAsync()
        {
            var contatos = new List<Contato>();

            try
            {
                using (SqlConnection conn = new SqlConnection(_connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_ListarContatos", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.CommandTimeout = 30;

                        await conn.OpenAsync();

                        using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                contatos.Add(MapearContato(reader));
                            }
                        }
                    }
                }

                _logger.LogInformation("Listados {Count} contatos via SP", contatos.Count);
                return contatos;
            }
            catch (SqlException ex)
            {
                _logger.LogError(ex, "Erro SQL ao listar contatos via SP");
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao listar contatos via SP");
                throw;
            }
        }

        public async Task<Contato> GetByIdAsync(int id)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(_connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_BuscarContatoPorId", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.CommandTimeout = 30;
                        cmd.Parameters.AddWithValue("@IdPessoa", id);

                        await conn.OpenAsync();

                        using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                var contato = MapearContato(reader);
                                _logger.LogInformation("Contato {Id} encontrado via SP", id);
                                return contato;
                            }
                        }
                    }
                }

                _logger.LogWarning("Contato {Id} não encontrado via SP", id);
                return null;
            }
            catch (SqlException ex)
            {
                _logger.LogError(ex, "Erro SQL ao buscar contato {Id} via SP", id);
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao buscar contato {Id} via SP", id);
                throw;
            }
        }

        public async Task<Contato> GetByEmailAsync(string email)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(_connectionString))
                {
                    // Usando query parametrizada para busca por email
                    string query = "SELECT * FROM Contatos WHERE Email = @Email";
                    
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.CommandType = CommandType.Text;
                        cmd.Parameters.AddWithValue("@Email", email);

                        await conn.OpenAsync();

                        using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                return MapearContato(reader);
                            }
                        }
                    }
                }

                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao buscar contato por email via SP");
                throw;
            }
        }

        public async Task<Contato> CreateAsync(Contato contato)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(_connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_InserirContato", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.CommandTimeout = 30;

                        // Parâmetros de entrada
                        cmd.Parameters.AddWithValue("@Nome", contato.Nome);
                        cmd.Parameters.AddWithValue("@DataNasc", contato.DataNasc);
                        cmd.Parameters.AddWithValue("@Obs", (object)contato.Obs ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Telefone", contato.Telefone);
                        cmd.Parameters.AddWithValue("@Email", contato.Email);

                        // Parâmetro de saída
                        SqlParameter outputParam = new SqlParameter("@IdPessoa", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        cmd.Parameters.Add(outputParam);

                        await conn.OpenAsync();

                        // Executar e ler resultado
                        using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                var novoContato = MapearContato(reader);
                                _logger.LogInformation("Contato criado via SP. ID: {Id}", novoContato.IdPessoa);
                                return novoContato;
                            }
                        }
                    }
                }

                throw new Exception("Falha ao criar contato via SP");
            }
            catch (SqlException ex)
            {
                _logger.LogError(ex, "Erro SQL ao criar contato via SP");
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao criar contato via SP");
                throw;
            }
        }

        public async Task<Contato> UpdateAsync(Contato contato)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(_connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_AtualizarContato", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.CommandTimeout = 30;

                        cmd.Parameters.AddWithValue("@IdPessoa", contato.IdPessoa);
                        cmd.Parameters.AddWithValue("@Nome", contato.Nome);
                        cmd.Parameters.AddWithValue("@DataNasc", contato.DataNasc);
                        cmd.Parameters.AddWithValue("@Obs", (object)contato.Obs ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Telefone", contato.Telefone);
                        cmd.Parameters.AddWithValue("@Email", contato.Email);

                        await conn.OpenAsync();

                        using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                var contatoAtualizado = MapearContato(reader);
                                _logger.LogInformation("Contato {Id} atualizado via SP", contato.IdPessoa);
                                return contatoAtualizado;
                            }
                        }
                    }
                }

                throw new Exception("Falha ao atualizar contato via SP");
            }
            catch (SqlException ex)
            {
                _logger.LogError(ex, "Erro SQL ao atualizar contato {Id} via SP", contato.IdPessoa);
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao atualizar contato {Id} via SP", contato.IdPessoa);
                throw;
            }
        }

        public async Task<bool> DeleteAsync(int id)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(_connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_DeletarContato", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.CommandTimeout = 30;
                        cmd.Parameters.AddWithValue("@IdPessoa", id);

                        await conn.OpenAsync();

                        int rowsAffected = await cmd.ExecuteNonQueryAsync();
                        
                        if (rowsAffected > 0)
                        {
                            _logger.LogInformation("Contato {Id} deletado via SP", id);
                            return true;
                        }

                        return false;
                    }
                }
            }
            catch (SqlException ex)
            {
                _logger.LogError(ex, "Erro SQL ao deletar contato {Id} via SP", id);
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao deletar contato {Id} via SP", id);
                throw;
            }
        }

        public async Task<bool> ExistsAsync(int id)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(_connectionString))
                {
                    string query = "SELECT COUNT(*) FROM Contatos WHERE IdPessoa = @IdPessoa";
                    
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@IdPessoa", id);

                        await conn.OpenAsync();

                        int count = (int)await cmd.ExecuteScalarAsync();
                        return count > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao verificar existência do contato {Id}", id);
                throw;
            }
        }

        public async Task<bool> EmailExistsAsync(string email, int? excludeId = null)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(_connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_VerificarEmailExiste", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Email", email);
                        cmd.Parameters.AddWithValue("@IdPessoaExcluir", (object)excludeId ?? DBNull.Value);

                        await conn.OpenAsync();

                        bool existe = (bool)await cmd.ExecuteScalarAsync();
                        return existe;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao verificar email via SP");
                throw;
            }
        }

        /// <summary>
        /// Mapeia SqlDataReader para objeto Contato
        /// </summary>
        private Contato MapearContato(SqlDataReader reader)
        {
            return new Contato
            {
                IdPessoa = reader.GetInt32(reader.GetOrdinal("IdPessoa")),
                Nome = reader.GetString(reader.GetOrdinal("Nome")),
                DataNasc = reader.GetDateTime(reader.GetOrdinal("DataNasc")),
                Obs = reader.IsDBNull(reader.GetOrdinal("Obs")) ? null : reader.GetString(reader.GetOrdinal("Obs")),
                Telefone = reader.GetString(reader.GetOrdinal("Telefone")),
                Email = reader.GetString(reader.GetOrdinal("Email")),
                DataCriacao = reader.GetDateTime(reader.GetOrdinal("DataCriacao")),
                DataAtualizacao = reader.IsDBNull(reader.GetOrdinal("DataAtualizacao")) 
                    ? (DateTime?)null 
                    : reader.GetDateTime(reader.GetOrdinal("DataAtualizacao"))
            };
        }
    }
}
