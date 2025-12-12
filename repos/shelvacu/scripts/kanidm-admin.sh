#!/usr/bin/env bash

source shellvaculib.bash || exit 1

declare pw
pw="$(ssh prop -- sudo -u kanidm kanidmd recover-account admin -o json | grep '^{' | jq .password -r)"
KANIDM_PASSWORD="$pw" kanidm login --name admin
