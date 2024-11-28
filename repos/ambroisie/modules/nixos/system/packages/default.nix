# Common packages
{ config, lib, ... }:
let
  cfg = config.my.system.packages;
in
{
  options.my.system.packages = with lib; {
    enable = my.mkDisableOption "packages configuration";

    allowAliases = mkEnableOption "allow package aliases";

    allowUnfree = my.mkDisableOption "allow unfree packages";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      vim = {
        enable = true;
        defaultEditor = true; # Modal editing is life
      };

      zsh = {
        enable = true; # Use integrations
        # Disable global compinit when a user config exists
        enableGlobalCompInit = !config.my.home.zsh.enable;
      };
    };

    nixpkgs.config = {
      inherit (cfg) allowAliases allowUnfree;
    };
  };
}
