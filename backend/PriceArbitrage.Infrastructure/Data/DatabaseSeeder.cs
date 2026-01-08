using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace PriceArbitrage.Infrastructure.Data;

/// <summary>
/// Class để seed dữ liệu ban đầu vào database
/// Chạy tự động khi ứng dụng khởi động lần đầu
/// </summary>
public static class DatabaseSeeder
{
    /// <summary>
    /// Seed dữ liệu ban đầu cho database
    /// Lưu ý: Database migrations phải được apply trước khi gọi method này
    /// </summary>
    public static async Task SeedAsync(ApplicationDbContext context, UserManager<IdentityUser> userManager, RoleManager<IdentityRole> roleManager)
    {
        // Seed Roles trước (vì Users cần Roles)
        await SeedRolesAsync(roleManager);

        // Seed Users
        await SeedUsersAsync(userManager);

        // Seed các dữ liệu khác (Products, Categories, v.v.)
        await SeedApplicationDataAsync(context);

        // Lưu tất cả thay đổi (nếu có thay đổi trong SeedApplicationDataAsync)
        await context.SaveChangesAsync();
    }

    /// <summary>
    /// Seed các Roles cơ bản
    /// </summary>
    private static async Task SeedRolesAsync(RoleManager<IdentityRole> roleManager)
    {
        var roles = new[] { "Admin", "User", "Moderator" };

        foreach (var roleName in roles)
        {
            var roleExists = await roleManager.RoleExistsAsync(roleName);
            if (!roleExists)
            {
                await roleManager.CreateAsync(new IdentityRole(roleName));
            }
        }
    }

    /// <summary>
    /// Seed các Users mẫu
    /// </summary>
    private static async Task SeedUsersAsync(UserManager<IdentityUser> userManager)
    {
        // Tạo Admin user
        var adminEmail = "admin@example.com";
        var adminUser = await userManager.FindByEmailAsync(adminEmail);
        if (adminUser == null)
        {
            adminUser = new IdentityUser
            {
                UserName = "admin",
                Email = adminEmail,
                EmailConfirmed = true
            };

            var result = await userManager.CreateAsync(adminUser, "Admin@123");
            if (result.Succeeded)
            {
                await userManager.AddToRoleAsync(adminUser, "Admin");
            }
        }

        // Tạo User mẫu
        var userEmail = "user@example.com";
        var normalUser = await userManager.FindByEmailAsync(userEmail);
        if (normalUser == null)
        {
            normalUser = new IdentityUser
            {
                UserName = "user",
                Email = userEmail,
                EmailConfirmed = true
            };

            var result = await userManager.CreateAsync(normalUser, "User@123");
            if (result.Succeeded)
            {
                await userManager.AddToRoleAsync(normalUser, "User");
            }
        }
    }

    /// <summary>
    /// Seed các dữ liệu ứng dụng khác
    /// (Products, Categories, PriceHistory, v.v.)
    /// TODO: Thêm các entities và seed data tùy theo nhu cầu
    /// </summary>
    private static async Task SeedApplicationDataAsync(ApplicationDbContext context)
    {
        // Ví dụ: Nếu bạn có Product entity:
        // var productsExist = await context.Products.AnyAsync();
        // if (!productsExist)
        // {
        //     context.Products.AddRange(new[]
        //     {
        //         new Product { Name = "Product 1", Price = 100 },
        //         new Product { Name = "Product 2", Price = 200 }
        //     });
        //     await context.SaveChangesAsync();
        // }

        // Tạm thời không có data để seed, bạn có thể thêm sau
        await Task.CompletedTask;
    }
}
