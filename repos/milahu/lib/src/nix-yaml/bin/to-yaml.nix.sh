#! /bin/sh

nixFile=$(basename "$0" .sh)
jsonFile="$1"
if [ -n "$jsonFile" ]; then
  if [ "${jsonFile:0:1}" != "/" ]; then
    # get absolute path so we can chdir
    # TODO handle paths with spaces: ln -s $jsonFile /tmp/input.yaml
    jsonFile="$(realpath "$jsonFile")"
  fi
else
  jsonFile="$(dirname "$0")/../test/test.yaml.json"
fi

cd "$(dirname "$0")/.."

nix-instantiate --show-trace --expr --eval --json --strict '
  with import <nixpkgs> {};
  let toYAML = callPackage ./'$nixFile' {}; in
  (
    builtins.toJSON
    (toYAML (builtins.fromJSON (builtins.readFile '$jsonFile')))
  )
' | jq -r | jq -r
