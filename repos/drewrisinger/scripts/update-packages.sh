#! /usr/bin/env nix-shell
#! nix-shell ../update-shell.nix -i bash

# Check that the jobs can be evaluated. Removes packages meant for e.g. raspberry pi
nix-eval-jobs --option restrict-eval true default.nix > evaluations.json
cat evaluations.json
# generate the list of attribute paths that should be updated
# support nix 2.4+ by running different command if first fails
if ! (nix eval --json "(import ./ci.nix { }).allAttrPaths" > nurAttrs.json); then
    # same command but for nix 2.4
    nix eval --json --impure --expr "(import ./ci.nix { }).allAttrPaths" --show-trace > nurAttrs.json
fi
cat nurAttrs.json
# run updates, exclude pyscf/pygsti-cirq
jq '[.. | values | strings] | map(select(contains("pygsti-cirq") or contains ("pyscf") or contains("oitg") or contains ("libcint") | not)) | .[]' nurAttrs.json | xargs -L1 nix-update --commit
