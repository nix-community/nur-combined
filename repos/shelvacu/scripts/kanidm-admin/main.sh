#!/usr/bin/env bash

set -euo pipefail

declare pw
pw="$(ssh prop -- sudo -u kanidm kanidmd scripting recover-account admin | jq -r .output)"
KANIDM_PASSWORD="$pw" kanidm login --name admin
