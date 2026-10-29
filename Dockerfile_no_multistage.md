# Dockerfile sem Multi-Stage

### Conceitos Fundamentais do Dockerfile

O arquivo ```Dockerfile_old``` define como construir uma imagem Docker da aplicação **sem utilizar o padrão multi-stage**. Isso significa que toda a aplicação (incluindo o SDK completo do .NET com ferramentas de build e compilação) é incluída na imagem final, resultando em uma imagem significativamente maior do que o necessário para apenas executar a aplicação. Aqui está uma explicação detalhada de cada etapa:

Vamos ver o arquivo completo do arquivo antes de estudarmos linha por linha:

```
FROM mcr.microsoft.com/dotnet/sdk:8.0

WORKDIR /app

COPY . .

RUN dotnet restore TrainningDocker.csproj

RUN dotnet publish TrainningDocker.csproj -c Release -o /app/publish

EXPOSE 8080

ENV ASPNETCORE_HTTP_PORTS=8080

ENTRYPOINT ["dotnet", "/app/publish/TrainningDocker.dll"]
```

#### 1. Definindo a Imagem Base

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0
```

Define a imagem base que será utilizada na construção. O SDK (Software Development Kit) contém ferramentas para desenvolver, compilar, testar e publicar aplicações .NET.

#### 2. Definindo o Diretório de Trabalho

```dockerfile
WORKDIR /app
```

Define o diretório de trabalho dentro da imagem. É semelhante a executar: `cd /app`

A partir daqui, comandos relativos serão executados considerando `/app` como o diretório atual.

#### 3. Copiando os Arquivos do Projeto

```dockerfile
COPY . .
```

- O primeiro ponto (`.`) significa copiar o conteúdo do contexto de build, que no nosso exemplo será a pasta TrainningDocker.
- O segundo ponto (`.`) representa o diretório de trabalho dentro da imagem, o `/app`.

#### 4. Restaurando as Dependências

```dockerfile
RUN dotnet restore TrainningDocker.csproj
```

Executa um comando durante a construção da imagem. Nesse caso, o Docker executa o `dotnet restore`, responsável por restaurar os pacotes NuGet necessários para a aplicação.

Por exemplo, se a API utiliza a biblioteca `Newtonsoft.Json`, as dependências serão restauradas nessa etapa. O resultado é incorporado ao estado da imagem em construção.

#### 5. Compilando e Publicando a Aplicação

```dockerfile
RUN dotnet publish TrainningDocker.csproj -c Release -o /app/publish
```

Essa instrução compila e publica nossa API.

**Explicação dos argumentos:**
- `dotnet publish` - Compila e prepara a aplicação para distribuição
- `TrainningDocker.csproj` - O projeto que será publicado
- `-c Release` - Usa a configuração Release (otimizada para produção)
- `-o /app/publish` - Define o diretório de saída

#### 6. Expondo a Porta

```dockerfile
EXPOSE 8080
```

Essa instrução documenta que o container foi projetado para utilizar a porta 8080. **Importante:** Ela não publica a porta automaticamente no computador host e não faz a aplicação começar a escutar nessa porta. Para publicar a porta, precisamos utilizar `-p` no comando `docker run`.

#### 7. Configurando Variáveis de Ambiente

```dockerfile
ENV ASPNETCORE_HTTP_PORTS=8080
```

Define uma variável de ambiente na imagem, disponível quando o container executar. Nesse caso, informamos ao ASP.NET Core que queremos utilizar a porta HTTP 8080. Essa variável pode ser sobrescrita na execução do container e outras configurações de URLs podem ter precedência sobre ela.

#### 8. Definindo o Comando de Inicialização

```dockerfile
ENTRYPOINT ["dotnet", "/app/publish/TrainningDocker.dll"]
```

Define o comando principal que será executado quando o container iniciar. É equivalente a executar: `dotnet /app/publish/TrainningDocker.dll`

**Diferença Fundamental:**
- `RUN` executa comandos durante o build da imagem.
- `ENTRYPOINT` define o comando que será executado quando o container iniciar.

Esse é um dos conceitos mais importantes para entender Dockerfiles.

### Construindo a Imagem Docker

Na pasta `TrainningDocker`, execute:

```bash
docker build -t trainning-docker:v1 .
```

**Significado dos parâmetros:**
- `docker build` - Constrói uma imagem
- `-t trainning-docker:v1` - Atribui nome e tag à imagem (format: `nome:versão`)
- `.` - Define o contexto de build como o diretório atual

### Executando o Container

Depois de construir a imagem, execute:

```bash
docker run -d --name trainning-docker -p 8080:8080 trainning-docker:v1
```

**Significado dos parâmetros:**
- `docker run` - Cria e executa um novo container
- `-d` - Executa o container em segundo plano (modo detach)
- `--name trainning-docker` - Nome do container que será criado
- `-p 8080:8080` - Estabelece o mapeamento de portas (porta do host : porta da aplicação)
- `trainning-docker:v1` - Nome e versão (tag) da imagem Docker que será utilizada

### Acessando a Aplicação

Assim que o container estiver executando, você poderá acessar sua API em

```
http://localhost:8080/swagger
```
### Qual é o problema desse Dockerfile?

O principal problema é que estamos utilizando a imagem sdk:8.0 para tudo.

Ela contém ferramentas que não são necessárias para executar uma API já publicada.

Imagine uma oficina mecânica.

Você precisa de várias ferramentas para construir um carro, mas não precisa levar todas elas dentro do veículo para conseguir dirigi-lo.

O mesmo acontece com o .NET.

O Dockerfile não otimizado também apresenta outros problemas: copia os arquivos do projeto antes de restaurar dependências, o que prejudica o aproveitamento do cache, e mantém arquivos de código-fonte e ferramentas de compilação na imagem final.

É justamente pra isso que existe o [Multi-stage Build](Dockerfile_with_multistage.md).
