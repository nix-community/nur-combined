{
  reIf,
  lib,
  pkgs,
  ...
}:
reIf {
  services.atuin = {
    enable = true;
    host = "fdcc::3";
    port = 8888;
    openFirewall = false;
    openRegistration = false;
    maxHistoryLength = 65536;
    database.uri = "postgresql://atuin@127.0.0.1:5432/atuin";
  };

  systemd.services = {
    atuin.serviceConfig.ExecStart = lib.mkForce "${(lib.getExe pkgs.atuin)} server start";
  };
}
