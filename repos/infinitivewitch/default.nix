# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT
{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) lib;
  overlayList = builtins.attrValues (import ./scrolls/overlays/overrides.nix);
  pkgs' = lib.foldl (prev: prev.extend) pkgs overlayList;
  selfLib = import ./scrolls/lib/library.nix {inherit (pkgs') lib;};
in
  {
    lib = selfLib;
    modules = import ./scrolls/modules/nixos;
    overlays = import ./scrolls/overlays/overrides.nix;
  }
  // pkgs'.callPackage ./scrolls/packages/pkgs {
    inherit selfLib;
  }
