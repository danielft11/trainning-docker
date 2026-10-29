# TrainningDocker

Uma API REST em ASP.NET Core 8.0 para fins de treinamento, demonstrando como containerizar uma aplicação .NET com Docker.

## Sobre o Projeto

Este é um projeto de treinamento que implementa uma simples API de Previsão do Tempo (WeatherForecast) em ASP.NET Core com suporte completo a Docker, permitindo aprender sobre:

- Containerização de aplicações .NET
- Configuração e deployment com Docker

## Configuração do Ambiente

### Pré-requisitos

- .NET 8.0 SDK instalado ([Download](https://dotnet.microsoft.com/en-us/download))
- Docker instalado (opcional, apenas para containerização)
- Um editor de código (Visual Studio Code, Visual Studio, etc.)

### Instalação Local

1. Clone ou extraia o repositório
2. Navegue até o diretório do projeto
3. Restaure as dependências:

```bash
dotnet restore
```

## Executando o Projeto

### Método 1: Execução Direta (.NET)

```bash
dotnet run
```

A aplicação iniciará em:
- **HTTP**: http://localhost:5000
- **HTTPS**: https://localhost:5001

Acesse o Swagger em: http://localhost:5000/swagger

### Método 2: Build e Execução com Dotnet

```bash
# Compilar o projeto
dotnet build

# Executar o projeto compilado
dotnet run
```

## Docker - Tutorial Completo

> 📄 **[Dockerfile sem Multi-Stage](Dockerfile_no_multistage.md)** - Documentação detalhada sobre o Dockerfile atual (modelo simples sem build multi-stage)
> 
> 📄 **[Dockerfile com Multi-Stage Build](Dockerfile_with_multistage.md)** - Versão otimizada com build multi-stage para reduzir o tamanho da imagem

### Comandos Docker Úteis

```bash
# Listar imagens Docker
docker images

# Listar containers em execução
docker ps

# Listar todos os containers (incluindo parados)
docker ps -a

# Ver logs de um container
docker logs trainning-docker

# Parar um container
docker stop trainning-docker

# Iniciar um container parado
docker start trainning-docker

# Remover um container (deve estar parado)
docker rm trainning-docker

# Remover uma imagem (nenhum container deve estar usando)
docker rmi trainning-docker:v1
```

Este projeto foi construído para demonstrar:

- ✅ Containerização com Docker
- ✅ Boas práticas de configuração de Dockerfile

## Solução de Problemas

### Porta já está em uso
Se receber erro que a porta está em uso, altere o mapeamento:
```bash
docker run -d --name trainning-docker -p 8081:8080 trainning-docker:v1
```

### Container não inicia
Verifique os logs:
```bash
docker logs trainning-docker
```

### Acesso negado ao Docker
Em Linux, adicione seu usuário ao grupo docker:
```bash
sudo usermod -aG docker $USER
```

## Autor

Daniel Fernando 

---

**Última atualização:** Outubro de 2026
