#! /bin/sh

cd "$(dirname "$0")"

nixFile=$(basename "$0" .sh)
yamlFile="$1"
[ -z "$yamlFile" ] && yamlFile=test.yaml

# TODO better than lib.traceValSeq
nix-instantiate --show-trace --expr --strict '
  with import <nixpkgs> {};
  #let fromYAML = import ./'$nixFile' {}; in
  let fromYAML = callPackage ./'$nixFile' {}; in
  lib.traceValSeq
  (
    builtins.toJSON
    (fromYAML (builtins.readFile ./'$yamlFile'))
  )
' 2>&1 |
cat
#grep ^"trace: " | tail -c+8 | jq -r
