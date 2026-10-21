#!/bin/bash
set -e

echo "Testing ai-tools feature..."

command -v claude
claude --version

echo "ai-tools feature tests passed."
