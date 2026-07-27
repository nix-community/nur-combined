{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.modules.services.bind;
in
{
  options = {
    modules.services.bind = {
      enable = mkEnableOption "Enable bind profile";
    };
  };
  config = mkIf cfg.enable {

    services = {
      bind = {
        enable = true;
        forwarders = [ "8.8.8.8" "8.8.4.4" ];
        extraOptions = ''
          dnssec-validation no;
        '';
        cacheNetworks = [ "192.168.1.0/24" "127.0.0.0/8" "10.100.0.0/24" ];
        zones = [
	  {
	    # sbr
	    name = "sbr.pm";
	    master = true;
	    slaves = [];
	    file = ../../../secrets/db.sbr.pm;
	  }
          {
            # home
            name = "home";
            master = true;
            slaves = [ ];
            file = ../../../secrets/db.home;
          }
          {
            # home.reverse
            name = "192.168.1.in-addr.arpa";
            master = true;
            slaves = [ ];
            file = ../../../secrets/db.192.168.1;
          }
          {
            # vpn
            name = "vpn";
            master = true;
            slaves = [ ];
            file = ../../../secrets/db.vpn;
          }
          {
            # vpn.reverse
            name = "10.100.0.in-addr.arpa";
            master = true;
            slaves = [ ];
            file = ../../../secrets/db.10.100.0;
          }
        ];
      };
    };
  };
}
