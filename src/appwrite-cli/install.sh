#!/bin/sh
set -eu

APPWRITE_CONFIG_MOUNT="/mnt/appwrite-config"
VERSION="${VERSION:-latest}"
REMOTE_USER="${_REMOTE_USER:-root}"
REMOTE_USER_HOME="${_REMOTE_USER_HOME:-/root}"

if ! command -v npm >/dev/null 2>&1; then
    echo "(!) npm not found: add ghcr.io/devcontainers/features/node or use an image with Node.js." >&2
    exit 1
fi
npm install -g "appwrite-cli@${VERSION}"

# Persistent login: the named volume mounted here survives rebuilds.
# Docker copies this directory's ownership into the volume when it is first created.
mkdir -p "${APPWRITE_CONFIG_MOUNT}"
chown "${REMOTE_USER}:" "${APPWRITE_CONFIG_MOUNT}"

# The CLI has no variable for its config directory: it uses ~/.appwrite when that
# directory exists, before $XDG_CONFIG_HOME/appwrite. A symlink therefore always wins.
if [ -e "${REMOTE_USER_HOME}/.appwrite" ] && [ ! -L "${REMOTE_USER_HOME}/.appwrite" ]; then
    echo "(!) ${REMOTE_USER_HOME}/.appwrite already exists and is not a symlink; remove it from the image." >&2
    exit 1
fi
ln -sfn "${APPWRITE_CONFIG_MOUNT}" "${REMOTE_USER_HOME}/.appwrite"
chown -h "${REMOTE_USER}:" "${REMOTE_USER_HOME}/.appwrite"

echo "appwrite-cli: config kept in ${APPWRITE_CONFIG_MOUNT} (${REMOTE_USER_HOME}/.appwrite)."
