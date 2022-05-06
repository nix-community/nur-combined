{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profile.gaming;

in
{
  meta.maintainers = [ wolfangaukang ];

  options.profile.gaming = {
    enable = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Enables gaming profile on NixOS
      '';
    };
    installNativeSteam = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Installs Steam through programs.steam settings
      '';
    };
    steamPackage = mkOption {
      default = pkgs.steam;
      type = types.package;
      description = ''
        Steam package to install 
      '';
    };
    useJoycond = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Enables joycond (blocks Pro controller on Steam) 
      '';
    };
    useSteamHardware = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Enables steam-hardware (does not recognize joycons) 
      '';
    };
    extraPkgs = mkOption {
      default = [];
      type = types.listOf types.package;
      description = ''
        List of extra packages to install
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      environment.systemPackages = cfg.extraPkgs;
      hardware.steam-hardware.enable = mkIf cfg.useSteamHardware true;
      services.joycond.enable = mkIf cfg.useJoycond true;
    }
    (mkIf cfg.installNativeSteam {
      environment.systemPackages = [ cfg.steamPackage ];
      programs.steam.enable = true;
      nixpkgs.config.allowUnfreePredicate = (
        pkg: builtins.elem (lib.getName pkg) [ "steam" "steam-original" "steam-runtime" ]
      );
      hardware.opengl = {
        extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
        setLdLibraryPath = true;
      };
    })
  ]);
}

