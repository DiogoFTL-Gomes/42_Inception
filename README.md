*This project has been created as part of the 42 curriculum by ddiogo-f.*

# Inception

## Description

The **Inception** project consists of building a small infrastructure using **Docker**
and **Docker Compose**, following strict rules regarding isolation, security, and
service orchestration.

The goal of this project is to understand how containerized services interact with
each other, how to configure them properly, and how to deploy a secure web stack
from scratch.

This infrastructure includes:
- An **NGINX** web server configured with HTTPS only (TLSv1.2 / TLSv1.3)
- A **WordPress** application running with **PHP-FPM**
- A **MariaDB** database
- Persistent storage using Docker volumes
- Secure handling of secrets using Docker secrets

Each service runs in its own dedicated container and communicates through a private
Docker network.

---

## Project Architecture / Overview

The infrastructure is composed of three main services, each running in its own
dedicated container and connected through a private Docker network.

The HTTP request flow is as follows:

```text
Client (Browser)
        |
        | HTTPS (TLS 1.2 / TLS 1.3)
        v
      NGINX
        |
        | FastCGI (port 9000)
        v
 WordPress (PHP-FPM)
        |
        | TCP (port 3306)
        v
    MariaDB
```

### Service Roles

- **NGINX**
  - Acts as the public entry point of the infrastructure
  - Terminates HTTPS connections (TLSv1.2 / TLSv1.3)
  - Forwards PHP requests to WordPress using FastCGI

- **WordPress (PHP-FPM)**
  - Executes PHP code via PHP-FPM
  - Generates dynamic content
  - Does not expose HTTP directly to the outside world

- **MariaDB**
  - Stores WordPress data (users, posts, configuration)
  - Is only accessible from inside the Docker network

All inter-service communication happens inside a private Docker bridge network.
Only NGINX is exposed externally, ensuring proper isolation and security.

---

## Instructions

This section explains how to run the project from scratch on a clean system.

### Requirements

The following tools must be installed on the host machine:

- Docker
- Docker Compose
- GNU Make

The project is intended to be run inside a Linux virtual machine, as required by the 42 subject.

---

### Installation

Clone the repository:

```bash
git clone <repository_url> <destination_folder>
cd <destination_folder>
```

Create the required secret files inside the secrets/ directory:
```bash
mkdir -p secrets
```

Create the following files with the appropriate values:
```text
secrets/
├── db_password.txt
├── db_root_password.txt
└── wp_admin_password.txt
```
Each file must contain only the password, without spaces or newlines.

---

### Execution
To build and start the entire infrastructure, run:
```bash
make
```
This command will:

- Build all Docker images

- Create volumes and networks

- Start all containers in detached mode

To stop the infrastructure:
```bash
make down
```
To completely remove containers, images, volumes, and networks:
```bash
make fclean
```
To rebuild everything from scratch:
```bash
make re
```
To check that all containers are running:
```bash
docker ps
```

### Accessing the Website
Once the containers are running, open a browser and access:
```text
https://<your-login>.42.fr
```
---
## 6. Project Design Choices

This section explains the main technical and architectural decisions made during the
project, as explicitly required by the subject. Each choice is justified and compared
with possible alternatives.

---

### 6.1 Use of Docker

Docker was chosen as the core technology to build and run the infrastructure because
it allows services to be isolated, reproducible, and easily orchestrated.

In this project, Docker solves several key problems:

- Each service runs in its own isolated environment
- Dependencies are bundled with the service itself
- The infrastructure behaves consistently across different machines
- Services can communicate through controlled networks
- Persistent data can be managed independently from containers

Docker makes it possible to reproduce a full web stack reliably, without relying on
host-specific configurations.

---

### 6.2 Virtual Machines vs Docker

**Virtual Machines** and **Docker containers** both provide isolation, but at very
different levels.

| Virtual Machines | Docker |
|------------------|--------|
| Full operating system per VM | Shares host kernel |
| Heavy and slow to start | Lightweight and fast |
| High resource usage | Low resource usage |
| Harder to scale | Designed for service-based architectures |

Docker was chosen because this project focuses on **service orchestration**, not full
system virtualization. Containers are better suited for running multiple independent
services that need to communicate efficiently while remaining isolated.

---

### 6.3 Secrets vs Environment Variables

Environment variables are commonly used for configuration, but they are not ideal for
handling sensitive data such as passwords.

Docker **secrets** were used in this project because:

- Secrets are not stored directly in the image
- They are mounted at runtime as files
- They reduce the risk of accidental exposure
- They follow Docker’s recommended security practices

In this infrastructure, database passwords and admin credentials are provided through
Docker secrets and read by the containers only when needed.

This approach improves security compared to plain environment variables.

---

### 6.4 Docker Network vs Host Network

Using the host network would expose services directly to the host system, reducing
isolation and increasing the attack surface.

A **Docker bridge network** was chosen because it provides:

- Isolation from the host network
- Controlled communication between services
- Automatic internal DNS resolution by service name
- No direct exposure of internal services to the outside world

Only the NGINX container exposes a port to the host. WordPress and MariaDB are only
accessible inside the Docker network, which improves security and encapsulation.

---

### 6.5 Docker Volumes vs Bind Mounts

Docker volumes and bind mounts are both used to persist data, but they serve different
purposes.

| Docker Volumes | Bind Mounts |
|----------------|------------|
| Managed by Docker | Directly tied to host filesystem |
| Portable | Host-path dependent |
| Safer and cleaner | Risk of permission issues |
| Ideal for production | Mostly for development |

Docker volumes were chosen in this project to store:

- MariaDB data
- WordPress website files

Volumes provide reliable persistence across container restarts while keeping the
infrastructure portable and independent from host-specific paths.
