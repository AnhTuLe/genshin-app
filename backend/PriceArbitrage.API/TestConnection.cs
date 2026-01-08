using Microsoft.Data.SqlClient;

namespace PriceArbitrage.API;

public static class TestConnection
{
    public static void Test()
    {
        var connectionString = "Server=localhost,1433;Database=master;User Id=sa;Password=letuanh821993;TrustServerCertificate=true;";
        
        try
        {
            using var connection = new SqlConnection(connectionString);
            connection.Open();
            Console.WriteLine("✅ Kết nối SQL Server thành công!");
            
            using var command = new SqlCommand("SELECT @@VERSION", connection);
            var version = command.ExecuteScalar();
            Console.WriteLine($"SQL Server Version: {version}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Lỗi kết nối: {ex.Message}");
        }
    }
}
