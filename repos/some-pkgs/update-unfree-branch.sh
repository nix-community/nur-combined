#!/usr/bin/env bash
# A little script that helps keep upstream and this repo in sync
set -exuo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)

workdir=$(mktemp -d)
cleanup() {
  cd "$here"
  git worktree remove --force "$workdir"
  rm -rf "$workdir"
}
trap cleanup EXIT

# Checkout that branch in a temporary worktree
git worktree add -f "$workdir" unfree 
cd "$workdir"
git rebase master
git push --force-with-lease origin "HEAD:unfree"

