*This project has been created as part of the 42 curriculum by ddiogo-f.*

# Inception

## Description

**Inception** is a system administration and DevOps project that focuses on building a
secure, containerized web infrastructure using **Docker** and **Docker Compose**.

The main goal of the project is to understand how multiple services can be isolated,
configured, and orchestrated to work together as a complete application stack.
Rather than relying on preconfigured images, each service is built and configured
from scratch.

In this project, a full web stack is deployed, composed of:
- An **NGINX** web server acting as the single entry point, configured to use HTTPS only
- A **WordPress** application running with **PHP-FPM**
- A **MariaDB** database used by WordPress
- Persistent storage handled through Docker volumes
- Sensitive data managed securely using Docker secrets

Each service runs in its own dedicated container and communicates with the others
through a private Docker network, ensuring isolation, security, and reproducibility.

## Instructions

This section explains how to build and run the project from scratch on a clean system.

### - Requirements

The following tools must be installed on the host machine:

- Docker
- Docker Compose
- GNU Make

The project is intended to be run inside a Linux virtual machine, as required by the
42 subject.

---

### - Installation

Clone the repository:

```bash
git clone <repository_url> inception
cd inception
```
Create the required secret files inside the secrets/ directory:
```bash
mkdir -p secrets
```
Create the following files and store the corresponding passwords inside them
(one value per file, no extra spaces or newlines):
```text
secrets/
├── db_root_password.txt
├── db_password.txt
└── wp_admin_password.txt
```
Create required directories on the host

The project requires persistent data directories to house the volumes on the host machine, as specified
by the subject. These directories will be used by Docker bind mounts:
```bash
sudo mkdir -p /home/$(whoami)/data/mariadb
sudo mkdir -p /home/$(whoami)/data/wordpress
```

### - Execution

To build the images and start all services:
```bash
make
```
This command will:

- Build all Docker images

- Create the required networks and volumes

- Start all containers in detached mode

To stop the infrastructure:
```bash
make down
```


To remove containers:
```bash
make clean
```
To completely remove containers, images, and unused Docker resources:
```bash
make fclean
```
When using bind mounts for persistent data, Docker does not manage the
lifecycle of the files stored on the host filesystem.
For this reason:
- `clean` and `fclean` remove containers, images, networks and Docker volumes
- Persistent data stored in `/home/<login>/data` is intentionally preserved

This avoids accidental data loss and keeps responsibilities clearly separated
between Docker and the host system.
To rebuild everything from scratch:
```bash
make re
```
### - Accessing the Website

Once the containers are running, open a web browser and access:
```text
https://<your-login>.42.fr
```
## Resources

The following resources were used as references during the development of this project.

### Docker & Docker Compose

- Docker Documentation  
  https://docs.docker.com/

- Docker Compose Documentation  
  https://docs.docker.com/compose/

- Dockerfile Reference  
  https://docs.docker.com/engine/reference/builder/

### NGINX

- Official NGINX Documentation  
  https://nginx.org/en/docs/

- NGINX Beginner’s Guide  
  https://nginx.org/en/docs/beginners_guide.html

### WordPress & PHP-FPM

- WordPress Documentation  
  https://wordpress.org/documentation/

- WP-CLI Documentation  
  https://developer.wordpress.org/cli/commands/

- PHP-FPM Configuration  
  https://www.php.net/manual/en/install.fpm.configuration.php

### MariaDB

- MariaDB Server Documentation  
  https://mariadb.com/kb/en/documentation/

- MariaDB and Docker  
  https://mariadb.com/docs/server/server-management/automated-mariadb-deployment-and-administration/docker-and-mariadb/installing-and-using-mariadb-via-docker

---

### Use of Artificial Intelligence

ChatGPT 5.2 was used during this project as a learning and debugging assistant to accelerate understanding and problem-solving.

AI was specifically used for:

- Clarifying Docker and Docker Compose concepts
- Understanding error messages and container startup issues
- Reasoning about service orchestration and networking
- Reviewing configuration files and design choices
- Improving documentation clarity and structure


## Project Design Choices

This project was designed by following the constraints of the 42 Inception subject while
also respecting common best practices for containerized infrastructures.

Docker and Docker Compose were used to orchestrate a small web stack composed of
independent services, each running in its own container. The goal was to ensure
isolation, reproducibility, and clear separation of responsibilities between services.

The following sections explain the main design choices and comparisons required by
the subject.

---

### Virtual Machines vs Docker

**Virtual Machines (VMs)** run a full operating system on top of a hypervisor.
They provide strong isolation but are heavy in terms of resource usage and slow
to start.

**Docker containers**, on the other hand, share the host kernel and isolate only
the application and its dependencies. This makes them lightweight, fast to start,
and well suited for service-based architectures.

---

### Secrets vs Environment Variables

Environment variables are commonly used for configuration, but they are not ideal
for storing sensitive data such as passwords.

In this project:
- **Non-sensitive configuration** (service names, database name, URLs) is provided
  via environment variables.
- **Sensitive data** (database passwords and admin credentials) is stored using
  **Docker secrets**.

Docker secrets are:
- Mounted as files at runtime
- Not baked into images
- Less likely to be exposed accidentally
- Recommended by Docker for handling sensitive data

Environment variables in this project reference secret file paths rather than
containing passwords directly, combining flexibility with improved security.

---

### Docker Network vs Host Network

Using the **host network** would expose services directly on the host and remove
network isolation between containers.

Instead, this project uses a **custom Docker bridge network**, which provides:
- Internal DNS-based service discovery (by container name)
- Network isolation from the host
- Controlled exposure of services

Only the NGINX container exposes a port to the host (HTTPS on port 443).
All other services communicate internally through the Docker network.

This approach improves security and mirrors real-world infrastructure setups.

---

### Docker Volumes vs Bind Mounts

Docker provides two ways to persist data outside containers: **volumes** and
**bind mounts**.

**Docker volumes** are managed by Docker itself and stored in an internal
directory. They offer strong isolation from the host filesystem and automatic
lifecycle management.

**Bind mounts** directly map a specific host directory into a container. This
gives full control over where data is stored, but also requires careful handling
of permissions and ownership.

In this project, **bind mounts are used through Docker volumes configured with
host paths**, as required by the subject. This ensures that:

- Database data is stored in `/home/login/data/mariadb`
- WordPress files are stored in `/home/login/data/wordpress`
- Data persists across container rebuilds
- Files are directly accessible from the host system

This approach trades some portability for transparency and explicit control over
data location, which is acceptable and required in the context of this project.
