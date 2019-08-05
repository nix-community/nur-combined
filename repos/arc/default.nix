{ pkgs ? import <nixpkgs> {} }:
pkgs.arc or (pkgs.extend (import ./top-level.nix)).arc
