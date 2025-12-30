{
  pkgs,
  config,
  inputs,
  lib,
  vacupkglib,
  ...
}:
let
  inherit (lib) mkOption types;
  nixvim-name = if config.vacu.nixvim.minimal then "nixvim-minimal" else "nixvim";
in
{
  options = {
    vacu.nixvim.minimal = mkOption {
      type = types.bool;
      default = config.vacu.isMinimal;
    };
    vacu.nixvimPkg = mkOption {
      type = types.package;
      readOnly = true;
    };
  };
  config = {
    vacu.nixvimPkg = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.${nixvim-name};
    vacu.packages = [
      (vacupkglib.aliasScript "nvim" [ "nvim-nixvim" ])
      (vacupkglib.aliasScript "nvim-plain" [ (lib.getExe pkgs.neovim) ])
      (vacupkglib.aliasScript "nvim-nixvim" [ (lib.getExe config.vacu.nixvimPkg) ])
    ];
  };
}
