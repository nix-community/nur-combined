# pict-rs is an image database/store used by Lemmy.
# i don't explicitly activate it here -- just adjust its defaults to be a bit friendlier
{ config, lib, ... }:
let
  cfg = config.services.pict-rs;
in
{
  sane.persist.sys.byStore.plaintext = lib.mkIf cfg.enable [
    { user = "pict-rs"; group = "pict-rs"; path = cfg.dataDir; method = "bind"; }
  ];

  systemd.services.pict-rs.serviceConfig = {
    # fix to use a normal user so we can configure perms correctly
    DynamicUser = lib.mkForce false;
    User = "pict-rs";
    Group = "pict-rs";
  };
  users.groups.pict-rs = {};
  users.users.pict-rs = {
    group = "pict-rs";
    isSystemUser = true;
  };
}
