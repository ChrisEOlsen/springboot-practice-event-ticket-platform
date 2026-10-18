# Spring Boot + Angular + PostgreSQL template

A local development foundation with three Docker Compose services. Generate the application sources and add the Dockerfiles below before starting Compose.

## 1. Create the root directory and clone

Install Git, Docker with Compose, a JDK matching your selected Spring Boot version, and Node.js/npm compatible with your Angular version. See the [Angular setup requirements](https://angular.dev/tools/cli/setup-local).

Replace `<repository-url>` with your template repository URL:

```sh
mkdir angular-springboot-template
git clone <repository-url> angular-springboot-template
cd angular-springboot-template
```

If you already cloned this repository, start in its root directory.

## 2. Generate the backend using Spring Initializr

1. Open [Spring Initializr](https://start.spring.io/).
2. Select **Maven**, **Java**, a stable Spring Boot release, **Jar** packaging, and **Java 25**. Choose a Boot release supporting Java 25.
3. Set your group/package name and use `backend` as the artifact name.
4. Add **Spring Web**, **Spring Data JPA**, and **PostgreSQL Driver**. Consult [dependency-cheatsheet.md](dependency-cheatsheet.md) for optional dependencies.
5. Click **Generate**, extract the downloaded ZIP, and move the extracted project into this repository as `backend/`.
6. Ensure `backend/pom.xml`, `backend/mvnw`, and `backend/src/` exist directly inside `backend/`, without an extra nested project folder.

Create `backend/Dockerfile` with these complete contents:

```dockerfile
FROM eclipse-temurin:25-jdk AS build
WORKDIR /app
COPY . .
RUN chmod +x mvnw && ./mvnw -B -DskipTests package && \
    JAR=$(find target -maxdepth 1 -name '*.jar' ! -name '*-plain.jar' | head -n 1) && \
    test -n "$JAR" && cp "$JAR" /app/application.jar

FROM eclipse-temurin:25-jre
WORKDIR /app
COPY --from=build /app/application.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```

These image versions must match your chosen Java version. Compose supplies the datasource settings and server port through Spring Boot's [environment configuration](https://docs.spring.io/spring-boot/how-to/properties-and-configuration.html). Schema migrations and application endpoints are left for your application to define; a generated backend may return HTTP 404 at `/`.

## 3. Generate the frontend

From the repository root:

```sh
npm install -g @angular/cli
ng new frontend
```

Choose your preferred stylesheet format and disable SSR/SSG for this browser-only development setup. If prompted, use npm as the package manager. Keep the generated `package-lock.json`.

Create `frontend/Dockerfile` with these complete contents:

```dockerfile
FROM node:24-alpine
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
CMD ["npm", "start"]
```

Use a Node version supported by your generated Angular release. Create `frontend/.dockerignore` containing:

```text
node_modules
dist
.angular
.git
```

Compose starts the Angular development server on all container interfaces using the configured frontend port. This serves a development build, not a production deployment. Source changes require rebuilding with this setup.

## 4. Configure the environment

Run the setup script (requires Bash and OpenSSL):

```sh
./setup.sh
```

It creates `.env` from `.env.example`, generates random database names/usernames and a cryptographically random 64-character hexadecimal password, and sets file permissions to `600` (owner read/write only). Existing `.env` files are preserved, so rerunning the script does not rotate credentials. `.gitignore` excludes local secrets.

Optionally override settings on the first run:

```sh
POSTGRES_USER=myapp POSTGRES_DB=myapp BACKEND_PORT=8081 FRONTEND_PORT=4201 ./setup.sh
```

Alternatively, configure it manually:

```sh
cp .env.example .env
chmod 600 .env
```

Edit `.env`: choose a database username, strong local password, database name, and available application ports. `POSTGRES_PORT` configures the database's internal listening port; it is not exposed to the host. Use simple alphanumeric/underscore database names and usernames. Quote values containing Compose-special characters as described in the [Compose environment-file syntax](https://docs.docker.com/compose/how-tos/environment-variables/variable-interpolation/#env-file-syntax).

Add `.env` to your root `.gitignore` before committing. Keep `.env.example` tracked and never commit real credentials.

## 5. Build and start

From the root directory:

```sh
docker-compose up --build
```

If your Docker installation provides the newer command spelling, use `docker compose up --build` instead. The database health check gates backend startup. Frontend dependency ordering does not guarantee backend readiness; the backend can take longer to initialize.

With the example ports, open:

- Frontend: `http://localhost:4200`
- Backend: `http://localhost:8080`

Substitute your `.env` port values if changed. Browser API requests must use `http://localhost:<BACKEND_PORT>`; `backend` is a Docker-internal hostname. Before making frontend API calls, configure backend CORS for `http://localhost:<FRONTEND_PORT>` or add an Angular development proxy. Compose alone does not configure browser API routing.

## 6. Logs, tests, and shutdown

```sh
docker-compose logs -f backend
docker-compose down
```

Database data persists in the named `postgres_data` volume across restarts. Changing database credentials in `.env` does not update an already initialized database; alter the existing database roles/settings or deliberately recreate its data volume. `docker-compose down --volumes` deletes that data permanently.

Run backend tests with `./mvnw test` inside `backend/` (provide a test database or test profile when tests need PostgreSQL). Run frontend tests with `npm test` inside `frontend/`. The example backend image build skips tests so that packaging does not require a database during image creation; run tests separately before shipping.
