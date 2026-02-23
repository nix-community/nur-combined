{ lib, config, ... }:
{
  config.services = lib.mkIf config.services.samba.enable {
    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
    samba = {
      openFirewall = true;
      settings = {
        global = {
          "netbios name" = "nas";
          security = "user";
          "server role" = "standalone";
          # 10.1.0.0/24 is the local network,
          # 100.89.0.0/16 is NetBird's network,
          "hosts allow" = "10.1.0.0/24 100.89.0.0/16 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
          "log level" = "2 auth_audit:5";
        };
        public = {
          path = "/mnt/POOL/Public";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0664";
          "directory mask" = "0775";
          "force user" = "nobody";
          "force group" = "users";
          "valid users" = "@users";
        };
        collin = {
          path = "/mnt/POOL/Collin";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0640";
          "directory mask" = "0750";
          "force user" = "toyvo";
          "force group" = "toyvo";
          "valid users" = "@toyvo";
        };
        chloe = {
          path = "/mnt/POOL/Chloe";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0640";
          "directory mask" = "0750";
          "force user" = "chloe";
          "force group" = "chloe";
          "valid users" = "@chloe";
        };
      };
    };
  };
}
