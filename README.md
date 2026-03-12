*This project has been created as part of the 42 curriculum by dzasenko.*

---

## Description

Inception is a system administration project that introduces containerized infrastructure using **Docker** and **Docker Compose**.

The goal of the project is to build a small web infrastructure composed of multiple services running in isolated containers and communicating through an internal Docker network.

The infrastructure hosts a **WordPress website secured with HTTPS** using **NGINX** as a reverse proxy and **MariaDB** as the database backend.

Each service runs in its own container and is built from a custom **Dockerfile** based on **Debian** images.


---

## Project Structure

```
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── .gitignore 
├── secrets/
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── .dockerignore
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── 50-server.cnf
        │   └── tools/
        │       └── entrypoint.sh
        ├── nginx/
        │   ├── .dockerignore
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── default.conf
        │   └── tools/
        │       └── entrypoint.sh
        └── wordpress/
            ├── .dockerignore
            ├── Dockerfile
            ├── conf/
            │   └── www.conf
            └── tools/
                └── entrypoint.sh
```

`.gitignore` excludes `secrets/`, `.env`, and other temporary files from the repository.

`.dockerignore` prevents unnecessary files from being included in the Docker image.

`secrets/` and `.env` contain sensitive data and are not tracked by Git.

---

## Services

The project stack includes the following services:

- **NGINX** reverse proxy serving HTTPS traffic (TLSv1.2 / TLSv1.3)
- **WordPress** with **PHP-FPM**
- **MariaDB** database

Each service image is built from a custom Dockerfile.

---

## Project Architecture

The NGINX container is the only entry point into the infrastructure and exposes port 443.

```
Client (Browser)
       │
       │ HTTPS (TLSv1.2 / TLSv1.3)
       ▼
    NGINX
       │ FastCGI
       ▼
   WordPress (PHP-FPM)
       │
       │ MySQL protocol
       ▼
     MariaDB
```

Containers communicate internally through a dedicated Docker bridge network.

Persistent data is stored using Docker named volumes.
```
/home/<login>/data/
                ├── wordpress/
                └── mariadb/
```
These directories store the WordPress website files and the database data.

---

## Instructions

### 1. Clone the repository

```bash
git clone <url> Inception
cd Inception
```

### 2. Configure environment variables

Edit the `.env` file located in `srcs/.env`:

Example:
```
DOMAIN_NAME=
MYSQL_DATABASE=
MYSQL_USER=
WP_HOST=
WP_PORT=
WP_NAME=
WP_USER=
WP_EDITOR=
WP_USER_EMAIL=
WP_EDITOR_EMAIL=
```

### 3. Configure secrets
Sensitive credentials must be stored inside the `secrets/` directory.

Example:
```bash
secrets/db_password.txt
secrets/db_root_password.txt
```
These files are mounted inside containers using Docker secrets.

### 4. Configure the local domain

Add the following entry to `/etc/hosts`:
```bash
127.0.0.1 <login>.42.fr
```

### 5. Start the project
Build and start all containers:
```bash
make
```

### 6. Stop the project

```bash
make down
```

---

## Design Choices

### Virtual Machines vs Docker

Virtual Machines virtualize entire operating systems and require more resources.

Docker containers share the host kernel and run lightweight isolated processes.

| Virtual Machines       | Docker Containers  |
| ---------------------- | ------------------ |
| Full OS virtualization | Shared host kernel |
| Heavy resource usage   | Lightweight        |
| Slower startup         | Very fast startup  |
| Large disk usage       | Small images       |

### Secrets vs Environment Variables

Environment variables are commonly used to configure applications.

However, sensitive information such as passwords should be stored using Docker secrets.

Secrets are mounted inside containers securely and are not visible in environment listings.

| Environment Variables            | Docker Secrets                     |
| -------------------------------- | ---------------------------------- |
| Stored in `.env`                 | Stored securely in `/run/secrets/` |
| Used for configuration           | Used for sensitive data            |
| Visible in container environment | Hidden from process listing        |

In this project:
- `.env` stores configuration variables
- `Docker secrets` store database passwords

### Docker Network vs Host Network

Docker networks allow containers to communicate securely using internal DNS.

Using host networking would expose services directly to the host system and reduce isolation.

| Docker Network                   | Host Network                  |
| -------------------------------- | ----------------------------- |
| Isolated container communication | Containers share host network |
| Secure internal communication    | Less secure                   |
| Services reachable by name       | Direct host exposure          |

This project uses a Docker bridge network to connect containers internally.

### Docker Volumes vs Bind Mounts

Bind mounts directly map host directories into containers.

Docker volumes are managed by Docker and provide better portability and isolation.

| Bind Mount                 | Docker Volume     |
| -------------------------- | ----------------- |
| Direct host mapping        | Managed by Docker |
| Less portable              | More portable     |
| Permission issues possible | Better isolation  |

This project uses Docker named volumes to persist:

- WordPress files
- MariaDB database

The volumes store their data inside: `/home/<login>/data/`

This ensures data persists even if containers are removed or rebuilt.

---

## Resources

### Official documentation:
- https://docs.docker.com
- https://nginx.org/en/docs/
- https://wordpress.org/support/article/how-to-install-wordpress/
- https://mariadb.org/documentation/

### Tutorials:
- Docker networking guide
- WordPress + NGINX architecture
- TLS configuration best practices

### AI usage:

AI tools were used for:

- explaining Docker concepts
- improving documentation clarity
- troubleshooting container configuration

All architectural decisions, implementation, configuration,
and debugging of the infrastructure were performed manually.
