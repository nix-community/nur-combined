#!/usr/bin/env nix-shell
#!nix-shell -I nixpkgs=./nix -i bash

set -e

export XDG_CONFIG_HOME="/foo/bar"

echo "========================================"
echo "Running test suite for npm lockfiles V1"
echo "========================================"

echo -e "Running unit tests for lockfiles v1\n"
nix-build -A tests.v1 --no-build-output --no-out-link --show-trace

echo -e "\n\nRunning integration tests for lockfiles v1\n"
$(nix-build  -A tests.v1.integration-tests --no-out-link --show-trace)

echo -e "\n\nTest githubSourceHashMap in restricted mode for lockfiles v1\n"
nix-build tests/tests-v1/examples-projects/github-dependency/default.nix --restrict-eval -I . --allowed-uris 'https://github.com/nixos/nixpkgs' --show-trace

echo "========================================"
echo "Running test suite for npm lockfiles V2"
echo "========================================"

echo -e "Running unit tests for lockfiles v2\n"
nix-build -A tests.v2 --no-build-output --no-out-link --show-trace

echo -e "\n\nRunning integration tests for lockfiles v2\n"
$(nix-build  -A tests.v2.integration-tests --no-out-link --show-trace)

echo -e "\n\nTest githubSourceHashMap in restricted mode for lockfiles v2\n"
nix-build tests/tests-v2/examples-projects/github-dependency/default.nix --restrict-eval -I . --allowed-uris 'https://github.com/nixos/nixpkgs' --show-trace
