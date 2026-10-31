#!/bin/bash
set -e

source dev-container-features-test-lib

# No network call from the CLI during the tests.
export APPWRITE_NO_UPDATE_CHECK=1

check "appwrite is installed" appwrite --version
check "config dir exists" test -d /mnt/appwrite-config
check "config dir is writable" bash -c 'touch /mnt/appwrite-config/.write-test && rm /mnt/appwrite-config/.write-test'
check "~/.appwrite points to the config dir" test "$(readlink "${HOME}/.appwrite")" = "/mnt/appwrite-config"
# `client --self-signed` writes prefs.json without contacting a server.
check "CLI writes its prefs to the config dir" bash -c 'appwrite client --self-signed false && test -f /mnt/appwrite-config/prefs.json'

reportResults
