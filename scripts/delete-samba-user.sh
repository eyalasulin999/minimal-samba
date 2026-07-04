#!/usr/bin/env bash
set -euo pipefail

# Usage: ./delete-samba-user.sh <username>
# Removes a user from the Samba database. Does NOT delete the Unix user.

if [ $# -ne 1 ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

USER="$1"

# Ensure the container is running
if ! docker compose exec samba true > /dev/null 2>&1; then
    echo "Error: Samba container is not running. Start it with 'docker compose up -d'."
    exit 1
fi

# Check that user exists in Samba database
if ! docker compose exec samba pdbedit -L 2>/dev/null | grep -q "^$USER:"; then
    echo "Error: Samba user '$USER' does not exist in the Samba database."
    exit 1
fi

# Confirmation
read -r -p "Are you sure you want to delete Samba user '$USER'? [y/N] " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

docker compose exec samba pdbedit -x -u "$USER"
echo "Samba user '$USER' deleted."