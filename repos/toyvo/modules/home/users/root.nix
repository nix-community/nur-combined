{
  config,
  lib,
  pkgs,
  system,
  inputs,
  ...
}:
let
  cfg = config.nixcfg;
in
{
  options.nixcfg.users.root.enable = lib.mkEnableOption "Enable root profile";

  config = lib.mkIf cfg.users.root.enable {
    catppuccin = {
      enable = true;
      autoEnable = true;
      flavor = "frappe";
      accent = "red";
    };
    home = {
      packages = [
        inputs.nixcfg.packages.${system}.toyvo-neovim
      ];
      sessionVariables.EDITOR = "nvim";
    };
    programs = {
      man.package = pkgs.man;
      helix.enable = true;
    };
  };
}
