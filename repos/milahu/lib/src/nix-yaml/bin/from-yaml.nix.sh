#! /bin/sh

nixFile=$(basename "$0" .sh)
yamlFile="$1"
if [ -n "$yamlFile" ]; then
  if [ "${yamlFile:0:1}" != "/" ]; then
    # get absolute path so we can chdir
    # TODO handle paths with spaces: ln -s $yamlFile /tmp/input.yaml
    yamlFile="$(realpath "$yamlFile")"
  fi
else
  yamlFile="$(dirname "$0")/../test/test.yaml"
fi

cd "$(dirname "$0")/.."

nix-instantiate --show-trace --expr --eval --json --strict '
  with import <nixpkgs> {};
  let fromYAML = callPackage ./'$nixFile' {}; in
  (
    builtins.toJSON
    (fromYAML (builtins.readFile '$yamlFile'))
  )
' | jq -r | jq -r
