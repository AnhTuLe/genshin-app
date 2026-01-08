using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using PriceArbitrage.Infrastructure.Data;

namespace PriceArbitrage.API.Data;

/// <summary>
/// Extension methods để quản lý database migrations và seeding
/// </summary>
public static class DatabaseExtensions
{
    /// <summary>
    /// Áp dụng migrations và seed dữ liệu ban đầu
    /// Chỉ chạy trong môi trường Development
    /// </summary>
    public static async Task<IApplicationBuilder> UseDatabaseMigrationAndSeedingAsync(
        this IApplicationBuilder app,
        bool isDevelopment = false)
    {
        using var scope = app.ApplicationServices.CreateScope();
        var services = scope.ServiceProvider;
        var logger = services.GetRequiredService<ILogger<ApplicationDbContext>>();

        try
        {
            var context = services.GetRequiredService<ApplicationDbContext>();

            // Áp dụng migrations tự động
            logger.LogInformation("Đang áp dụng database migrations...");
            await context.Database.MigrateAsync();
            logger.LogInformation("Database migrations đã được áp dụng thành công!");

            // Seed dữ liệu ban đầu (chỉ trong Development hoặc khi database trống)
            if (isDevelopment)
            {
                logger.LogInformation("Đang seed dữ liệu ban đầu...");
                
                var userManager = services.GetRequiredService<UserManager<IdentityUser>>();
                var roleManager = services.GetRequiredService<RoleManager<IdentityRole>>();

                await DatabaseSeeder.SeedAsync(context, userManager, roleManager);
                logger.LogInformation("Dữ liệu seed đã hoàn tất!");
            }
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Có lỗi xảy ra khi migrate hoặc seed database");
            throw;
        }

        return app;
    }

    /// <summary>
    /// Áp dụng migrations và seed dữ liệu (synchronous wrapper)
    /// </summary>
    public static IApplicationBuilder UseDatabaseMigrationAndSeeding(
        this IApplicationBuilder app,
        bool isDevelopment = false)
    {
        Task.Run(async () =>
        {
            await app.UseDatabaseMigrationAndSeedingAsync(isDevelopment);
        }).GetAwaiter().GetResult();

        return app;
    }
}
