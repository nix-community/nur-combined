{ pkgs, lib, stdenv }: (import ./Cargo.nix { inherit pkgs lib stdenv; }).workspaceMembers.lightspeed-ingest.build

