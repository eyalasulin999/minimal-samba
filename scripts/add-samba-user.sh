#!/usr/bin/env bash
set -euo pipefail

# Usage: ./add-samba-user.sh <username>
# Adds a new Samba user (must already be a host Unix user) and sets their password.

if [ $# -ne 1 ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

USER="$1"

# 1. Ensure the container is running
if ! docker compose exec samba true > /dev/null 2>&1; then
    echo "Error: Samba container is not running. Start it with 'docker compose up -d'."
    exit 1
fi

# 2. Check host Unix user (no container needed)
if ! getent passwd "$USER" > /dev/null 2>&1; then
    echo "Error: Unix user '$USER' does not exist on the host."
    exit 1
fi

# 3. Check if already in Samba database
if docker compose exec samba pdbedit -L 2>/dev/null | grep -q "^$USER:"; then
    echo "Warning: Samba user '$USER' already exists."
fi

# 4. Add the user
echo "Adding Samba user '$USER'..."
docker compose exec samba pdbedit -a -u "$USER"
echo "User '$USER' added successfully."