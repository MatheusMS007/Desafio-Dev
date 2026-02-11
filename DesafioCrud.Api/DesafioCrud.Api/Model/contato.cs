using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DesafioCrud.Api.Model
{
    [Table("Contatos")]
    public class Contato
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int IdPessoa { get; set; }

        [Required(ErrorMessage = "* Nome é obrigatório")]
        [StringLength(200, ErrorMessage = "* Nome não pode exceder 200 caracteres")]
        public string Nome { get; set; }

        [Required(ErrorMessage = "* Data de nascimento é obrigatória")]
        [DataType(DataType.Date)]
        public DateTime DataNasc { get; set; }

        [StringLength(200, ErrorMessage = "* Observação não pode exceder 200 caracteres")]
        public string Obs { get; set; }

        [Required(ErrorMessage = "* Telefone deve conter 11 números")]
        [Phone(ErrorMessage = "Formato de telefone inválido")]
        [StringLength(11, ErrorMessage = "* Telefone deve ter 11 números")]
        public string Telefone { get; set; }

        [Required(ErrorMessage = "* Email é obrigatório")]
        [EmailAddress(ErrorMessage = "Formato de email inválido")]
        [StringLength(200)]
        public string Email { get; set; }

        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public DateTime DataCriacao { get; set; } = DateTime.UtcNow;

        public DateTime? DataAtualizacao { get; set; }
    }
}