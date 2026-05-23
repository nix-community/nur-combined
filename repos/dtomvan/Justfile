default: check build-test

check: check-flake check-nur-eval

check-flake:
    NIXPKGS_ALLOW_BROKEN=1 nix flake check -L --impure

check-nur-eval:
    nix run .#check-nur-eval

build-test:
    #!/usr/bin/env bash
    if [ -z "$CI" ]; then
        nom-build ci.nix -A buildPkgs
    else
        nix-build ci.nix -A buildPkgs
    fi

build:
    nom-build ci.nix -A buildPkgs --keep-going -j 2

push +WHAT='updates':
    jj config set --repo templates.git_push_bookmark '"\"updates-\" ++ author.timestamp().format(\"%F\")"'
    jj git push -c @-
    fj --host git.toostveen.nl pr create \
        --head "$(jj show -r 'closest_bookmark(@)' -T 'bookmarks.map(|b| b.name())' --no-patch | tr ' ' '\n' | sort | head -n1)" \
        --base master \
        --autofill
