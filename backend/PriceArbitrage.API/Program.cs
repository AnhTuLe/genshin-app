using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using PriceArbitrage.API.Data;
using PriceArbitrage.API.Models;
using PriceArbitrage.Application.Interfaces;
using PriceArbitrage.Infrastructure.Data;
using PriceArbitrage.Infrastructure.Services;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Price Arbitrage API",
        Version = "v1",
        Description = "API cho ứng dụng Price Arbitrage",
        Contact = new OpenApiContact
        {
            Name = "Price Arbitrage Team"
        }
    });

    // Thêm JWT Authentication vào Swagger
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Example: \"Authorization: Bearer {token}\"",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// Add DbContext
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Add Identity Services
builder.Services.AddIdentity<IdentityUser, IdentityRole>(options =>
{
    // Password requirements
    options.Password.RequireDigit = true;
    options.Password.RequiredLength = 8;
    options.Password.RequireUppercase = true;
    options.Password.RequireLowercase = true;
    options.Password.RequireNonAlphanumeric = true;
    
    // User settings
    options.User.RequireUniqueEmail = true;
    
    // Lockout settings
    options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(5);
    options.Lockout.MaxFailedAccessAttempts = 5;
})
.AddEntityFrameworkStores<ApplicationDbContext>()
.AddDefaultTokenProviders();

// Cấu hình JWT Settings
var jwtSettings = builder.Configuration.GetSection("JwtSettings").Get<JwtSettings>()
    ?? new JwtSettings
    {
        SecretKey = builder.Configuration["JwtSettings:SecretKey"] ?? "YourVeryLongAndSecureSecretKeyForJWTTokenGeneration2024!@#$%^&*()MustBeAtLeast32Characters",
        Issuer = builder.Configuration["JwtSettings:Issuer"] ?? "PriceArbitrageAPI",
        Audience = builder.Configuration["JwtSettings:Audience"] ?? "PriceArbitrageClient",
        ExpirationMinutes = int.TryParse(builder.Configuration["JwtSettings:ExpirationMinutes"], out var exp) ? exp : 60
    };

// Cấu hình JWT Authentication
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings.Issuer,
        ValidAudience = jwtSettings.Audience,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings.SecretKey)),
        ClockSkew = TimeSpan.Zero // Không cho phép clock skew
    };
});

// Đăng ký AuthService
builder.Services.AddScoped<IAuthService, AuthService>();

// Add Health Checks
builder.Services.AddHealthChecks()
    .AddSqlServer(
        connectionString: builder.Configuration.GetConnectionString("DefaultConnection") ?? "",
        name: "sqlserver",
        failureStatus: HealthStatus.Unhealthy,
        tags: new[] { "db", "sql", "sqlserver" });

// Cấu hình CORS để cho phép Frontend React gọi API
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowReactApp", policy =>
    {
        var corsOrigins = builder.Configuration.GetSection("CorsOrigins").Get<string[]>();
        
        if (corsOrigins != null && corsOrigins.Length > 0)
        {
            // Production: sử dụng origins từ cấu hình
            policy.WithOrigins(corsOrigins);
        }
        else
        {
            // Development: cho phép localhost
            policy.WithOrigins("http://localhost:3000", "http://localhost:5173");
        }
        
        policy.AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

var app = builder.Build();

// Tự động apply migrations và seed dữ liệu khi start (chỉ trong Development)
var isDevelopment = app.Environment.IsDevelopment();
await app.UseDatabaseMigrationAndSeedingAsync(isDevelopment);

// Configure the HTTP request pipeline.
if (isDevelopment)
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// Sử dụng CORS
app.UseCors("AllowReactApp");

app.UseAuthentication(); // Thêm Authentication middleware (cần trước Authorization)
app.UseAuthorization();

app.MapControllers();

// Map Health Check endpoint
app.MapHealthChecks("/health");

app.Run();

