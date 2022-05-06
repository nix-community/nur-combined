{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profile.mobile-devices;

in
{
  meta.maintainers = [ wolfangaukang ];

  options.profile.mobile-devices = {
    android = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Enables Android support 
        '';
      };
      adb = {
        enable = mkOption {
          default = false;
          type = types.bool;
          description = ''
            Enable ADB 
          '';
        };
        adbuserGroupMembers = mkOption {
          default = [];
          type = types.listOf types.str;
          description = ''
            List of users to add to adbusers group 
          '';
        };
      };
      extraPkgs = mkOption {
        default = with pkgs; [ jmtpfs ];
        type = types.listOf types.package;
        description = ''
          List of extra packages to install for Android support 
        '';
      };
    };
    ios = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Enables iOS support 
        '';
      };
      extraPkgs = mkOption {
        default = with pkgs; [ ifuse libimobiledevice ];
        type = types.listOf types.package;
        description = ''
          List of extra packages to install for iOS support 
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.android.enable (mkMerge [
      { environment.systemPackages = cfg.android.extraPkgs; }
      (mkIf cfg.android.adb.enable {
        programs.adb.enable = true;
        users.extraGroups.adbusers.members = cfg.android.adb.adbusersGroupMembers;
      })
    ]))
    (mkIf cfg.ios.enable {
      environment.systemPackages = cfg.ios.extraPkgs;
      services.usbmuxd.enable = true;
    })
  ];
}

