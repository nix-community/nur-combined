#!/usr/bin/env bash
cd "$(dirname "$(readlink -f "$0")")/.." || exit 1

[ -n "$(git diff)" ] || exit
git add _sources/generated.nix
git config --global user.name 'Github Actions'
git config --global user.email '41898282+github-actions[bot]@users.noreply.github.com'
git commit -m ":bookmark: Update"
git remote set-url origin "https://x-access-token:$GH_TOKEN@github.com/$GITHUB_REPOSITORY"
git push
