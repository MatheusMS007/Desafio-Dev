using Microsoft.EntityFrameworkCore;
using DesafioCrud.Api.Model;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace DesafioCrud.Api.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<Contato> Contatos { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configurações adicionais de segurança e performance
            modelBuilder.Entity<Contato>(entity =>
            {
                entity.HasKey(e => e.IdPessoa);
                
                entity.Property(e => e.Nome)
                    .IsRequired()
                    .HasMaxLength(200);

                entity.Property(e => e.Email)
                    .IsRequired()
                    .HasMaxLength(200);

                entity.Property(e => e.Telefone)
                    .IsRequired()
                    .HasMaxLength(20);

                entity.Property(e => e.Obs)
                    .HasMaxLength(1000);

                entity.Property(e => e.DataCriacao)
                    .HasDefaultValueSql("GETUTCDATE()");

                // Índices para performance
                entity.HasIndex(e => e.Email)
                    .IsUnique()
                    .HasDatabaseName("IX_Contatos_Email");

                entity.HasIndex(e => e.Telefone)
                    .HasDatabaseName("IX_Contatos_Telefone");
            });
        }

        public override int SaveChanges()
        {
            UpdateTimestamps();
            return base.SaveChanges();
        }

        public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            UpdateTimestamps();
            return await base.SaveChangesAsync(cancellationToken);
        }

        private void UpdateTimestamps()
        {
            var entries = ChangeTracker.Entries()
                .Where(e => e.Entity is Contato && (e.State == EntityState.Modified));

            foreach (var entry in entries)
            {
                ((Contato)entry.Entity).DataAtualizacao = DateTime.UtcNow;
            }
        }
    }
}
