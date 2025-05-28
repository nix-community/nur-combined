alias check := default

default: check-flake check-nur-eval check-formatting build-test

check-flake:
    nix flake check -L

check-nur-eval:
    nix run .#check-nur-eval

check-formatting:
    nix fmt -- --ci

build-test:
    #!/usr/bin/env bash
    if [ -z "$CI" ]; then
        nix shell nixpkgs#nix-output-monitor --command nom-build ci.nix -A buildPkgs
    else
        nix-build ci.nix -A buildPkgs
    fi
