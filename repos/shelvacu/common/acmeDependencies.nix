{
  config,
  lib,
  utils,
  vacuModuleType,
  ...
}:
let
  for-systemd-services = lib.concatMapAttrs (cert: units: {
    "acme-selfsigned-${cert}" = {
      wantedBy = units;
      before = units;
    };
  }) config.vacu.acmeCertDependencies;
  for-security-acme-certs = lib.concatMapAttrs (cert: units: {
    ${cert}.reloadServices = units;
  }) config.vacu.acmeCertDependencies;
in
lib.optionalAttrs (vacuModuleType == "nixos") {
  options.vacu.acmeCertDependencies = lib.mkOption {
    default = { };
    example = ''
      vacu.acmeCertDependencies."mail.example.com" = [ "postfix.service" ];
    '';
    type = lib.types.attrsOf (lib.types.listOf utils.systemdUtils.lib.unitNameType);
  };
  config = {
    systemd.services = for-systemd-services;
    security.acme.certs = for-security-acme-certs;
  };
}
