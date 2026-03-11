# Developer Documentation

_This document explains how to set up, build, run, and manage the Inception project environment._

---
## Environment Setup

### Prerequisites:
The following software must be installed:
- Docker
- Docker Compose
- Make
- Git

Verify installation:
```bash
docker --version
docker compose version
make --version
git --version
```

### Configuration files:

Environment variables are defined in: `srcs/.env`

Example configuration:
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

These variables are used by Docker Compose and the containers to configure the services.

### Secrets:

Sensitive credentials must not be stored in the repository.

Instead they are stored in the `secrets/` directory.

| File                 | Description                      |
| -------------------- | -------------------------------- |
| db_password.txt      | WordPress database user password |
| db_root_password.txt | MariaDB root password            |

Docker Compose mounts these files inside containers using Docker secrets. This ensures that sensitive information is not exposed in environment variables or source code.

### Domain Configuration:

The project expects a local domain pointing to the host machine.

Add the following line to `/etc/hosts`:

```
127.0.0.1 <login>.42.fr
```

This allows the browser to resolve the local WordPress server.

---
## Building and Launching the Project

The project uses a Makefile to simplify Docker commands.

Docker Compose configuration is located at: `srcs/docker-compose.yml`


### Build and start services:
```bash
make
```
This command will:
- create required data directories
- set correct permissions
- start containers using Docker Compose

### Build Directories and Permissions:
```bash
make build
```

This command will:
- Create host directories for persistent data: `/home/<login>/data/mariadb` and `/home/<login>/data/wordpress`
- Set ownership of these directories to user account


### Start all services:
```bash
make up
```

### Stop and remove containers:
```bash
make down
```

### Start existing containers:
```bash
make start
```
### Start an individual service:
```bash
make start-db
make start-wp
make start-nginx
```

### Stop all running containers:
```bash
make stop
```

### Stop an individual service:
```bash
make stop-db
make stop-wp
make stop-nginx
```

### Rebuilding Containers:
```bash
make re
```
This command will rebuild Docker images and restart containers.

### Restart all services:
```bash
make restart
```

### Rebuild the project:
```bash
make rebuild
```

---
## Cleaning the Environment

### Remove containers and unused resources:
```bash
make clean
```
This command will:
- stop containers
- remove volumes defined by Docker Compose
- clean unused Docker resources

### Full Cleanup
```bash
make fclean
```
This command will remove everything including persistent data: 
- `/home/<login>/data/mariadb`
- `/home/<login>/data/wordpress`

and prunes all Docker images, networks, volumes.

---
## Container Management

### View containers:
```bash
make ps
```

### View all containers (running or stopped):
```bash
make status
```

### Check processes inside containers:
```bash
make top
```

### View logs for all services:
```bash
make logs
```

### View logs for an individual service:
```bash
make logs-db
make logs-wp
make logs-nginx
```

### Inspect container configuration:
**MariaDB:**
```bash
make inspect-db
```
**Wordpress:**
```bash
make inspect-wp
```
**Nginx:**
```bash
make inspect-nginx
```
These commands show container configuration, mounted volumes, networks, and environment variables.


### Accessing Containers:

**Nginx**:
```bash
make bash-nginx
```
**WordPress**:
```bash
make bash-wp
```
**MariaDB**:
```bash
make bash-db
```
These commands open an interactive shell inside the running container.

---

## Managing Volumes

### List Docker volumes:
```bash
make volumes
```

### Inspect specific volumes:
```bash
make inspect-vol-db
make inspect-vol-wp
```

---

## Docker Networks
Containers communicate internally through a Docker network defined in docker-compose.yml

This network allows services to communicate using service names instead of IP addresses.

### List Docker networks:
```bash
make networks
```

### Inspect the project network:
```bash
make inspect-net
```

---
## Data Persistence

Containers are ephemeral, meaning they can be destroyed or recreated at any time.

Persistent data is stored using Docker volumes mapped to host directories.

This ensures that database and website files remain available even if containers are rebuilt.

### Persistent data location:

`/home/<login>/data/`

Example structure:
```
/home/<login>/data/
├── /mariadb
└── /wordpress
```

| Volume    | Data                    |
| --------- | ----------------------- |
| mariadb   | MariaDB database files  |
| wordpress | WordPress website files |

This ensures that:
- database data persists after container rebuilds
- website files remain available
- containers can be recreated without data loss
