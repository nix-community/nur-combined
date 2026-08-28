{
  config,
  lib,
  ...
}:
let
  cfg = config.services.sillytavern;
in
{
  services.sillytavern = {
    enable = true;
    port = 8000;
  };
  systemd.tmpfiles.settings.sillytavern = {
    "/var/lib/SillyTavern/config.yaml" = lib.mkForce {
      "C+" = {
        mode = "0600";
        argument = cfg.configFile;
        inherit (cfg) user group;
      };
    };
  };
}
