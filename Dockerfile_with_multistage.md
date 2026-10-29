# Dockerfile com Multi-Stage

### Conceitos Fundamentais do Dockerfile

#### O que é Multi-stage Build?

Multi-stage Build é uma técnica que permite utilizar múltiplos estágios de construção dentro do mesmo Dockerfile.

Podemos utilizar um estágio para compilar a aplicação e outro para executá-la.

A grande vantagem é que podemos copiar apenas o resultado necessário do estágio de compilação para o estágio final.

O arquivo ```Dockerfile``` define como construir uma imagem Docker da aplicação **utilizando o padrão multi-stage**. 

Vamos ver o arquivo completo do arquivo antes de estudarmos linha por linha:

```
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
```

#### Estágio 1 — Build

Imagem: .NET SDK 8

Restaura dependências, compila e publica a API.

**Resultado**: arquivos publicados em /app/publish.

Copia apenas os arquivos publicados.

#### 1. Definindo a Imagem Base

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
```

Continuamos utilizando o SDK, mas acrescentamos ```AS build```. Isso atribui o nome ```build``` ao estágio. Podemos referenciá-lo 
posteriormente utilizando esse nome.

#### 2. Definindo o Diretório de Trabalho

```dockerfile
WORKDIR /src
```
Define ```/src``` como diretório de trabalho do estágio de compilação.

#### 3. Copiando os Arquivos do Projeto

```dockerfile
COPY ["TrainningDocker.csproj", "."]
```

Aqui está uma otimização muito importante.

Em vez de copiar todos os arquivos, estamos copiando inicialmente apenas o arquivo .csproj.

Por quê?

Porque queremos restaurar as dependências antes de copiar o código-fonte.

Assim, quando alteramos somente um controller, por exemplo, o Docker pode reutilizar o resultado da restauração de dependências.

Vamos separar:

- TrainningDocker.csproj: arquivo de origem, localizado no contexto de build.
- . : diretório de destino, relativo ao WORKDIR ```/src``` definido anteriormente.

#### 4. Restaurando as Dependências

``` dockerfile 
RUN dotnet restore "TrainningDocker.csproj"
```

Restaura os pacotes NuGet.

Se o .csproj e os demais insumos relevantes para essa etapa não mudaram, o Docker poderá reutilizar o cache desse passo.

#### 5. Copiando os demais arquivos

``` dockerfile 
COPY . .
```

Agora copiamos o restante do código-fonte para o estágio de build.

Isso inclui nossos controllers, Program.cs e outros arquivos permitidos pelo contexto de build.


#### 6. Compilando e Publicando a Aplicação

```dockerfile
RUN dotnet publish "TrainningDocker.csproj" -c Release -o /app/publish --no-restore
```

Publicamos a aplicação.

A novidade é ```--no-restore```. Esse argumento informa que não queremos executar novamente a restauração de dependências, 
porque já fizemos isso anteriormente. Essa separação permite um melhor aproveitamento do cache.

#### Estágio 2 — Runtime

Imagem: ASP.NET Core Runtime 8

Recebe a publicação e executa a API, sem precisar do SDK.

O estágio de build não passa a fazer parte da imagem final. Ele serve para produzir os arquivos que serão utilizados pelo 
último estágio.

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
```

Aqui começamos um novo estágio.

Diferentemente do primeiro, agora utilizamos a imagem aspnet:8.0.

Ela contém o runtime necessário para executar aplicações ASP.NET Core, mas não o SDK completo.

O nome runtime identifica esse estágio.


```dockerfile
WORKDIR /app
```

Define o diretório de trabalho do estágio final.

```dockerfile
COPY --from=build /app/publish .
```

Essa é a instrução central do Multi-stage Build.

Vamos separar:
- COPY => copia arquivos.
- --from=build => origem: estágio chamado build.
- /app/publish => diretório de origem naquele estágio.
- .=> Destino: /app no estágio atual.

Ou seja, copiamos somente os arquivos publicados do estágio de compilação para a imagem final.

Não copiamos o SDK, nem os diretórios completos do projeto.

#### Expondo a Porta e configurando variável de ambiente

```dockerfile
EXPOSE 8080

ENV ASPNETCORE_HTTP_PORTS=8080
```

Continuam com as mesmas responsabilidades: documentar a porta e configurar o ASP.NET Core para escutar nela.

#### 8. Definindo o Comando de Inicialização

ENTRYPOINT ["dotnet", "TrainningDocker.dll"]

Executa nossa API.

Observe que agora utilizamos apenas TrainningDocker.dll, pois o WORKDIR está definido como /app, onde copiamos os 
arquivos publicados.

#### Entendendo o cache do Docker

Esse é um dos pontos mais importantes da otimização.

Imagine que você alterou somente o arquivo ProdutosController.cs.

No Dockerfile não otimizado, temos:

```dockerfile
COPY . .
RUN dotnet restore TrainningDocker.csproj
```

Como o COPY . . percebe alterações no código-fonte, o cache dessa instrução é invalidado. Isso pode fazer com que o Docker execute novamente a restauração de dependências.

Já no Dockerfile otimizado:

```dockerfile
COPY ["TrainningDocker.csproj", "."]

RUN dotnet restore "TrainningDocker.csproj"

COPY . .
```

A situação é diferente:

**Alterei apenas ProdutosController.cs**: 

Resultado esperado do cache:

- COPY MinhaApi.csproj: cache reutilizado

- RUN dotnet restore: cache reutilizado

- COPY . . :executa novamente

- RUN dotnet publish: executa novamente

**Alterei as dependências no MinhaApi.csproj**:

Resultado esperado do cache:

- COPY MinhaApi.csproj: executa novamente

- RUN dotnet restore: executa novamente

- COPY . . :executa novamente

- RUN dotnet publish: executa novamente

*Simulação simplificada, supondo cache disponível e nenhuma outra alteração nos insumos do build.*

É por isso que a ordem das instruções de um Dockerfile importa tanto.

O Docker consegue reutilizar resultados de etapas anteriores quando seus insumos relevantes permanecem inalterados.

#### Comparando as duas abordagens

| Característica               | Sem Multi-stage     | Com Multi-stage    |
|------------------------------|---------------------|--------------------|
| Imagem final                 | SDK completo        | ASP.NET Runtime    |
| Código-fonte na imagem final | Sim                 | Não, em geral      |
| Ferramentas de compilação    | Presentes           | Ausentes           |
| Cache do restore             | Pouco eficiente     | Mais eficiente     |
| Tamanho da imagem            | Maior               | Menor              |
| Superfície de ataque         | Geralmente maior    | Geralmente menor   |
| Indicado para produção       | Evitar              | Sim                |

#### Um detalhe importante: .dockerignore

Existe outra otimização que vale conhecer.

Crie um arquivo chamado .dockerignore na raiz da solução:

```.dockerignore
**/bin/
**/obj/
.git/
.vs/
.vscode/
**/TestResults/
Dockerfile*
```

Esse arquivo informa ao Docker quais arquivos não devem ser enviados no contexto de build.

Por exemplo, não precisamos copiar as pastas bin e obj produzidas por compilações locais, pois vamos compilar a aplicação novamente
dentro do Docker.

Isso reduz a quantidade de arquivos enviados ao processo de build e evita que arquivos locais interfiram na construção.

Em soluções maiores, também é importante copiar antes do restore arquivos como NuGet.Config, Directory.Packages.props, Directory.Build.props e projetos referenciados, quando existirem. Caso contrário, a estratégia de cache ou o próprio restore podem falhar.