# vim: set ft=make :

# Show all available recipes interactively with fzf
choose:
    @just --list | grep -E '^\s+' | sed 's/^\s*//' | cut -d' ' -f1 | fzf --preview 'just --list | grep "^{}" | head -1' --reverse --height=50% | xargs just

update:
    nix flake update

build-iso $host:
    just copy {{ host }}; ssh {{ host }}; nixos-rebuild build-image --image-variant iso --flake .#{{ host }}

# Build an SD card image for a host with an sdImage configuration (pi0, pi1, apollo1, apollo13)
build-sd-image $host:
    nom build ".#nixosConfigurations.{{ host }}.config.system.build.sdImage" --out-link "result-{{ host }}-sd-image"

check:
    nix flake check

dry-run $host:
    nixos-rebuild dry-activate --flake .#{{ host }} --target-host {{ host }} --build-host {{ host }} --fast --elevate=sudo
deploy $host:
    just copy {{ host }}; nixos-rebuild switch --flake .#{{ host }} --target-host {{ host }} --build-host {{ host }} --no-reexec --sudo --elevate=sudo

copy $host:
    rsync -ax --delete --rsync-path="sudo rsync" ./ {{ host }}:/etc/nixos/

darwin-deploy:
    nh darwin switch .

home-deploy $host:
    just copy {{ host }}; ssh {{ host }} "cd /etc/nixos && home-manager switch --flake .#avy@{{ host }}"

home-dry-run $host:
    just copy {{ host }}; ssh {{ host }} "cd /etc/nixos && home-manager switch --flake .#avy@{{ host }} --dry-run"

updatekeys:
    sops updatekeys secrets/*
