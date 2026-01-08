using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace PriceArbitrage.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DatabaseTestController : ControllerBase
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<DatabaseTestController> _logger;

    public DatabaseTestController(IConfiguration configuration, ILogger<DatabaseTestController> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    /// <summary>
    /// Kiểm tra kết nối đến SQL Server
    /// </summary>
    [HttpGet("connection")]
    public IActionResult TestConnection()
    {
        try
        {
            var connectionString = _configuration.GetConnectionString("DefaultConnection");
            
            if (string.IsNullOrEmpty(connectionString))
            {
                return BadRequest(new
                {
                    status = "error",
                    message = "Connection string không được cấu hình"
                });
            }

            using var connection = new SqlConnection(connectionString);
            connection.Open();

            var serverVersion = connection.ServerVersion;
            var database = connection.Database;
            var dataSource = connection.DataSource;
            var state = connection.State.ToString();

            // Kiểm tra database có tồn tại không
            var dbExists = false;
            try
            {
                using var checkCommand = new SqlCommand(
                    "SELECT COUNT(*) FROM sys.databases WHERE name = @dbName", 
                    connection);
                checkCommand.Parameters.AddWithValue("@dbName", database);
                dbExists = (int)checkCommand.ExecuteScalar() > 0;
            }
            catch
            {
                // Nếu không thể check (có thể đang connect đến master)
                dbExists = database == "master";
            }

            return Ok(new
            {
                status = "success",
                message = "Kết nối database thành công!",
                details = new
                {
                    server = dataSource,
                    database = database,
                    serverVersion = serverVersion,
                    connectionState = state,
                    databaseExists = dbExists,
                    timestamp = DateTime.UtcNow
                }
            });
        }
        catch (SqlException ex)
        {
            _logger.LogError(ex, "Lỗi SQL khi kết nối database");
            return StatusCode(500, new
            {
                status = "error",
                message = "Lỗi kết nối SQL Server",
                error = new
                {
                    type = "SqlException",
                    message = ex.Message,
                    number = ex.Number,
                    state = ex.State,
                    class_ = ex.Class
                }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi khi kiểm tra database connection");
            return StatusCode(500, new
            {
                status = "error",
                message = "Lỗi không xác định",
                error = new
                {
                    type = ex.GetType().Name,
                    message = ex.Message
                }
            });
        }
    }

    /// <summary>
    /// Kiểm tra danh sách databases
    /// </summary>
    [HttpGet("databases")]
    public IActionResult GetDatabases()
    {
        try
        {
            var connectionString = _configuration.GetConnectionString("DefaultConnection");
            
            if (string.IsNullOrEmpty(connectionString))
            {
                return BadRequest(new { status = "error", message = "Connection string không được cấu hình" });
            }

            // Kết nối đến master để lấy danh sách databases
            var masterConnectionString = connectionString.Replace(
                "Database=PriceArbitrageDB", 
                "Database=master");

            using var connection = new SqlConnection(masterConnectionString);
            connection.Open();

            var databases = new List<object>();
            using var command = new SqlCommand("SELECT name, database_id, create_date FROM sys.databases ORDER BY name", connection);
            using var reader = command.ExecuteReader();

            while (reader.Read())
            {
                databases.Add(new
                {
                    name = reader["name"].ToString(),
                    id = reader["database_id"],
                    createDate = reader["create_date"]
                });
            }

            return Ok(new
            {
                status = "success",
                count = databases.Count,
                databases = databases
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi khi lấy danh sách databases");
            return StatusCode(500, new
            {
                status = "error",
                message = ex.Message
            });
        }
    }

    /// <summary>
    /// Kiểm tra tables trong database PriceArbitrageDB
    /// </summary>
    [HttpGet("tables")]
    public IActionResult GetTables()
    {
        try
        {
            var connectionString = _configuration.GetConnectionString("DefaultConnection");
            
            if (string.IsNullOrEmpty(connectionString))
            {
                return BadRequest(new { status = "error", message = "Connection string không được cấu hình" });
            }

            using var connection = new SqlConnection(connectionString);
            connection.Open();

            var tables = new List<object>();
            using var command = new SqlCommand(
                "SELECT TABLE_NAME, TABLE_TYPE FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME",
                connection);
            using var reader = command.ExecuteReader();

            while (reader.Read())
            {
                tables.Add(new
                {
                    name = reader["TABLE_NAME"].ToString(),
                    type = reader["TABLE_TYPE"].ToString()
                });
            }

            return Ok(new
            {
                status = "success",
                database = connection.Database,
                count = tables.Count,
                tables = tables
            });
        }
        catch (SqlException ex) when (ex.Number == 4060)
        {
            return NotFound(new
            {
                status = "error",
                message = $"Database không tồn tại: {ex.Message}",
                suggestion = "Tạo database bằng lệnh: CREATE DATABASE PriceArbitrageDB"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi khi lấy danh sách tables");
            return StatusCode(500, new
            {
                status = "error",
                message = ex.Message
            });
        }
    }
}
