#/usr/bin/env bash

set -euo pipefail

GCS_BUCKET="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"

curl --fail "${GCS_BUCKET}/latest"
