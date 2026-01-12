*This project has been created as part of the 42 curriculum by ddiogo-f.*

# Inception
## Description

Inception is a system administration and DevOps project focused on building a
secure, containerized web infrastructure using Docker and Docker Compose.

The goal of the project is to understand how multiple services can be isolated,
configured, and orchestrated to work together as a complete application stack.
All services are built and configured from scratch, without relying on prebuilt
application images.

The infrastructure deploys a complete web stack composed of:

- NGINX as the single entry point, configured to accept HTTPS connections only

- WordPress running with PHP-FPM

- MariaDB as the database backend for WordPress

- Persistent storage for both database and website data

- Secure handling of sensitive credentials using Docker secrets

Each service runs in its own dedicated container and communicates through a private
Docker network, ensuring isolation, security, and reproducibility.

---
## Instructions

This section explains how to build and run the project from scratch on a clean system.

### Requirements

The following tools must be installed on the host system:

- Docker

- Docker Compose

- GNU Make

The project is intended to run inside a Linux virtual machine, as required by the
42 Inception subject.

---
## Installation

Clone the repository and enter the project directory:
```bash
git clone <repository_url> inception
cd inception
```
Create the directory for Docker secrets:
```bash
mkdir -p secrets
```
Create the following secret files, each containing only the password (no extra spaces or newlines):
```text
secrets/
├── db_root_password.txt
├── db_password.txt
└── wp_admin_password.txt
```
Create the required persistent data directories on the host machine:
```bash
sudo mkdir -p /home/$(whoami)/data/mariadb
sudo mkdir -p /home/$(whoami)/data/wordpress
```
These directories are used by Docker bind mounts to ensure data persistence, as required by the subject.

---
## Execution

To build all images and start the infrastructure:
```bash
make
```
This command will:

- Build all Docker images

- Create the required network and containers

- Start all services in detached mode

To stop the infrastructure:
```bash
make down
```
To completely rebuild the project from scratch:
```bash
make re
```
Note: Persistent data stored under `/home/<login>/data` is not removed automatically
when using bind mounts.

---
## Accessing the Website

Once all containers are running, open a web browser and access:
```text
https://<your-login>.42.fr
```
A self-signed SSL certificate is used, so the browser may display a security warning.
This is expected and can be safely bypassed.

---
## Project Design Choices

This project follows the constraints of the 42 Inception subject while also applying common best practices for containerized infrastructures.

Docker and Docker Compose are used to orchestrate a small web stack composed of independent services, each running in its own container. This ensures clear separation of responsibilities, isolation, and reproducibility.

The following comparisons are required by the subject and guided the design decisions.

---
### Virtual Machines vs Docker

**Virtual Machines (VMs)** run a full operating system on top of a hypervisor, providing
strong isolation but at the cost of higher resource usage and slower startup times.

**Docker containers** share the host kernel and isolate only the application and its
dependencies. This makes them lightweight, fast to start, and well suited for
service-based architectures such as this project.

---
### Secrets vs Environment Variables

Environment variables are useful for configuration but are not ideal for storing
sensitive information such as passwords.

In this project:

- Non-sensitive configuration values are provided through environment variables

- Sensitive credentials (database and WordPress passwords) are stored using Docker secrets

Docker secrets are mounted as files at runtime and are not baked into images, reducing the risk of accidental exposure.

---
### Docker Network vs Host Network

Using the host network would expose services directly on the host system and remove network isolation between containers.

Instead, this project uses a **custom Docker bridge network**, which provides:

- Internal DNS-based service discovery by container name

- Network isolation from the host system

- Controlled exposure of services

Only the **NGINX** container exposes a port to the host (HTTPS on port 443). All other
services communicate exclusively through the internal Docker network.

---
### Docker Volumes vs Bind Mounts

Docker supports data persistence through **volumes** and **bind mounts**.

Docker volumes are managed entirely by Docker and stored in internal directories, providing strong isolation from the host filesystem.

Bind mounts map specific host directories directly into containers, giving full control over data location but requiring careful permission management.

In this project, bind mounts are used via Docker volumes configured with host paths, as required by the subject. This ensures that:

- Database data is stored in `/home/<login>/data/mariadb`

- WordPress files are stored in `/home/<login>/data/wordpress`

- Data persists across container rebuilds

- Files remain accessible from the host system

---
### Resources

The following resources were used during the development of this project:

#### Docker & Docker Compose

- https://docs.docker.com/

- https://docs.docker.com/compose/

- https://docs.docker.com/engine/reference/builder/

#### NGINX

- https://nginx.org/en/docs/

- https://nginx.org/en/docs/beginners_guide.html

#### WordPress & PHP-FPM

- https://wordpress.org/documentation/

- https://developer.wordpress.org/cli/commands/

- https://www.php.net/manual/en/install.fpm.configuration.php

#### MariaDB

- https://mariadb.com/kb/en/documentation/

- https://mariadb.com/docs/server/server-management/automated-mariadb-deployment-and-administration/docker-and-mariadb/installing-and-using-mariadb-via-docker

---
### Use of Artificial Intelligence

ChatGPT 5.2 was used during this project as a learning and debugging assistant.

AI was used to:

- Clarify Docker and Docker Compose concepts

- Understand error messages and container startup behavior

- Reason about service orchestration and networking

- Review configuration files and design choices

- Improve documentation clarity and structure

All AI-generated content was reviewed, understood, and adapted by the author.