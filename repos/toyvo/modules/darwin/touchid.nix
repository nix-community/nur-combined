{
  config,
  lib,
  ...
}:
let
  cfg = config.nixcfg.darwin.touchid;
in
{
  options.nixcfg.darwin.touchid.enable = lib.mkEnableOption "Touch ID authentication for sudo";

  config = lib.mkIf cfg.enable {
    security.pam.services.sudo_local.touchIdAuth = true;
  };
}
