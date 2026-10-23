#!/bin/sh
set -eu

# Copies the skills shipped with the ai-tools feature into the shared Claude config volume.
# Skills with the same name are overwritten; other user skills are left untouched.

SHARE_DIR="/usr/local/share/ai-tools"
CONFIG_DIR="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}"

if [ ! -w "${CONFIG_DIR}" ]; then
    echo "(!) ai-tools: ${CONFIG_DIR} is not writable, skills not synced." >&2
    exit 0
fi

mkdir -p "${CONFIG_DIR}/skills"
for skill in "${SHARE_DIR}"/skills/*/; do
    name="$(basename "${skill}")"
    rm -rf "${CONFIG_DIR}/skills/${name}"
    cp -R "${skill}" "${CONFIG_DIR}/skills/${name}"
done
