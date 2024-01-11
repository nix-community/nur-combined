build target:
    nom build ".#{{target}}"

check:
    nix flake check .

update:
    nix flake update
    nvfetcher -c nvfetcher.toml -o _sources

push cachix target=("$(readlink result)"):
    cachix push moraxyc {{target}}
