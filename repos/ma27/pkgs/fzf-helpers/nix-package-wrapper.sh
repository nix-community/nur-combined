#! /usr/bin/env bash

nix_path_entry=${1:-}

script="
map
  (n: if \"$nix_path_entry\" != \"\" then \"$nix_path_entry.\${n}\" else n)
  (builtins.attrNames (import <nixpkgs> { }))
"

# there are fairly much commands that can take packages as arguments.
#
# So rather than hacking together another wrapper which runs any Nix command and this
# result it's easier to simply substitute the results with any desired command.
#
# $ nix run $(spkg)
nix-instantiate --strict --eval -E "$script" | xargs echo | tr " " "\n" | sed '$ d' | sed 1d | fzf
