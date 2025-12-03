#!/usr/bin/env bash

source shellvaculib.bash

declare pw
pw="$(ssh prop -- sudo -u kanidm kanidmd recover-account admin -o json | grep '^{' | jq .password -r)"
KANIDM_PASSWORD="$pw" kanidm login --name admin
