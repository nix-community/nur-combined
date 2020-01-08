{ pkgs ? import <nixpkgs> {} }: let
  chaseSuper = pkgs: if pkgs ? arc.super then chaseSuper pkgs.arc.super else pkgs;
in if pkgs.arc.path or null == ./.
  then pkgs.arc # avoid unnecessary duplication?
  else ((chaseSuper pkgs).extend (import ./top-level.nix)).arc
