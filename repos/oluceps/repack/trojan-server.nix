{
  reIf,
  lib,
  config,
  ...
}:
reIf {
  services.trojan-server.enable = true;
  systemd.services.trojan-server.serviceConfig.LoadCredential = (map (lib.genCredPath config)) [
    "nyaw.cert"
    "nyaw.key"
  ];
}
