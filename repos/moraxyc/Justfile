build target:
    nom build ".#{{target}}"

check:
    nix flake check .

update:
    nix run .#update

cache target=("./result"):
    cachix push moraxyc {{target}}
