# Minimal-Samba

A minimal samba server docker image

## Deploy

```bash
docker compose up -d

docker compose stop
```

## Users management

All Samba users must already exist as Unix users on the host (the container mounts `/etc/passwd` and `/etc/group`)
Samba keeps its own hashed passwords, completely separate from the host.

Checkout `./script` folder for helper scripts

### Add user example

First, create a unix user on the host system

```bash
adduser -D -H -s /sbin/nologin <user>
```

Then, assign password for the user in samba

```bash
docker compose exec samba pdbedit -a -u <user>
```

### List samba users example

```bash
docker compose exec samba pdbedit -L
```