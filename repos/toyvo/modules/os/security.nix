{ config, lib, ... }:
let
  cfg = config.nixcfg.security;
in
{
  options.nixcfg.security.enable = lib.mkEnableOption "security defaults (sops)";

  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFile = ../../secrets.yaml;
      age.keyFile = "/var/sops/age/keys.txt";
    };
  };
}
