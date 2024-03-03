set shell := ["nu", "-c"]

alias c := check

host := `hostname`
me := `whoami`

default:
    @just --choose

build-livecd:
    nom build .#nixosConfigurations.nixos.config.system.build.isoImage

build-bootstrap:
    nom build .#nixosConfigurations.bootstrap.config.system.build.diskoImages

check +args="":
    nix flake check {{ args }}

slow-action +args="": rekey check overwrite-s3
    sudo nixos-rebuild switch

rekey:
    agenix rekey

overwrite-s3:
    mc mirror --overwrite --remove /home/{{ me }}/Sec/ r2/sec/Sec
    mc mirror --overwrite --remove {{ loc }}/sec/ r2/sec/credentials

overwrite-local:
    mc mirror --overwrite --remove r2/sec/Sec /home/{{ me }}/Sec/

cn:
    git clean -f
