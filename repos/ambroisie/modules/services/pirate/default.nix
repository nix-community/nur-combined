# The total autonomous media delivery system.
# Relevant link [1].
#
# [1]: https://youtu.be/I26Ql-uX6AM
{ config, lib, ... }:
let
  cfg = config.my.services.pirate;

  ports = {
    bazarr = 6767;
    lidarr = 8686;
    radarr = 7878;
    sonarr = 8989;
  };

  managers = with lib.attrsets;
    (mapAttrs
      (_: _: {
        enable = true;
        group = "media";
      })
      ports);

  redirections = lib.flip lib.mapAttrsToList ports
    (subdomain: port: { inherit subdomain port; });
in
{
  options.my.services.pirate = {
    enable = lib.mkEnableOption "Media automation";
  };

  config = lib.mkIf cfg.enable {
    services = managers;
    my.services.nginx.virtualHosts = redirections;
    # Set-up media group
    users.groups.media = { };
  };
}
