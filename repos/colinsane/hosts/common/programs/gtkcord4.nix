# FIRST-TIME SETUP:
# - disable notification sounds: hamburger menu in bottom-left -> preferences
#   - notification sounds can be handled by swaync
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.gtkcord4;
in
{
  sane.programs.gtkcord4 = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.autostart = mkOption {
          type = types.bool;
          default = true;
        };
      };
    };

    package = pkgs.gtkcord4.overrideAttrs (upstream: {
      postConfigure = (upstream.postConfigure or "") + ''
        # gtkcord4 uses go-keyring to interface with the org.freedesktop.secrets provider (i.e. gnome-keyring).
        # go-keyring hardcodes `login.keyring` as the keyring to store secrets in, instead of reading `~/.local/share/keyring/default`.
        # `login.keyring` seems to be a special keyring preconfigured (by gnome-keyring) to encrypt everything to the user's password.
        # that's redundant with my fs-level encryption and makes the keyring less inspectable,
        # so patch gtkcord4 to use Default_keyring instead.
        # see:
        # - <https://github.com/diamondburned/gtkcord4/issues/139>
        # - <https://github.com/zalando/go-keyring/issues/46>
        substituteInPlace vendor/github.com/zalando/go-keyring/secret_service/secret_service.go \
          --replace '"login"' '"Default_keyring"'
      '';
    });

    persist.byStore.private = [
      ".cache/gtkcord4"
      ".config/gtkcord4"  # empty?
    ];

    services.gtkcord4 = {
      description = "unofficial Discord chat client";
      wantedBy = lib.mkIf cfg.config.autostart [ "default.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/gtkcord4";
        Type = "simple";
        Restart = "always";
        RestartSec = "20s";
      };
    };
  };
}
