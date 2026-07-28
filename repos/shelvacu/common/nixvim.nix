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
  options.vacu = {
    nixvim.minimal = mkOption {
      type = types.bool;
      default = config.vacu.isMinimal;
    };
    nixvimPkg = mkOption {
      type = types.package;
      readOnly = true;
    };
  };
  config.vacu = {
    environment.variables.EDITOR = lib.getExe pkgs.neovim;
    nixvimPkg = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.${nixvim-name};
    packages = [
      config.vacu.nixvimPkg
      (vacupkglib.aliasScript "nvim-plain" [ (lib.getExe pkgs.neovim) ])
      (vacupkglib.aliasScript "nvim-nixvim" [ (lib.getExe config.vacu.nixvimPkg) ])
    ];
  };
}
