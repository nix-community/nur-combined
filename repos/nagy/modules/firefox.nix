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

    # From https://nixos.wiki/wiki/Firefox
    # You can make Firefox use xinput2 by setting the MOZ_USE_XINPUT2 environment
    # variable. This improves touchscreen support and enables additional touchpad
    # gestures. It also enables smooth scrolling as opposed to the stepped
    # scrolling that Firefox has by default.
    environment.sessionVariables = lib.mkIf config.services.xserver.enable { MOZ_USE_XINPUT2 = "1"; };
  };
}
