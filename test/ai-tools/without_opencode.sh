#!/bin/bash
set -e

source dev-container-features-test-lib

check "claude is installed" claude --version
check "opencode is not installed" bash -c "! command -v opencode"

reportResults
