FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src

COPY ["TrainningDocker.csproj", "."]

RUN dotnet restore "TrainningDocker.csproj"

COPY . .

RUN dotnet publish "TrainningDocker.csproj" -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime

WORKDIR /app

COPY --from=build /app/publish .

EXPOSE 8080

ENV ASPNETCORE_HTTP_PORTS=8080

ENTRYPOINT ["dotnet", "TrainningDocker.dll"]
