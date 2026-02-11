using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.OpenApi.Models;
using Microsoft.EntityFrameworkCore;
using DesafioCrud.Api.Data;

namespace DesafioCrud.Api
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        
        public void ConfigureServices(IServiceCollection services)
        {
          
            services.AddDbContext<AppDbContext>(options =>
            {
                options.UseSqlServer(
                    Configuration.GetConnectionString("DefaultConnection"),
                    sqlServerOptions =>
                    {
                        sqlServerOptions.EnableRetryOnFailure(
                            maxRetryCount: 5,
                            maxRetryDelay: TimeSpan.FromSeconds(30),
                            errorNumbersToAdd: null
                        );
                        sqlServerOptions.CommandTimeout(30);
                    }
                );
                
               
                if (Configuration.GetValue<bool>("EnableSensitiveDataLogging"))
                {
                    options.EnableSensitiveDataLogging();
                }
            });

            
            services.AddScoped<IContatoRepository, ContatoRepository>();

            
            services.AddCors(options =>
            {
                options.AddPolicy("AllowSpecificOrigins", builder =>
                {
                    builder.WithOrigins(Configuration.GetSection("AllowedOrigins").Get<string[]>() ?? new[] { "http://localhost:4201", "http://localhost:3000" })
                           .AllowAnyMethod()
                           .AllowAnyHeader()
                           .AllowCredentials();
                });
            });

            services.AddControllers()
                .ConfigureApiBehaviorOptions(options =>
                {
                    
                    options.InvalidModelStateResponseFactory = context =>
                    {
                        var errors = context.ModelState
                            .Where(e => e.Value.Errors.Count > 0)
                            .Select(e => new
                            {
                                Field = e.Key,
                                Errors = e.Value.Errors.Select(x => x.ErrorMessage).ToArray()
                            });

                        return new BadRequestObjectResult(new
                        {
                            message = "Erro de validação",
                            errors = errors
                        });
                    };
                });

            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new OpenApiInfo 
                { 
                    Title = "DesafioCrud API", 
                    Version = "v1",
                    Description = "API para gerenciamento de contatos com SQL Server",
                    Contact = new OpenApiContact
                    {
                        Name = "Equipe de Desenvolvimento",
                        Email = "dev@example.com"
                    }
                });
            });

          
            services.AddHealthChecks()
                .AddDbContextCheck<AppDbContext>("database");
        }

       
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
                app.UseSwagger();
                app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "DesafioCrud.Api v1"));
            }

            app.UseRouting();

            app.UseCors("AllowSpecificOrigins");

            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
                endpoints.MapHealthChecks("/health");
            });
        }
    }
}
