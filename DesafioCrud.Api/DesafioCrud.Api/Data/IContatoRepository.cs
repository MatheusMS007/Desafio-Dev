using DesafioCrud.Api.Model;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DesafioCrud.Api.Data
{
    public interface IContatoRepository
    {
        Task<IEnumerable<Contato>> GetAllAsync();
        Task<Contato> GetByIdAsync(int id);
        Task<Contato> GetByEmailAsync(string email);
        Task<Contato> CreateAsync(Contato contato);
        Task<Contato> UpdateAsync(Contato contato);
        Task<bool> DeleteAsync(int id);
        Task<bool> ExistsAsync(int id);
        Task<bool> EmailExistsAsync(string email, int? excludeId = null);
    }
}
