# User Documentation

## Overview

This document explains how to **use and manage** the **Inception** infrastructure as an end user or administrator.

It describes:

- What services are provided

- How to start, stop, and restart the project

- How to access the website and the WordPress administration panel

- Where credentials are stored

- How to verify that the system is running correctly

No prior knowledge of Docker internals is required to use this infrastructure.

---
## Services Provided

The project deploys a complete and secure web stack composed of:

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

All services run in isolated Docker containers and communicate through a private Docker network.

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
## Stopping and Restarting the Project

To stop and remove all containers while keeping stored data:
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

## Local Domain Configuration

The project uses a local domain name following the 42 project convention:
```text
https://<login>.42.fr
```
This domain is **not publicly registered** and must be resolved locally on the host machine.

To access the website correctly, the domain must be mapped to the local machine using the `/etc/hosts` file:
```bash
sudo nano /etc/hosts
```
Add the following line:
```text
127.0.0.1 <login>.42.fr
```
---
## Accessing the Website

Once the project is running, open a web browser and navigate to:
```text
https://<your-login>.42.fr
```
A self-signed SSL certificate is used, so the browser may display a security warning. This is expected and can be safely bypassed.

---
## Accessing the WordPress Administration Panel
To access the WordPress admin interface, in the browser go to:
```text
https://<your-login>.42.fr/wp-admin
```
Log in using the WordPress administrator credentials.

---
## Managing Credentials

All sensitive credentials are stored using Docker secrets and are not hardcoded inside images or configuration files.

The secret files are located in the `secrets/` directory:
```text
secrets/
├── db_root_password.txt      # MariaDB root password
├── db_password.txt           # WordPress database user password
└── wp_admin_password.txt     # WordPress admin password
```
Each file must contain **only the password**, with no extra spaces or newlines.

---
## Changing Passwords

Passwords provided via Docker secrets are applied **only during the initial setup** of the infrastructure.

## WordPress credentials

- WordPress user passwords can be changed through the WordPress administration panel

- No container restart is required

## Applying new secrets

- To apply new credentials from the `secrets/` directory, all stored data must be
removed and the infrastructure reinitialized

- This process permanently deletes all website and database data

Refer to the developer documentation for detailed reset instructions.

---
## Checking Service Status

To verify that all services are running correctly:
```bash
make ps
```
Expected running containers:

- nginx

- wordpress

- mariadb

---
## Viewing Logs

To view logs from all services:
```bash
make logs
```
This is useful for diagnosing startup issues or service failures.

---
## Verifying Correct Operation

The system is considered operational when:

- The website loads correctly over HTTPS

- The WordPress administration panel is accessible

- All containers are running

- No critical errors appear in the logs

---
## Notes

- Website and database data are stored persistently on the host system

- Restarting or rebuilding containers does not delete stored data

- Removing the persistent data directories will permanently delete all content