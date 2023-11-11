{ config, lib, pkgs, ... }:
let
  cfg = config.my.system.documentation;
in
{
  options.my.system.documentation = with lib; {
    enable = my.mkDisableOption "Documentation integration";

    dev.enable = my.mkDisableOption "Documentation aimed at developers";

    info.enable = my.mkDisableOption "Documentation aimed at developers";

    man = {
      enable = my.mkDisableOption "Documentation aimed at developers";

      linux = my.mkDisableOption "Linux man pages (section 2 & 3)";
    };

    nixos.enable = my.mkDisableOption "NixOS documentation";
  };

  config = lib.mkIf cfg.enable {
    documentation = {
      enable = true;

      dev.enable = cfg.dev.enable;

      info.enable = cfg.info.enable;

      man = {
        enable = cfg.man.enable;
        generateCaches = true;
      };

      nixos.enable = cfg.nixos.enable;
    };

    environment.systemPackages = with pkgs; lib.optionals cfg.man.linux [
      man-pages
      man-pages-posix
    ];
  };
}
