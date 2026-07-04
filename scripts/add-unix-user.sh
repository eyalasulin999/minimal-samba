#!/usr/bin/env bash
set -euo pipefail

# Usage: sudo ./add-unix-user.sh <username>
# Creates a Unix user with no home, no login shell, and no password.

if [ $# -ne 1 ]; then
    echo "Usage: sudo $0 <username>"
    exit 1
fi

USER="$1"

# Check if user already exists
if getent passwd "$USER" >/dev/null 2>&1; then
    echo "Error: Unix user '$USER' already exists."
    exit 1
fi

useradd --no-create-home --shell /sbin/nologin "$USER"
echo "User '$USER' created."