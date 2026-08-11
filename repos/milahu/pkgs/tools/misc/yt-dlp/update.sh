#!/usr/bin/env bash

nix_file=default.nix

for bin in git nix-prefetch; do
  if ! command -v $bin >/dev/null; then
    echo "error: missing program: $bin"
    exit 1
  fi
done

nix_file="$(dirname "$0")"/$nix_file
echo "nix file: $nix_file"

owner=$(grep -m1 ' owner = "' $nix_file | cut -d'"' -f2)
repo=$(grep -m1 ' repo = "' $nix_file | cut -d'"' -f2)
remote=https://github.com/$owner/$repo

echo "remote: $remote"

# tags are already sorted so we just need "tail -n1"
if [ "$1" == "--test" ]; then
  new_version='2024.05.26'
else
  new_version=$(git ls-remote --tags $remote | tail -n1 | cut -c52-)
fi

# check if package is up to date
old_version=$(grep -m1 ' version = "' $nix_file | cut -d'"' -f2)

if [ "$old_version" = "$new_version" ]; then
  echo "already up to date"
  exit
fi

echo "updating: $old_version -> $new_version"

if [ "$1" == "--test" ]; then
  new_hash='sha256-hGmxuOZSEzGG+7ejwiSqLuzYmsbcK9aaoigiz1cVV/Y='
else
  new_hash=$(nix-prefetch fetchFromGitHub --owner $owner --repo $repo --rev $new_version)
fi

escapeForRegex() {
  echo "$1" | sed -E 's/[][(){}.+*?^$]/\\&/g'
}

old_hash=$(grep -m1 ' hash = "' $nix_file | cut -d'"' -f2)

# hash can contain "/"
sed_script="s/ version = \"$(escapeForRegex "$old_version")\"/ version = \"$(escapeForRegex "$new_version")\"/;"
sed_script+="s| hash = \"$(escapeForRegex "$old_hash")\"| hash = \"$(escapeForRegex "$new_hash")\"|;"

sed -E -i "$sed_script" $nix_file

nix_attr=$(git log --format=format:%s -- $nix_file | grep -m1 -e ': init' -e ' -> ' | cut -d':' -f1)

set -x
git add $nix_file
git commit -m "$nix_attr: $old_version -> $new_version"
git show --stat
