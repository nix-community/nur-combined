# Usenet binary client.
{ config, lib, ... }:
let
  cfg = config.my.services.sabnzbd;
  port = 9090; # NOTE: not declaratively set...
in
{
  options.my.services.sabnzbd = with lib; {
    enable = mkEnableOption "SABnzbd binary news reader";
  };

  config = lib.mkIf cfg.enable {
    services.sabnzbd = {
      enable = true;
      group = "media";
    };

    # Set-up media group
    users.groups.media = { };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "sabnzbd";
        inherit port;
      }
    ];
  };
}
