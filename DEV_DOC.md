# Developer Documentation

## Overview

This document explains how a developer can set up, build, run, and maintain the
**Inception** infrastructure.

It focuses on:
- Environment setup from scratch
- Project configuration and secrets
- Build and execution workflow
- Container and volume management
- Data persistence and storage locations

This document assumes basic familiarity with Docker and Linux systems.

---

## 1. Environment Setup

### Prerequisites

The following tools must be installed on the host system:

- Docker
- Docker Compose
- GNU Make

The project is designed to run inside a Linux virtual machine, as required by the
42 subject.

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
---

### Secrets Configuration

All sensitive credentials are provided using Docker secrets.

Create the `secrets/` directory at the project root and add the following files:
```text
secrets/
├── db_root_password.txt      # MariaDB root password
├── db_password.txt           # WordPress database user password
└── wp_admin_password.txt     # WordPress administrator password
```
Each file must contain only the password, without spaces or trailing newlines.

---
### Environment Variables

The file srcs/.env defines non-sensitive configuration values and references
the secret files by path.

Example values include:

- Database host and name

- WordPress site URL and title

- Secret file paths used at runtime

No plaintext passwords are stored in this file.

---

## 2. Building and Launching the Project

### Build and Start

To build all images and start the full infrastructure:
```bash
make
```
This command:

- Builds all Docker images

- Creates networks and containers

- Starts services in detached mode

---
### Stop and Restart

To stop all containers:
```bash
make down
```
To stop containers without removing them:
```bash
make stop
```
To restart all services:
```bash
make restart
```
---
### Full Rebuild

To remove containers, volumes, images, and rebuild everything:
```bash
make re
```
⚠️ When using bind mounts, persistent data directories on the host are not
removed automatically and may require manual cleanup.

---
## 3. Container and Volume Management

### Viewing Container Status
```bash
make ps
```
Expected containers:

- nginx

- wordpress

- mariadb

---
### Viewing Logs

This streams logs from all services and is useful for debugging startup issues:
```bash
make logs
```
---
## 4. Data Persistence

### Storage Locations

Persistent data is stored on the host using bind mounts under:
```text
/home/<login>/data/
├── mariadb/     # MariaDB database files
└── wordpress/   # WordPress files and uploads
```
These directories are mounted into containers as:

- /var/lib/mysql (MariaDB)

- /var/www/html (WordPress and NGINX)

---

### Persistence Behavior

Data survives container restarts and rebuilds

- Data is not removed by docker-compose down -v

- Removing containers does not reset WordPress or the database

- This behavior is expected when using bind mounts.

---
### Resetting Persistent Data

To force a full reinitialization (e.g. to apply new secrets):
```bash
rm -rf /home/<login>/data/mariadb
rm -rf /home/<login>/data/wordpress
```
Recreate the directories:
```bash
mkdir -p /home/<login>/data/mariadb
mkdir -p /home/<login>/data/wordpress
```
Then restart the project:
```bash
make
```
⚠️ This operation permanently deletes all stored data.

---
## 5. Developer Notes

- MariaDB initialization runs only when the database directory is empty

- WordPress installation is skipped if wp-config.php already exists

- Secrets are applied only during initial setup

- Changing passwords after initialization requires manual intervention or
a full data reset

- This behavior ensures predictable and reproducible container startup.

---
## Conclusion

This infrastructure is designed to be:

- Deterministic

- Secure

- Easy to rebuild

- Explicit about data persistence

Understanding how bind mounts and initialization scripts interact is essential
for maintaining and extending this project.