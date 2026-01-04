# User Documentation

## Overview

This document explains how to use and manage the **Inception** infrastructure as an
end user or administrator.

It describes:
- What services are provided
- How to start and stop the project
- How to access the website and the WordPress administration panel
- Where credentials are stored and how to manage them
- How to verify that all services are running correctly

---

## Services Provided

The stack provides a complete and secure web infrastructure composed of:

- **NGINX**
  - Public web server
  - Handles HTTPS connections (TLS 1.2 / TLS 1.3)
  - Acts as the single entry point to the infrastructure

- **WordPress (PHP-FPM)**
  - Dynamic website and content management system
  - Executes PHP code using PHP-FPM
  - Not directly exposed to the internet

- **MariaDB**
  - Database server used by WordPress
  - Stores users, posts, configuration, and metadata
  - Accessible only from inside the Docker network

All services run in isolated Docker containers and communicate through a private
Docker network.

---

## Starting the Project

To start the entire infrastructure, run the following command from the project root:

```bash
make
```
This will:

- Build all Docker images

- Create the required containers

- Start all services in detached mode
---

## Stopping the Project

To stop and remove containers while keeping persistent data:
```bash
make down
```
To temporarily stop containers without removing them:
```bash
make stop
```
To restart all services:
```bash
make restart
```
---

## Accessing the Website

Once the project is running, open a web browser and navigate to:
```text
https://<your-login>.42.fr
```
A self-signed SSL certificate is used, so the browser may display a security warning.
This is expected and can be safely bypassed.

---

## Accessing the WordPress Administration Panel
To access the WordPress admin interface, in the browser go to:
```text
https://<your-login>.42.fr/wp-admin
```
Log in using the WordPress administrator credentials.

---
## Managing Credentials

All sensitive credentials are stored using Docker secrets and are not hardcoded
inside images or configuration files.

The secret files are located in the `secrets/` directory:
```text
secrets/
├── db_root_password.txt      # MariaDB root password
├── db_password.txt           # WordPress database user password
└── wp_admin_password.txt     # WordPress admin password
```
Each file must contain only the password, with no extra spaces or newlines.

## Credential Usage

- MariaDB root password
  - Used internally during database initialization

- WordPress database password
  - Used by WordPress to connect to MariaDB

- WordPress admin password
  - Used to log into the WordPress admin panel

## To change a password:

### If you want to keep data in volumes:
- Passwords stored in Docker secrets are applied only during the initial setup.
After initialization, credentials are stored internally by the services.
- To change WordPress credentials after the initial installation,
use the WordPress administration panel or WP-CLI.
- To change the database user password after installation, connect to the
MariaDB container and update it manually:
```bash
docker exec -it mariadb mysql -u root -p

ALTER USER 'wp_user'@'%' IDENTIFIED BY '<new_password>';
FLUSH PRIVILEGES;
```

### To apply new credentials from `secrets/`, all persistent data must be removed.

This requires manually deleting the data directories:
```bash
rm -rf /home/<login>/data/mariadb
rm -rf /home/<login>/data/wordpress
```
⚠️ Warning: This operation is destructive and will permanently delete all stored data. Depending on set permissions, `sudo` may be required and `data/` may also need to be removed.

After that, run:
```bash
mkdir -p /home/<login>/data/mariadb
mkdir -p /home/<login>/data/wordpress

make
```

---
## Checking Service Status

To verify that all containers are running correctly:
```bash
make ps
```
Expected output should show three running containers:

* nginx

* wordpress

* mariadb

---
## Viewing Logs

To inspect logs from all services:
```bash
make logs
```
---
## Verifying Correct Operation

The system is considered operational when:

- The website loads correctly over HTTPS

- The WordPress admin panel is accessible

- All containers are in a running state

- No critical errors appear in the logs

---
## Notes

- Data is persisted using bind mounts located under `/home/<login>/data/`
- Stopping or rebuilding containers does not delete website content or database data
- Removing these directories will permanently delete stored data