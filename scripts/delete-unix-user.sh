#!/usr/bin/env bash
set -euo pipefail

# Usage: sudo ./delete-unix-user.sh <username>
# Removes a Unix user from the host. Does not affect Samba.

if [ $# -ne 1 ]; then
    echo "Usage: sudo $0 <username>"
    exit 1
fi

USER="$1"

if ! getent passwd "$USER" >/dev/null 2>&1; then
    echo "Error: Unix user '$USER' does not exist."
    exit 1
fi

read -r -p "Are you sure you want to delete Unix user '$USER'? [y/N] " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

userdel "$USER"
echo "User '$USER' deleted."