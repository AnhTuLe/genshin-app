# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy solution file
COPY ["PriceArbitrage.sln", "."]

# Copy project files (for better layer caching)
COPY ["PriceArbitrage.API/PriceArbitrage.API.csproj", "PriceArbitrage.API/"]
COPY ["PriceArbitrage.Application/PriceArbitrage.Application.csproj", "PriceArbitrage.Application/"]
COPY ["PriceArbitrage.Domain/PriceArbitrage.Domain.csproj", "PriceArbitrage.Domain/"]
COPY ["PriceArbitrage.Infrastructure/PriceArbitrage.Infrastructure.csproj", "PriceArbitrage.Infrastructure/"]

# Restore dependencies
RUN dotnet restore "PriceArbitrage.sln"

# Copy everything else and build
COPY . .
RUN dotnet build "PriceArbitrage.sln" -c Release -o /app/build

# Publish stage
FROM build AS publish
WORKDIR /src/PriceArbitrage.API
RUN dotnet publish "PriceArbitrage.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 8080
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "PriceArbitrage.API.dll"]
