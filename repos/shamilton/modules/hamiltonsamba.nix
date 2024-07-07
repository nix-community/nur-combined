{ config, lib, pkgs, options, modulesPath
, specialArgs}:
with lib;
let
  cfg = config.services.hamiltonsamba;
in {
  options.services.hamiltonsamba = {
    enable = mkEnableOption "Hamilton's samba shares";
  };
  config = mkIf cfg.enable {
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 139 445 ];
      allowedUDPPorts = [ 137 138 ];
    };
    services = {
      samba-wsdd = {
        enable = true;
        hostname = "HAMILTON's Server";
      };
      samba = {
        enable = true;
        nsswins = true;
        extraConfig = ''
        workgroup = WORKGROUP
        server string = Hamilton's Home Server
        server role = standalone server
        hosts allow = 192.168.1. 2a01:cb08:8d33:dd00:215f:3b13:29b8:21c3/64 localhost
        protocol = SMB3
        logging = systemd
        log level = 0
        passdb backend = tdbsam
        netbios name = PiServer
        map to guest = Never
        force user = scott
        force group = users
        server signing = mandatory

        # For windows NTLMv2 auth (for backups)
        ntlm auth = yes
        lanman auth = no
        client lanman auth = no
        '';
        shares = {
          public = {
            comment = "Hamilton's home share";
            "create mask" = 770;
            path = "/export/share";
            printable = "no";
            public = "no";
            "valid users" = [ "scott" "hamilton" ];
            writeable = "yes";
          };
          music = {
            comment = "Hamilton's music";
            "create mask" = 770;
            path = "/export/music";
            printable = "no";
            public = "no";
            "valid users" = [ "scott" "hamilton" ];
            writeable = "yes";
          };
        };
      };
    };
    users.users.hamilton = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };
}

