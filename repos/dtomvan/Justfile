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
        nom-build ci.nix -A buildPkgs
    else
        nix-build ci.nix -A buildPkgs
    fi

build:
    nom-build ci.nix -A buildPkgs --keep-going -j 2

push:
    jj git push -c @-
    gh pr create \
        -B master \
        -H "$(jj show -r 'closest_bookmark(@)' -T 'bookmarks.map(|b| b.name())' --no-patch | tr ' ' '\n' | sort | head -n1)" \
        -t "updates $(date -I)" \
        -F <(git log --oneline master..HEAD | sed 's|^|- |')
