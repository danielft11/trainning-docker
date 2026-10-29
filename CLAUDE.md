# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**TrainningDocker** is an ASP.NET Core 8.0 Web API training project demonstrating containerization with Docker. It includes a basic WeatherForecast endpoint with Swagger documentation for API exploration and testing.

### Tech Stack
- **.NET 8.0** - Latest LTS version with nullable reference types and implicit usings enabled
- **ASP.NET Core** - Minimal hosting model via Program.cs (no Startup class)
- **Swagger/OpenAPI** - API documentation via Swashbuckle.AspNetCore 6.6.2
- **Docker** - Multi-stage containerization for production deployment
- **JSON serialization** - Newtonsoft.Json 13.0.4

## Build & Run Commands

### Local Development
```bash
# Restore dependencies and build
dotnet build

# Run the application (starts on configured port, typically 5000-5001)
dotnet run

# Swagger UI will be available at https://localhost:5000/swagger or http://localhost:5000/swagger
```

### Docker
```bash
# Build Docker image with name and version tag
docker build -t trainning-docker:v1 .

# Run container in detached mode with port mapping (host:container)
docker run -d --name trainning-docker -p 8080:8080 trainning-docker:v1

# Access the API at http://localhost:8080
# Swagger UI available at http://localhost:8080/swagger
```

### Testing (Once Added)
When unit tests are added, run with:
```bash
dotnet test
dotnet test --filter "ClassName" --verbosity normal
```

## Project Structure

```
TrainningDocker/
├── Controllers/                    # API endpoints
│   └── WeatherForecastController.cs
├── Program.cs                      # Dependency injection & middleware configuration
├── WeatherForecast.cs              # Data model for API responses
├── appsettings.json                # Configuration (logging, allowed hosts)
├── appsettings.Development.json    # Development-specific overrides
├── Dockerfile                      # Docker image definition (SDK-based build)
├── TrainningDocker.csproj          # Project file with NuGet references
└── TrainningDocker.http            # VS Code REST API requests file
```

## Architecture Notes

### Minimal Host Model
The application uses ASP.NET Core's minimal hosting setup:
- No Startup class — all configuration in Program.cs
- Services registered and middleware configured in a single file
- Controllers discovered automatically via `MapControllers()`

### API Controllers
Controllers inherit from `ControllerBase` (not `Controller`) — no View support needed for API-only projects.

### Docker Configuration
- **Base image**: `mcr.microsoft.com/dotnet/sdk:8.0` (includes build tools)
- **Port**: 8080 (configurable via ASPNETCORE_HTTP_PORTS environment variable)
- **Build phases**: Restore → Publish → Runtime execution
- **Entry point**: Runs the compiled .NET assembly

## Development Workflow

1. **Local iteration**: Use `dotnet run` for fast feedback with hot-reload capability
2. **Verify changes**: Test endpoints via Swagger UI at /swagger
3. **Docker validation**: Build and run locally with Docker to verify containerization
4. **Adding features**: Create controllers in `Controllers/` folder; models can go at project root or in a `Models/` folder

## Key Configuration Files

- **Program.cs**: Controls middleware pipeline, swagger generation, controller routing
- **appsettings.json**: Shared configuration (logging defaults)
- **Dockerfile**: Follows Docker best practices (restore → compile → publish pattern, multi-stage build ready)
