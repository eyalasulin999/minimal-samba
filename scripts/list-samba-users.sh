#!/usr/bin/env bash
set -euo pipefail

# Usage: ./list-samba-users.sh
# Lists all Samba users currently stored in the container’s password database.

# Ensure container is running
if ! docker compose exec samba true >/dev/null 2>&1; then
    echo "Error: Samba container is not running. Start it with 'docker compose up -d'."
    exit 1
fi

echo "Samba users:"
docker compose exec samba pdbedit -L