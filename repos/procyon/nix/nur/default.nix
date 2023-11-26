# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT

{ pkgs ? import <nixpkgs> { } }:

let
  inherit (pkgs) lib;
  overlayList = builtins.attrValues (import ../overlays);
  pkgs' = lib.foldl (prev: prev.extend) pkgs overlayList;
  selfLib = import ../lib { inherit (pkgs') inputs self config lib; };
in
{
  lib = selfLib;
  modules = { }; # TODO: add modules
  overlays = { }; # TODO: add overlays
}
  //
(pkgs'.callPackage ../pkgs {
  inherit selfLib;
})
