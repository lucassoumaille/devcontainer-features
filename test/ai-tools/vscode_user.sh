#!/bin/bash
set -e

source dev-container-features-test-lib

check "claude is installed" claude --version
check "opencode is installed" bash -c "command -v opencode"
check "CLAUDE_CONFIG_DIR points to the shared volume" test "${CLAUDE_CONFIG_DIR}" = "/mnt/claude-config"
check "shared config dir is writable" bash -c 'touch "${CLAUDE_CONFIG_DIR}/.write-test" && rm "${CLAUDE_CONFIG_DIR}/.write-test"'
check "managed settings installed" test -f /etc/claude-code/managed-settings.d/ai-tools.json
check "managed CLAUDE.md installed" test -f /etc/claude-code/CLAUDE.md
check "skills synced into config dir" bash -c '/usr/local/share/ai-tools/sync-claude-config.sh && test -f "${CLAUDE_CONFIG_DIR}/skills/quick-review/SKILL.md"'

reportResults
