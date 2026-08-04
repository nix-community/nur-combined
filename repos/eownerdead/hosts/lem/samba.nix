{ pkgs, ... }:
{
  services = {
    samba = {
      enable = true;
      package = pkgs.sambaFull;
      openFirewall = true;
      settings = {
        global = {
          security = "user";
        };
        data = {
          path = "/data";
          "guest ok" = true;
          writeable = true;
        };
      };
    };
    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
  };
}
