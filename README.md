# Minimal-Samba

A minimal samba server docker image

## FUSE passwd script

When you add new unix user on your system, `/etc/passwd` file moved to `/etc/passwd-` (backup) and `/etc/passwd` created as new file.
Docker`s bind mount is by inode, so any changes on passwd does not sync with container's passwd.

```bash
python3 -m venv venv
. ./venv/bin/activate
pip3 install fusepy

cp passwd-fuse.service /etc/systemd/system/passwd-fuse.service
sudo systemctl daemon-reload
sudo systemctl enable passwd-fuse.service
sudo systemctl start passwd-fuse.service
```

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