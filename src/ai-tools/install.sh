#!/bin/sh
set -eu

FEATURE_DIR="$(cd "$(dirname "$0")" && pwd)"
SHARE_DIR="/usr/local/share/ai-tools"
CLAUDE_CONFIG_MOUNT="/mnt/claude-config"
REMOTE_USER="${_REMOTE_USER:-root}"

# Claude Code itself is installed by the ghcr.io/anthropics/devcontainer-features/claude-code dependency.

# Shared login: the named volume mounted here is reused by every container.
# Docker copies this directory's ownership into the volume when it is first created.
mkdir -p "${CLAUDE_CONFIG_MOUNT}"
chown "${REMOTE_USER}:" "${CLAUDE_CONFIG_MOUNT}"

# Shared configuration lives outside the volume so it always matches this feature version.
install -d /etc/claude-code/managed-settings.d
install -m 0644 "${FEATURE_DIR}/claude/managed-settings.json" /etc/claude-code/managed-settings.d/ai-tools.json
install -m 0644 "${FEATURE_DIR}/claude/CLAUDE.md" /etc/claude-code/CLAUDE.md

# Skills have no system-wide location; they are copied into the volume on each start.
rm -rf "${SHARE_DIR}"
install -d "${SHARE_DIR}"
cp -R "${FEATURE_DIR}/claude/skills" "${SHARE_DIR}/skills"
install -m 0755 "${FEATURE_DIR}/sync-claude-config.sh" "${SHARE_DIR}/sync-claude-config.sh"

if [ "${INSTALLOPENCODE:-true}" = "true" ]; then
    if ! command -v npm >/dev/null 2>&1; then
        echo "(!) npm not found: add ghcr.io/devcontainers/features/node or set installOpenCode=false." >&2
        exit 1
    fi
    npm install -g opencode-ai
fi

echo "ai-tools: Claude Code config shared through ${CLAUDE_CONFIG_MOUNT}."
