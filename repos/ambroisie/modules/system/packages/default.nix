# Common packages
{ config, lib, pkgs, ... }:
let
  cfg = config.my.system.packages;
in
{
  options.my.system.packages = with lib; {
    enable = my.mkDisableOption "packages configuration";

    allowUnfree = my.mkDisableOption "allow unfree packages";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vim
      wget
    ];

    programs = {
      vim.defaultEditor = true; # Modal editing is life

      zsh = {
        enable = true; # Use integrations
        # Disable global compinit when a user config exists
        enableGlobalCompInit = !config.my.home.zsh.enable;
      };
    };

    nixpkgs.config = {
      allowUnfree = cfg.allowUnfree; # Because I don't care *that* much.
    };
  };
}
