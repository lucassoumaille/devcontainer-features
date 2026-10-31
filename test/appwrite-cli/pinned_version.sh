#!/bin/bash
set -e

source dev-container-features-test-lib

export APPWRITE_NO_UPDATE_CHECK=1

check "pinned version is installed" bash -c 'appwrite --version | grep -F 28.10.2'
check "~/.appwrite points to the config dir" test "$(readlink "${HOME}/.appwrite")" = "/mnt/appwrite-config"

reportResults
