{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf versionOlder;
  cfg = config.modules.services.avahi;
  stable = versionOlder config.system.nixos.release "24.05";
in
{
  options = {
    modules.services.avahi = {
      enable = mkEnableOption "Enable avahi profile";
    };
  };

  config = mkIf cfg.enable
    {
      services = {
        avahi = {
          enable = true;
          ipv4 = true;
          ipv6 = true;
          publish = {
            enable = true;
            userServices = true;
          };
	  openFirewall = true;
        } // (if stable
        then {
          nssmdns = true;
        } else {
          nssmdns4 = true;
        });
      };
    };
}
