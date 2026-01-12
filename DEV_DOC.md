# Developer Documentation

## Overview

This document explains how a developer can set up, build, run, and maintain the **Inception** infrastructure.

It focuses on the **internal mechanics** of the project, including:
- Environment and directory setup

- Project configuration and secrets handling

- Build and execution workflow

- Container lifecycle and orchestration

- Volume usage and data persistence behavior

This document assumes familiarity with Docker, Docker Compose, and basic Linux
system administration.

---
## 1. Environment Setup

### Prerequisites

The following tools must be installed on the host system:

- Docker
- Docker Compose
- GNU Make

The project is designed to run inside a Linux virtual machine, as required by the 42 subject.

---
### Project Structure
```text
.
├── Makefile
├── secrets/
│   ├── db_root_password.txt
│   ├── db_password.txt
│   └── wp_admin_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        ├── wordpress/
        └── nginx/
```
- `Makefile`
Entry point for building, running, and managing the infrastructure.

- `secrets/`
Stores sensitive credentials used at runtime via Docker secrets.

- `srcs/.env`
Defines non-sensitive configuration values and paths to secret files.

- `srcs/docker-compose.yml`
Orchestrates all services, networks, volumes, and secrets.

- `requirements/`
Contains one directory per service, each with its own Dockerfile,
configuration files, and entrypoint scripts.

---
## 2. Secrets and Configuration
### Secrets Management

Sensitive credentials are provided using Docker secrets.

The following files must exist under the `secrets/` directory:
```text
secrets/
├── db_root_password.txt      # MariaDB root password
├── db_password.txt           # WordPress database user password
└── wp_admin_password.txt     # WordPress administrator password
```
Each file must contain **only the password**, with no trailing spaces or newlines.

Secrets are mounted into containers at runtime under `/run/secrets/` and are never baked into Docker images or committed to the repository.

---
### Environment Variables (.env)
The file `srcs/.env` defines non-sensitive configuration values and references secret file paths.

Typical values include:

- Database host, name, and user

- WordPress site URL, title, and admin username

- Paths to secret files mounted inside containers

**No plaintext credentials are stored in this file.** Environment variables are injected into containers by Docker Compose and consumed
by entrypoint scripts during initialization.

---
## 3. Build and Execution Workflow
### Build and Startup

To build all images and start the infrastructure:
```bash
make
```
This command performs the following actions:

- Builds Docker images for all services

- Creates the Docker network and volumes

- Starts all containers in detached mode

The `Makefile` acts as a thin wrapper around Docker Compose to ensure consistent and reproducible execution.

---
### Stopping and Restarting Services

Available management commands include:
```bash
make down      # Stop and remove containers
make stop      # Stop containers without removing them
make start     # Start stopped containers
make restart   # Restart all containers
```

---
### Full Rebuild

To remove containers, images, and Docker-managed resources, then rebuild everything:
```bash
make re
```
When using bind mounts, host directories used for persistent data are not removed automatically and must be cleaned manually if a full reset is required.

---
## 4. Container Lifecycle and Initialization
### MariaDB Initialization

MariaDB uses a custom entrypoint script to handle first-time initialization.

Behavior:

- The database is initialized only if the data directory is empty

- Root and WordPress user credentials are read from Docker secrets

- The WordPress database and user are created during the first startup

- An initialization flag is written to prevent re-execution on subsequent runs

Once initialized, MariaDB stores all data and credentials inside the persistent data directory.

---
### WordPress Initialization

WordPress setup is handled via WP-CLI inside the container entrypoint.

Behavior:

- WordPress core is downloaded only if not already present

- wp-config.php is generated only once

- WordPress installation is skipped if it is already installed

Credentials and configuration values are applied only during the initial setup phase. Subsequent container restarts do not reapply secrets.

---
### NGINX Runtime Behavior

NGINX is configured as the single public entry point to the infrastructure.

Behavior:

- Serves WordPress files from the shared WordPress volume

- Forwards PHP requests to the WordPress PHP-FPM container

- Uses a self-signed TLS certificate

- Runs in the foreground as PID 1, following Docker best practices

---
## 5. Volumes and Data Persistence
### Storage Locations

Persistent data is stored on the host using bind mounts located under:
```text
/home/<login>/data/
├── mariadb/     # MariaDB database files
└── wordpress/   # WordPress files and uploads
```
These directories are mounted into containers as:

- `/var/lib/mysql` for MariaDB

- `/var/www/html` for WordPress and NGINX

---
### Persistence Behavior

- Data survives container restarts and rebuilds

- Removing containers does not reset WordPress or the database

- Docker does not manage the lifecycle of bind-mounted host directories

This behavior is expected and required by the project subject.

---
### Resetting Persistent Data

To force a complete reinitialization (for example, to apply new secrets):
```bash
rm -rf /home/<login>/data/mariadb
rm -rf /home/<login>/data/wordpress

mkdir -p /home/<login>/data/mariadb
mkdir -p /home/<login>/data/wordpress
```
Then restart the infrastructure:
```bash
make
```
⚠️ This operation permanently deletes all stored data.

---
## 6. Debugging and Monitoring
### Container Status

To inspect the state of all containers:
```bash
make ps
```
Expected running containers:

- `nginx`

- `wordpress`

- `mariadb`

---
### Logs

To stream logs from all services:
```bash
make logs
```
This is useful for diagnosing startup issues and initialization failures.

---
## 7. Developer Notes

- Secrets are consumed only during initial service setup

- Changing secret values after initialization has no effect without a data reset

- Entry-point scripts are idempotent and designed to run safely on restart

- Bind mounts provide transparency at the cost of manual lifecycle management

These design choices ensure predictable behavior and reproducible container startup.

---
## Conclusion

This infrastructure is designed to be:

- Deterministic

- Secure

- Reproducible

- Explicit about data persistence

Understanding how initialization scripts, secrets, and bind mounts interact is essential for maintaining, extending, or debugging this project.

---