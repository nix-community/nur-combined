#!/usr/bin/env bash

set -exof pipefail

git add -A
git commit -a --allow-empty-message -m "$*"
git push
