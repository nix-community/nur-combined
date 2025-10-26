{
  config,
  lib,
  pkgs,
  nur,
  ...
}:

let
  cfg = config.nagy.firefox;
in
{
  options.nagy.firefox = {
    enable = lib.mkEnableOption "firefox config";
  };
  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      # policies = {
      # };
    };

    # Firefox connects to these hosts on every start.
    # Hard disable them on the whole host.
    networking.hosts = {
      "0.0.0.0" = [
        "content-signature-2.cdn.mozilla.net"
        # maybe this one can still be disabled via `about:config`
        "firefox.settings.services.mozilla.com"
      ];
    };

  };
}
