using DesafioCrud.Api.Model;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DesafioCrud.Api.Data
{
    public class ContatoRepository : IContatoRepository
    {
        private readonly AppDbContext _context;
        private readonly ILogger<ContatoRepository> _logger;

        public ContatoRepository(AppDbContext context, ILogger<ContatoRepository> logger)
        {
            _context = context ?? throw new ArgumentNullException(nameof(context));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        public async Task<IEnumerable<Contato>> GetAllAsync()
        {
            try
            {
                return await _context.Contatos
                    .AsNoTracking()
                    .OrderBy(c => c.Nome)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao buscar todos os contatos");
                throw;
            }
        }

        public async Task<Contato> GetByIdAsync(int id)
        {
            try
            {
                return await _context.Contatos
                    .AsNoTracking()
                    .FirstOrDefaultAsync(c => c.IdPessoa == id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao buscar contato por ID: {Id}", id);
                throw;
            }
        }

        public async Task<Contato> GetByEmailAsync(string email)
        {
            try
            {
                return await _context.Contatos
                    .AsNoTracking()
                    .FirstOrDefaultAsync(c => c.Email == email);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao buscar contato por email: {Email}", email);
                throw;
            }
        }

        public async Task<Contato> CreateAsync(Contato contato)
        {
            try
            {
                _context.Contatos.Add(contato);
                await _context.SaveChangesAsync();
                _logger.LogInformation("Contato criado com sucesso. ID: {Id}", contato.IdPessoa);
                return contato;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao criar contato");
                throw;
            }
        }

        public async Task<Contato> UpdateAsync(Contato contato)
        {
            try
            {
                _context.Entry(contato).State = EntityState.Modified;
                await _context.SaveChangesAsync();
                _logger.LogInformation("Contato atualizado com sucesso. ID: {Id}", contato.IdPessoa);
                return contato;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao atualizar contato. ID: {Id}", contato.IdPessoa);
                throw;
            }
        }

        public async Task<bool> DeleteAsync(int id)
        {
            try
            {
                var contato = await _context.Contatos.FindAsync(id);
                if (contato == null)
                {
                    return false;
                }

                _context.Contatos.Remove(contato);
                await _context.SaveChangesAsync();
                _logger.LogInformation("Contato deletado com sucesso. ID: {Id}", id);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao deletar contato. ID: {Id}", id);
                throw;
            }
        }

        public async Task<bool> ExistsAsync(int id)
        {
            return await _context.Contatos.AnyAsync(c => c.IdPessoa == id);
        }

        public async Task<bool> EmailExistsAsync(string email, int? excludeId = null)
        {
            if (excludeId.HasValue)
            {
                return await _context.Contatos
                    .AnyAsync(c => c.Email == email && c.IdPessoa != excludeId.Value);
            }
            return await _context.Contatos.AnyAsync(c => c.Email == email);
        }
    }
}
