# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT
{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.nixpkgs;
in {
  options.nixpkgs = {
    config = lib.mkOption {
      type = with lib.types; attrsOf raw;
      default = {};
    };
    overlays = lib.mkOption {
      type = with lib.types; listOf raw;
      default = [];
    };
  };
  config = {
    perSystem = {system, ...}: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        inherit (cfg) config overlays;
      };
    };
  };
}
