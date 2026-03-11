# User Documentation

_This document explains how to use the Inception project as an end user or administrator._

---

## Overview

This project provides a self-hosted WordPress website running inside Docker containers.

Available services:

| Service   | Purpose                            |
| --------- | -------------------                |
| NGINX     | HTTPS reverse proxy and web server |
| WordPress | Website application                |
| MariaDB   | Database                           |

_Users access the website through HTTPS only._


---

## Starting the Project

To start the project run:

```bash
make
```

---

## Stopping the Project
Stop all running services:
```bash
make stop
```

---

## Accessing the Website

Open a browser and go to: `https://<login>.42.fr`

If the domain does not resolve, add the following line to /etc/hosts:

`127.0.0.1 <login>.42.fr`

---

## Accessing the WordPress Admin Panel

To access the administration panel open a browser and go to: `https://<login>.42.fr/wp-admin`

Log in using the wordpress users credentials defined in the `srcs/.env` configuration file.

---

## Credentials and Configuration

Credentials are defined in two locations:

#### Environment configuration:

`srcs/.env`

This file contains configuration values such as:

- WordPress site name
- database name
- usernames
- email addresses

#### Secret files:

Sensitive passwords are stored in the `secrets/` directory.

| File                 | Description                 |
| -------------------- | --------------------------- |
| db_password.txt      | WordPress database password |
| db_root_password.txt | MariaDB root password       |

These secrets are automatically mounted inside containers using Docker secrets.

---

## Verifying That Services Are Running

A healthy setup should meet these conditions:

1. `nginx`, `wordpress`, `mariadb` containers are running. 

2. The website loads at: `https://<login>.42.fr`

3. The WordPress admin panel is accessible: `https://<login>.42.fr/wp-admin`

4. Container logs show no critical errors.

---

## Checking Services

To check running containers:
```bash
make ps
```
_Expected containers:_ `nginx` `wordpress` `mariadb`


You can also view full container status:
```bash
make status
```

---

## Viewing Logs

View logs for all services:
```bash
make logs
```

Logs for a specific service:
```bash
make logs-nginx
make logs-wp
make logs-db
```