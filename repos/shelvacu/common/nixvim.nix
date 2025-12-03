{
  pkgs,
  config,
  inputs,
  lib,
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
    vacu.nixvimPkg = inputs.self.packages.${pkgs.system}.${nixvim-name};
    vacu.shell.functions = lib.mkIf (!config.vacu.isMinimal) {
      nvim-plain = ''${pkgs.neovim}/bin/nvim "$@"'';
      nvim-nixvim = ''${config.vacu.nixvimPkg}/bin/nvim "$@"'';
      nvim = ''nvim-nixvim "$@"'';
    };
  };
}
