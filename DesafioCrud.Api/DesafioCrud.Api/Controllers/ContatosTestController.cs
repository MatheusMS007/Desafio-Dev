using Microsoft.AspNetCore.Mvc;
using DesafioCrud.Api.Model;
using System.Collections.Generic;
using System.Linq;

namespace DesafioCrud.Api.Controllers
{
    [ApiController]
    [Route("api/contatos")]
    public class ContatosTestController : ControllerBase
    {
        private static List<Contato> _contatos = new List<Contato>
        {
            new Contato { IdPessoa = 1, Nome = "João Silva", Telefone = "(11) 98765-4321", Email = "joao@email.com" },
            new Contato { IdPessoa = 2, Nome = "Maria Santos", Telefone = "(21) 99876-5432", Email = "maria@email.com" },
            new Contato { IdPessoa = 3, Nome = "Pedro Oliveira", Telefone = "(31) 97654-3210", Email = "pedro@email.com" }
        };
        private static int _nextId = 4;

        [HttpGet]
        public ActionResult<IEnumerable<Contato>> GetAll()
        {
            return Ok(_contatos);
        }

        [HttpGet("{id}")]
        public ActionResult<Contato> GetById(int id)
        {
            var contato = _contatos.FirstOrDefault(c => c.IdPessoa == id);
            if (contato == null)
                return NotFound();
            return Ok(contato);
        }

        [HttpPost]
        public ActionResult<Contato> Create([FromBody] Contato contato)
        {
            contato.IdPessoa = _nextId++;
            _contatos.Add(contato);
            return CreatedAtAction(nameof(GetById), new { id = contato.IdPessoa }, contato);
        }

        [HttpPut("{id}")]
        public ActionResult<Contato> Update(int id, [FromBody] Contato contato)
        {
            var index = _contatos.FindIndex(c => c.IdPessoa == id);
            if (index == -1)
                return NotFound();
            
            contato.IdPessoa = id;
            _contatos[index] = contato;
            return Ok(contato);
        }

        [HttpDelete("{id}")]
        public ActionResult Delete(int id)
        {
            var contato = _contatos.FirstOrDefault(c => c.IdPessoa == id);
            if (contato == null)
                return NotFound();
            
            _contatos.Remove(contato);
            return NoContent();
        }
    }
}
