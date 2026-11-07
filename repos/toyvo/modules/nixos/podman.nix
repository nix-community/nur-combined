{
  config,
  lib,
  ...
}:
let
  cfg = config.virtualisation;
in
{
  config = lib.mkIf cfg.podman.enable {
    users.groups.podman = { };
    virtualisation.podman = {
      defaultNetwork.settings.dns_enabled = true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };
  };
}
