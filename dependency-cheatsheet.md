# Spring Initializr dependency cheatsheet

Select dependencies at [Spring Initializr](https://start.spring.io/) when generating the backend. Availability and labels can vary by Spring Boot version. Start with the three baseline dependencies; add others when the application needs them.

| Dependency | When to add it |
| --- | --- |
| **Spring Web** (baseline) | Build REST endpoints with Spring MVC and an embedded HTTP server. |
| **Spring Data JPA** (baseline) | Map relational tables to Java entities and implement repositories using JPA/Hibernate. |
| **PostgreSQL Driver** (baseline) | Connect to this template's PostgreSQL database over JDBC. |
| Validation | Validate request DTOs with constraints such as `@NotBlank` and `@Email`, activated with `@Valid`. |
| Spring Security | Add authentication and authorization. Adding it changes default endpoint access; configure your security rules. |
| OAuth2 Resource Server | Protect an API using bearer access tokens issued by an identity provider. |
| OAuth2 Client | Implement OAuth/OIDC login or call another service using OAuth credentials. |
| Spring Boot Actuator | Expose health and operational metrics endpoints; control which endpoints are exposed. |
| Flyway Migration | Version database schema changes with migrations. For PostgreSQL, check whether your selected Boot/Flyway version also needs the PostgreSQL-specific Flyway module. |
| Liquibase Migration | Manage schema changes with changelogs; choose this or Flyway as your migration tool. |
| Lombok | Reduce repetitive Java getters, constructors, and builders; requires annotation processing in your build/IDE. |
| Spring Boot DevTools | Improve local JVM development with restart support; the packaged Docker workflow here still requires rebuilding. |
| Spring Data JDBC | Use simpler relational aggregates and JDBC repositories as an alternative to JPA. |
| Spring Data Redis (Access+Driver) | Add Redis-backed data access or caching; requires a separate Redis service and cache configuration. |
| Java Mail Sender | Send transactional email using an SMTP server. |
| Spring for RabbitMQ | Publish and consume asynchronous messages; requires a RabbitMQ broker. |
| Spring for Apache Kafka | Produce and consume event streams; requires Kafka infrastructure. |
| Testcontainers | Run integration tests against disposable real services such as PostgreSQL; requires Docker and test configuration. |

Use Spring Boot's generated dependency management rather than manually assigning versions to each starter. Spring Initializr normally includes baseline test support; check the generated build before adding duplicate test libraries. Avoid adding WebFlux alongside Spring Web unless you have a deliberate mixed-stack design.
