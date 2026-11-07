{
  config,
  lib,
  pkgs,
  inputs,
  options,
  ...
}:
let
  cfg = config.nixcfg.security;
in
{
  options.nixcfg.security.enable = lib.mkEnableOption "security defaults (sops)";

  config = lib.mkIf cfg.enable (
    (
      if (builtins.hasAttr "sops" options) then
        {
          sops = {
            defaultSopsFile = ../../secrets.yaml;
            age.keyFile = "/var/sops/age/keys.txt";
          };
        }
      else
        {
        }
    )
  );
}
