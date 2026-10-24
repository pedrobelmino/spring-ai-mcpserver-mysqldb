# AGENTS.md — spring-ai-mcpserver-mysqldb

Servidor MCP (Model Context Protocol) em Spring AI + WebFlux que expõe metadados de um MySQL
(tabelas, colunas, tipos, tamanhos) como ferramenta para LLMs. Transporte SSE em `/sse`, com
mensagens em `/mcp/message`. Inclui `schema.sql` de um domínio de anúncios de veículos.

## Stack (lida de pom.xml / docker-compose)

- Java 21 (`<java.version>21</java.version>`)
- Spring Boot 4.0.0 (parent)
- Spring AI BOM 2.0.0-SNAPSHOT + `spring-ai-starter-mcp-server-webflux`
- `spring-boot-starter-data-jpa`
- `mysql-connector-java` 8.0.33 (coordenada legada, `mysql:mysql-connector-java`)
- MySQL 8.0 (container `mysql-db`)
- Maven wrapper presente (`./mvnw`, Maven 3.9.6)
- Coordenadas: `br.com.pedrobemino.mcpserver.mysqldb` / `spring-ai-mcpserver-mysqldb` / `0.0.1-SNAPSHOT`

## Comandos

- build: `./mvnw clean package`
- test: `./mvnw test`  (não existe nenhum teste no projeto)
- run: `./mvnw spring-boot:run`  (porta 8080)
- banco: `cd docker-compose && docker compose up -d`
- lint: não existe no projeto

## Estrutura

- `src/main/java/br/com/pedrobemino/mcpserver/mysqldb/` — `McpServerApplication` (main, registra os `ToolCallbackProvider`)
- `.../mysql.../MetamodelToolsService.java` — a única tool: `@Tool getMetamodel()` via `DatabaseMetaData`
- `src/main/resources/application.properties` — datasource, nome/versão/tipo do servidor MCP, endpoints SSE
- `docker-compose/docker-compose.yml` — MySQL 8 com credenciais vindas de env
- `docker-compose/schema.sql` — DDL carregado em `/docker-entrypoint-initdb.d`
- `postman/postman-mcpserver.png` — imagem de apoio (sem collection `.json`)

## Convenções observadas

- Pacote `br.com.pedrobemino.mcpserver.mysqldb` (grafia "bemino", diferente do resto do portfólio) —
  manter, renomear quebraria imports e o nome da aplicação.
- Injeção por construtor; `JdbcTemplate` montado à mão a partir do `DataSource`.
- `@Tool(description = ...)` em inglês, curto — é o texto que o LLM lê.
- `SQLException` é encapsulada em `RuntimeException`; não há handler global.
- Saída da tool é texto plano formatado (`Table:` / `\tColumn: ..., Type: ..., Size: ...`).

## Regras

- Credencial de banco só por variável de ambiente (`MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`,
  `MYSQL_USER`, `MYSQL_PASSWORD`). Não comitar `.env`.
- `application.properties` hoje tem usuário/senha literais (`user`/`password`) — não replicar
  esse padrão em código novo; o correto é `${...}`.
- Não mudar nome, assinatura ou descrição da tool `getMetamodel` sem avisar quem consome:
  é contrato estável para clientes MCP (Postman, IDEs, agentes).

## Pegadinhas reais

- O `pom.xml` depende de `spring-ai` 2.0.0-SNAPSHOT: o build exige os repositórios de snapshot
  declarados (`Spring Milestones`, `Spring Snapshots`, `Central Portal Snapshots`) e rede. Offline, quebra.
- URL do datasource aponta para `jdbc:mysql://localhost:3306/mysql_db`, mas o banco criado pelo
  compose é o valor de `MYSQL_DATABASE`. Se os nomes divergirem, o `schema.sql` entra em outro schema
  e a tool devolve lista vazia — sem erro.
- `schema.sql` só roda no primeiro boot do volume (`mysql-data`). Mudou o DDL? `docker compose down -v`
  antes de subir de novo. O compose monta `../schema.sql`, então ele precisa ser executado de dentro de `docker-compose/`.
- O compose não tem healthcheck e a aplicação não espera o MySQL: suba o banco, espere aceitar conexão
  e só então rode o `spring-boot:run`.
- Porta 3306 é fixa no host e colide com qualquer MySQL local.
- Endpoint MCP: SSE em `/sse`, mensagens em `/mcp/message`; `spring.ai.mcp.server.stdio=false`.
  Cliente errado (esperando stdio) fica pendurado sem erro claro.
