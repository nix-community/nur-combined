_default:
    @just --list

shell:
    nix shell nixpkgs#nix-update

update: update-bb-imager update-dtsfmt update-envoluntary update-potracer update-supernote-tool

update-bb-imager:
    nix-update --flake bb-imager

update-dtsfmt:
    nix-update --flake dtsfmt

update-envoluntary:
    nix-update --flake envoluntary

update-potracer:
    nix-update --flake potracer

update-supernote-tool:
    nix-update --flake supernote-tool
